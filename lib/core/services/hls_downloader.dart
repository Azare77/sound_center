// mp4_remux.dart
//
// Pure-Dart defragmenter for CMAF/fragmented-MP4 (HLS output with EXT-X-MAP).
// Equivalent to what `ffmpeg -i in.mp4 -c copy out.m4a` does: without
// transcoding, it only converts the container from fragmented (moov with
// duration=0 + multiple moof/mdat) to flat (one moov with a complete sample
// table + one mdat).
//
// Assumptions (valid for audio-only usage such as SoundCloud HLS):
//   - One audio track, without B-frames / composition-time-offset
//   - Each downloaded segment contains exactly one moof+mdat pair (one CMAF fragment)
//   - edts (edit list) is removed because it is no longer meaningful after remux
//
// Known limitation: if the playlist contains multiple tracks (e.g. audio+video)
// or multiple EXT-X-MAP entries, this code must be adjusted before use — currently
// it only processes the first/only trak.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class HlsDownloader {
  /// Downloads a complete HLS stream using parallel downloads for a significant
  /// speed improvement.
  ///
  /// [waitIfPaused] is awaited at the beginning of each worker iteration. If
  /// paused, the worker remains suspended there until resume is called, without
  /// losing segments that have already been downloaded.
  static Future<File> downloadAndMux({
    required String m3u8Url,
    required String outputPath,
    required Function(double) onProgress,
    Future<void> Function()? waitIfPaused,
  }) async {
    final playlistResp = await http.get(Uri.parse(m3u8Url));
    if (playlistResp.statusCode != 200) {
      throw Exception('filed getting playlist: ${playlistResp.statusCode}');
    }
    final lines = const LineSplitter().convert(playlistResp.body);

    String? initUrl;
    final segmentUrls = <String>[];

    for (final line in lines) {
      if (line.startsWith('#EXT-X-MAP:URI=')) {
        final match = RegExp(r'URI="([^"]+)"').firstMatch(line);
        if (match != null) initUrl = match.group(1);
      } else if (line.isNotEmpty && !line.startsWith('#')) {
        segmentUrls.add(line);
      }
    }

    if (initUrl == null || segmentUrls.isEmpty) {
      throw Exception('wrong playlist or no segment');
    }

    // 1) Download the Init Segment immediately and directly
    final initBytes = await _fetchBytes(initUrl);
    onProgress(0.05);

    // 2) Create an array to store downloaded segments while preserving disk order
    final downloadedSegments = List<List<int>?>.filled(
      segmentUrls.length,
      null,
    );
    int completedCount = 0;

    // 3) Configure concurrency (e.g. download 8 segments simultaneously)
    const int maxConcurrentDownloads = 8;
    int currentTaskIndex = 0;

    // Helper function for managing the parallel queue
    Future<void> worker() async {
      while (currentTaskIndex < segmentUrls.length) {
        // If paused, suspend here until resumed; do not start the next segment,
        // but do not cancel segments that are currently being downloaded.
        await waitIfPaused?.call();

        final index = currentTaskIndex++;
        final url = segmentUrls[index];

        try {
          final bytes = await _fetchBytes(url);
          downloadedSegments[index] = bytes;
          completedCount++;

          // Update the progress percentage in real time
          double progressRatio =
              0.05 + (completedCount / segmentUrls.length) * 0.95;
          onProgress(progressRatio);
        } catch (e) {
          rethrow;
        }
      }
    }

    // Start all workers concurrently
    final workers = List.generate(maxConcurrentDownloads, (_) => worker());

    // Wait for all segments to finish downloading
    await Future.wait(workers);

    final result = remuxFragmentsToFlatMp4(
      initBytes: Uint8List.fromList(initBytes),
      fragmentBytesList: downloadedSegments
          .whereType<List<int>>()
          .map((s) => Uint8List.fromList(s))
          .toList(),
    );

    final outFile = File(outputPath);
    await outFile.writeAsBytes(result.bytes);

    return outFile;
  }

  static Future<List<int>> _fetchBytes(String url) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('Error in segment downloading: (${resp.statusCode})');
    }
    return resp.bodyBytes;
  }
}

class Mp4RemuxException implements Exception {
  final String message;

  Mp4RemuxException(this.message);

  @override
  String toString() => 'Mp4RemuxException: $message';
}

class FlatMp4Result {
  final Uint8List bytes;
  final int durationMs;

  FlatMp4Result(this.bytes, this.durationMs);
}

/// Main entry point. `initBytes` = init segment (from EXT-X-MAP),
/// `fragmentBytesList` = downloaded segments in the same order as the playlist.
FlatMp4Result remuxFragmentsToFlatMp4({
  required Uint8List initBytes,
  required List<Uint8List> fragmentBytesList,
}) {
  // --- Parse fragments and build the sample tables ---
  final initBoxes = _Mp4Box.parseTop(initBytes);
  final ftyp = _Mp4Box.find(initBoxes, 'ftyp');
  final moov = _Mp4Box.find(initBoxes, 'moov');
  if (ftyp == null || moov == null) {
    throw Mp4RemuxException('init segment without ftyp or moov');
  }

  final moovBoxes = _Mp4Box.parseTop(moov.payload);
  final mvhdBox = _Mp4Box.find(moovBoxes, 'mvhd');
  final trakBox = _Mp4Box.find(moovBoxes, 'trak');
  if (mvhdBox == null || trakBox == null) {
    throw Mp4RemuxException('moov is without mvhd or trak');
  }

  final movieTimescale = _readTimescale(mvhdBox.payload);

  final trakBoxes = _Mp4Box.parseTop(trakBox.payload);
  final tkhdBox = _Mp4Box.find(trakBoxes, 'tkhd');
  final mdiaBox = _Mp4Box.find(trakBoxes, 'mdia');
  if (tkhdBox == null || mdiaBox == null) {
    throw Mp4RemuxException('trak is without tkhd or mdia');
  }

  final mdiaBoxes = _Mp4Box.parseTop(mdiaBox.payload);
  final mdhdBox = _Mp4Box.find(mdiaBoxes, 'mdhd');
  final minfBox = _Mp4Box.find(mdiaBoxes, 'minf');
  if (mdhdBox == null || minfBox == null) {
    throw Mp4RemuxException('mdia is without mdhd or minf');
  }
  final mediaTimescale = _readTimescale(mdhdBox.payload);

  final minfBoxes = _Mp4Box.parseTop(minfBox.payload);
  final stblBox = _Mp4Box.find(minfBoxes, 'stbl');
  if (stblBox == null) throw Mp4RemuxException('minf is missing stbl');
  final stblBoxes = _Mp4Box.parseTop(stblBox.payload);
  final stsdBox = _Mp4Box.find(stblBoxes, 'stsd');
  if (stsdBox == null) throw Mp4RemuxException('stbl is without stsd');

  // --- Parse fragments and build sample tables ---
  final durations = <int>[];
  final sizes = <int>[];
  final chunkSampleCounts = <int>[];
  final mdatParts = <Uint8List>[];

  for (final segment in fragmentBytesList) {
    final frag = _parseFragment(segment);
    if (frag.samples.isEmpty) continue;
    chunkSampleCounts.add(frag.samples.length);
    mdatParts.add(frag.mdatPayload);
    for (final s in frag.samples) {
      if (s.duration == null || s.size == null) {
        throw Mp4RemuxException("sample is without size or duration");
      }
      durations.add(s.duration!);
      sizes.add(s.size!);
    }
  }

  if (durations.isEmpty) {
    throw Mp4RemuxException('no sample out of fragments');
  }

  final totalDurationMediaTs = durations.fold<int>(0, (a, b) => a + b);
  final totalDurationMovieTs =
      (totalDurationMediaTs / mediaTimescale * movieTimescale).round();

  final sttsBox = _buildStts(durations);
  final stszBox = _buildStsz(sizes);
  final stscBox = _buildStsc(chunkSampleCounts);

  // Build the moov box with the calculated duration and chunk offsets.
  Uint8List buildMoov(Uint8List stcoBox) {
    final newStblPayload = BytesBuilder()
      ..add(_Mp4Box.build('stsd', stsdBox.payload))
      ..add(sttsBox)
      ..add(stszBox)
      ..add(stscBox)
      ..add(stcoBox);
    final newStbl = _Mp4Box.build('stbl', newStblPayload.toBytes());

    final newMinfPayload = BytesBuilder();
    for (final b in minfBoxes) {
      newMinfPayload.add(
        b.type == 'stbl' ? newStbl : _Mp4Box.build(b.type, b.payload),
      );
    }
    final newMinf = _Mp4Box.build('minf', newMinfPayload.toBytes());

    final newMdhd = _Mp4Box.build(
      'mdhd',
      _patchFullBoxDuration(mdhdBox.payload, totalDurationMediaTs),
    );

    final newMdiaPayload = BytesBuilder();
    for (final b in mdiaBoxes) {
      if (b.type == 'mdhd') {
        newMdiaPayload.add(newMdhd);
      } else if (b.type == 'minf') {
        newMdiaPayload.add(newMinf);
      } else {
        newMdiaPayload.add(_Mp4Box.build(b.type, b.payload));
      }
    }
    final newMdia = _Mp4Box.build('mdia', newMdiaPayload.toBytes());

    final newTkhd = _Mp4Box.build(
      'tkhd',
      _patchTkhdDuration(tkhdBox.payload, totalDurationMovieTs),
    );

    final newTrakPayload = BytesBuilder();
    for (final b in trakBoxes) {
      if (b.type == 'tkhd') {
        newTrakPayload.add(newTkhd);
      } else if (b.type == 'mdia') {
        newTrakPayload.add(newMdia);
      } else if (b.type == 'edts') {
        continue; // The old edit list is no longer valid after remux.
      } else {
        newTrakPayload.add(_Mp4Box.build(b.type, b.payload));
      }
    }
    final newTrak = _Mp4Box.build('trak', newTrakPayload.toBytes());

    final newMvhd = _Mp4Box.build(
      'mvhd',
      _patchFullBoxDuration(mvhdBox.payload, totalDurationMovieTs),
    );

    final newMoovPayload = BytesBuilder();
    for (final b in moovBoxes) {
      if (b.type == 'mvhd') {
        newMoovPayload.add(newMvhd);
      } else if (b.type == 'trak') {
        newMoovPayload.add(newTrak);
      } else if (b.type == 'mvex') {
        continue; // The final file is not fragmented, so mvex is meaningless.
      } else {
        newMoovPayload.add(_Mp4Box.build(b.type, b.payload));
      }
    }
    return _Mp4Box.build('moov', newMoovPayload.toBytes());
  }

  // First step: build moov with a placeholder stco (zero offsets) only to
  // determine the size of the moov box.
  final placeholderStco = _buildStco(List.filled(chunkSampleCounts.length, 0));
  final moovForSizing = buildMoov(placeholderStco);

  final ftypBox = _Mp4Box.build('ftyp', ftyp.payload);
  final mdatDataOffset =
      ftypBox.length + moovForSizing.length + 8; // +8 = mdat header

  final chunkOffsets = <int>[];
  int running = mdatDataOffset;
  for (final part in mdatParts) {
    chunkOffsets.add(running);
    running += part.length;
  }

  final finalStco = _buildStco(chunkOffsets);
  final finalMoov = buildMoov(finalStco);

  // Since stco (uint32) has exactly the same length in both the placeholder
  // and final versions (unless the file is >4GB, which is unlikely for music),
  // the moov size remains unchanged and the calculated offsets stay valid.
  if (finalMoov.length != moovForSizing.length) {
    throw Mp4RemuxException(
      'size of moov after offset calculation probably is more than  >4GB need cod64',
    );
  }

  final mdatPayloadTotal = BytesBuilder();
  for (final part in mdatParts) {
    mdatPayloadTotal.add(part);
  }
  final mdatBox = _Mp4Box.build('mdat', mdatPayloadTotal.toBytes());

  final output = BytesBuilder()
    ..add(ftypBox)
    ..add(finalMoov)
    ..add(mdatBox);

  final durationMs = (totalDurationMediaTs / mediaTimescale * 1000).round();
  return FlatMp4Result(output.toBytes(), durationMs);
}

// ------------------------- Parse fragment (moof+mdat) -------------------------

class _TrunSample {
  final int? duration;
  final int? size;

  _TrunSample({this.duration, this.size});
}

class _FragmentInfo {
  final List<_TrunSample> samples;
  final Uint8List mdatPayload;

  _FragmentInfo(this.samples, this.mdatPayload);
}

_FragmentInfo _parseFragment(Uint8List segmentBytes) {
  final topBoxes = _Mp4Box.parseTop(segmentBytes);
  final moof = _Mp4Box.find(topBoxes, 'moof');
  final mdat = _Mp4Box.find(topBoxes, 'mdat');
  if (moof == null || mdat == null) {
    throw Mp4RemuxException('one segment is without moof or mdat');
  }

  final moofBoxes = _Mp4Box.parseTop(moof.payload);
  final traf = _Mp4Box.find(moofBoxes, 'traf');
  if (traf == null) throw Mp4RemuxException('moof is without traf');
  final trafBoxes = _Mp4Box.parseTop(traf.payload);

  int? defaultDuration;
  int? defaultSize;

  final tfhd = _Mp4Box.find(trafBoxes, 'tfhd');
  if (tfhd != null) {
    final bd = ByteData.sublistView(tfhd.payload);
    final flags = bd.getUint32(0) & 0x00FFFFFF;
    int off = 4 + 4; // version+flags(4) + track_ID(4)
    if (flags & 0x000001 != 0) off += 8; // base-data-offset-present
    if (flags & 0x000002 != 0) off += 4; // sample-description-index-present
    if (flags & 0x000008 != 0) {
      defaultDuration = bd.getUint32(off);
      off += 4;
    }
    if (flags & 0x000010 != 0) {
      defaultSize = bd.getUint32(off);
      off += 4;
    }
    // We do not need default-sample-flags (0x000020)
    // because they are only required for stss/sync.
  }

  final samples = <_TrunSample>[];
  for (final b in trafBoxes.where((x) => x.type == 'trun')) {
    final bd = ByteData.sublistView(b.payload);
    final flags = bd.getUint32(0) & 0x00FFFFFF;
    final sampleCount = bd.getUint32(4);
    int off = 8;
    if (flags & 0x000001 != 0) off += 4; // data-offset-present
    if (flags & 0x000004 != 0) off += 4; // first-sample-flags-present

    final hasDuration = flags & 0x000100 != 0;
    final hasSize = flags & 0x000200 != 0;
    final hasFlags = flags & 0x000400 != 0;
    final hasCts = flags & 0x000800 != 0;

    for (int i = 0; i < sampleCount; i++) {
      int? dur, size;
      if (hasDuration) {
        dur = bd.getUint32(off);
        off += 4;
      }
      if (hasSize) {
        size = bd.getUint32(off);
        off += 4;
      }
      if (hasFlags) off += 4;
      if (hasCts) off += 4;
      samples.add(
        _TrunSample(
          duration: dur ?? defaultDuration,
          size: size ?? defaultSize,
        ),
      );
    }
  }

  return _FragmentInfo(samples, mdat.payload);
}

// ------------------------- Build stbl boxes -------------------------

Uint8List _buildStts(List<int> durations) {
  final entries = <List<int>>[]; // [sampleCount, delta]
  for (final d in durations) {
    if (entries.isNotEmpty && entries.last[1] == d) {
      entries.last[0]++;
    } else {
      entries.add([1, d]);
    }
  }

  final payload = BytesBuilder()
    ..add(_fullBoxHeader())
    ..add(_u32(entries.length));
  for (final e in entries) {
    payload.add(_u32(e[0]));
    payload.add(_u32(e[1]));
  }
  return _Mp4Box.build('stts', payload.toBytes());
}

Uint8List _buildStsz(List<int> sizes) {
  final allSame = sizes.every((s) => s == sizes.first);
  final payload = BytesBuilder()..add(_fullBoxHeader());
  if (allSame) {
    payload.add(_u32(sizes.first));
    payload.add(_u32(sizes.length));
  } else {
    payload.add(_u32(0));
    payload.add(_u32(sizes.length));
    for (final s in sizes) {
      payload.add(_u32(s));
    }
  }
  return _Mp4Box.build('stsz', payload.toBytes());
}

Uint8List _buildStsc(List<int> chunkSampleCounts) {
  final payload = BytesBuilder()
    ..add(_fullBoxHeader())
    ..add(_u32(chunkSampleCounts.length));
  for (int i = 0; i < chunkSampleCounts.length; i++) {
    payload.add(_u32(i + 1)); // first_chunk (1-based)
    payload.add(_u32(chunkSampleCounts[i])); // samples_per_chunk
    payload.add(_u32(1)); // sample_description_index
  }
  return _Mp4Box.build('stsc', payload.toBytes());
}

Uint8List _buildStco(List<int> offsets) {
  final payload = BytesBuilder()
    ..add(_fullBoxHeader())
    ..add(_u32(offsets.length));
  for (final o in offsets) {
    payload.add(_u32(o));
  }
  return _Mp4Box.build('stco', payload.toBytes());
}

// ------------------------- Patch duration -------------------------

/// For mvhd and mdhd: both use the same layout
/// (version+flags, creation, modification, timescale, duration, ...).
int _readTimescale(Uint8List fullBoxPayload) {
  final bd = ByteData.sublistView(fullBoxPayload);
  final version = fullBoxPayload[0];
  return version == 1 ? bd.getUint32(4 + 8 + 8) : bd.getUint32(4 + 4 + 4);
}

Uint8List _patchFullBoxDuration(Uint8List fullBoxPayload, int newDuration) {
  final out = Uint8List.fromList(fullBoxPayload);
  final outBd = ByteData.sublistView(out);
  final version = fullBoxPayload[0];
  if (version == 1) {
    outBd.setUint64(4 + 8 + 8 + 4, newDuration);
  } else {
    outBd.setUint32(4 + 4 + 4 + 4, newDuration);
  }
  return out;
}

/// tkhd has a different layout: creation/modification/track_ID/reserved/duration
Uint8List _patchTkhdDuration(Uint8List fullBoxPayload, int newDuration) {
  final out = Uint8List.fromList(fullBoxPayload);
  final outBd = ByteData.sublistView(out);
  final version = fullBoxPayload[0];
  if (version == 1) {
    // 4(v+flags) + 8(creation) + 8(modification) + 4(track_ID) + 4(reserved)
    outBd.setUint64(28, newDuration);
  } else {
    // 4(v+flags) + 4(creation) + 4(modification) + 4(track_ID) + 4(reserved)
    outBd.setUint32(20, newDuration);
  }
  return out;
}

// ------------------------- General box helpers -------------------------

List<int> _fullBoxHeader() => const [0, 0, 0, 0]; // version=0, flags=0

Uint8List _u32(int v) => (ByteData(4)..setUint32(0, v)).buffer.asUint8List();

class _Mp4Box {
  final String type;
  final Uint8List payload;

  _Mp4Box(this.type, this.payload);

  static List<_Mp4Box> parseTop(Uint8List bytes) {
    final boxes = <_Mp4Box>[];
    int offset = 0;
    while (offset + 8 <= bytes.length) {
      final header = ByteData.sublistView(bytes, offset, offset + 8);
      int size = header.getUint32(0);
      final type = ascii.decode(bytes.sublist(offset + 4, offset + 8));
      int headerSize = 8;
      if (size == 1) {
        if (offset + 16 > bytes.length) break;
        size = ByteData.sublistView(
          bytes,
          offset + 8,
          offset + 16,
        ).getUint64(0);
        headerSize = 16;
      } else if (size == 0) {
        size = bytes.length - offset;
      }
      if (size < headerSize || offset + size > bytes.length) break;
      boxes.add(
        _Mp4Box(type, bytes.sublist(offset + headerSize, offset + size)),
      );
      offset += size;
    }
    return boxes;
  }

  static _Mp4Box? find(List<_Mp4Box> boxes, String type) {
    for (final b in boxes) {
      if (b.type == type) return b;
    }
    return null;
  }

  static Uint8List build(String type, List<int> payload) {
    final size = 8 + payload.length;
    final b = BytesBuilder();
    b.add(_u32(size));
    b.add(ascii.encode(type));
    b.add(payload);
    return b.toBytes();
  }
}
