// mp4_remux.dart
//
// Pure-Dart defragmenter برای CMAF/fragmented-MP4 (خروجی HLS با EXT-X-MAP).
// معادل چیزیه که `ffmpeg -i in.mp4 -c copy out.m4a` انجام میده: بدون
// transcode، فقط container رو از fragmented (moov با duration=0 + چند
// moof/mdat) به flat (یک moov با جدول sample کامل + یک mdat) تبدیل می‌کنه.
//
// فرض‌ها (برای مصرف audio-only مثل SoundCloud HLS معتبره):
//   - یک track صوتی، بدون B-frame / composition-time-offset
//   - هر segment دانلودی دقیقاً یک جفت moof+mdat هست (یک CMAF fragment)
//   - edts (edit list) حذف می‌شه چون بعد از remux معنی نداره
//
// محدودیت شناخته‌شده: اگه پلی‌لیست شما چند track (مثلاً audio+video) یا
// چند EXT-X-MAP داشته باشه، این کد باید قبل از استفاده اصلاح بشه — فعلاً
// فقط اولین/تنها trak رو پردازش می‌کنه.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

class HlsDownloader {
  /// دانلود کامل یک استریم HLS با متد دانلود موازی برای افزایش سرعت چشمگیر.
  ///
  /// [waitIfPaused] در ابتدای هر iteration ورکر await می‌شه؛ اگه pause شده
  /// باشه، ورکر همون‌جا معلق می‌مونه تا resume صدا زده بشه، بدون این‌که
  /// segmentهایی که تا اون لحظه دانلود شدن از دست برن.
  static Future<File> downloadAndMux({
    required String m3u8Url,
    required String outputPath,
    required Function(double) onProgress,
    Future<void> Function()? waitIfPaused,
  }) async {
    print('🌐 [HlsDownloader] دریافت مانیفست m3u8...');
    final playlistResp = await http.get(Uri.parse(m3u8Url));
    if (playlistResp.statusCode != 200) {
      throw Exception('دریافت پلی‌لیست ناموفق بود: ${playlistResp.statusCode}');
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
      throw Exception('پلی‌لیست معتبر نیست یا سگمنتی پیدا نشد');
    }

    print(
      '📦 [HlsDownloader] تعداد کل سگمنت‌ها: ${segmentUrls.length}. شروع دانلود موازی...',
    );

    // ۱) دانلود فورا و مستقیم Init Segment
    final initBytes = await _fetchBytes(initUrl);
    onProgress(0.05);

    // ۲) تعریف آرایه برای نگهداری سگمنت‌های دانلود شده با حفظ ترتیب دیسک
    final downloadedSegments = List<List<int>?>.filled(
      segmentUrls.length,
      null,
    );
    int completedCount = 0;

    // ۳) تنظیم میزان همزمانی (مثلا دانلود همزمان 8 سگمنت با هم)
    const int maxConcurrentDownloads = 8;
    int currentTaskIndex = 0;

    // تابع کمکی برای مدیریت صف موازی
    Future<void> worker() async {
      while (currentTaskIndex < segmentUrls.length) {
        // اگه pause شده، همین‌جا معلق می‌مونه تا resume بشه؛ segment بعدی
        // رو شروع نمی‌کنه ولی segmentهای در حال دانلود فعلی رو کنسل نمی‌کنه.
        await waitIfPaused?.call();

        final index = currentTaskIndex++;
        final url = segmentUrls[index];

        try {
          final bytes = await _fetchBytes(url);
          downloadedSegments[index] = bytes;
          completedCount++;

          // آپدیت درصد پیشرفت به صورت زنده
          double progressRatio =
              0.05 + (completedCount / segmentUrls.length) * 0.95;
          onProgress(progressRatio);
        } catch (e) {
          print('❌ خطا در دانلود سگمنت شماره $index: $e');
          rethrow;
        }
      }
    }

    // شروع کار ورکرها به صورت همزمان
    final workers = List.generate(maxConcurrentDownloads, (_) => worker());

    // انتظار برای اتمام دانلود تمام سگمنت‌ها
    await Future.wait(workers);

    print('💾 [HlsDownloader] در حال remux به flat MP4...');
    final result = remuxFragmentsToFlatMp4(
      initBytes: Uint8List.fromList(initBytes),
      fragmentBytesList: downloadedSegments
          .whereType<List<int>>()
          .map((s) => Uint8List.fromList(s))
          .toList(),
    );
    print('⏱️ duration محاسبه‌شده: ${result.durationMs}ms');

    final outFile = File(outputPath);
    await outFile.writeAsBytes(result.bytes);
    // ۴) نوشتن همگی در فایل خروجی به ترتیب کاملا درست مانیفست
    // print(
    //   '💾 [HlsDownloader] تمام پارت‌ها دانلود شدند. در حال سرهم‌بندی (Mux) روی دیسک...',
    // );
    // final outFile = File(outputPath);
    // final sink = outFile.openWrite();
    //
    // try {
    //   sink.add(initBytes); // اول ftyp+moov
    //   for (final segmentBytes in downloadedSegments) {
    //     if (segmentBytes != null) {
    //       sink.add(segmentBytes);
    //     }
    //   }
    // } finally {
    //   await sink.flush();
    //   await sink.close();
    //   print('✨ [HlsDownloader] فایل نهایی با موفقیت ساخته شد.');
    // }

    return outFile;
  }

  static Future<List<int>> _fetchBytes(String url) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode != 200) {
      throw Exception('دانلود سگمنت ناموفق: (${resp.statusCode})');
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

/// نقطه‌ی ورود اصلی. `initBytes` = init segment (از EXT-X-MAP)،
/// `fragmentBytesList` = لیست segmentهای دانلودشده به همون ترتیب پلی‌لیست.
FlatMp4Result remuxFragmentsToFlatMp4({
  required Uint8List initBytes,
  required List<Uint8List> fragmentBytesList,
}) {
  final initBoxes = _Mp4Box.parseTop(initBytes);
  final ftyp = _Mp4Box.find(initBoxes, 'ftyp');
  final moov = _Mp4Box.find(initBoxes, 'moov');
  if (ftyp == null || moov == null) {
    throw Mp4RemuxException('init segment فاقد ftyp یا moov است');
  }

  final moovBoxes = _Mp4Box.parseTop(moov.payload);
  final mvhdBox = _Mp4Box.find(moovBoxes, 'mvhd');
  final trakBox = _Mp4Box.find(moovBoxes, 'trak');
  if (mvhdBox == null || trakBox == null) {
    throw Mp4RemuxException('moov فاقد mvhd یا trak است');
  }

  final movieTimescale = _readTimescale(mvhdBox.payload);

  final trakBoxes = _Mp4Box.parseTop(trakBox.payload);
  final tkhdBox = _Mp4Box.find(trakBoxes, 'tkhd');
  final mdiaBox = _Mp4Box.find(trakBoxes, 'mdia');
  if (tkhdBox == null || mdiaBox == null) {
    throw Mp4RemuxException('trak فاقد tkhd یا mdia است');
  }

  final mdiaBoxes = _Mp4Box.parseTop(mdiaBox.payload);
  final mdhdBox = _Mp4Box.find(mdiaBoxes, 'mdhd');
  final minfBox = _Mp4Box.find(mdiaBoxes, 'minf');
  if (mdhdBox == null || minfBox == null) {
    throw Mp4RemuxException('mdia فاقد mdhd یا minf است');
  }
  final mediaTimescale = _readTimescale(mdhdBox.payload);

  final minfBoxes = _Mp4Box.parseTop(minfBox.payload);
  final stblBox = _Mp4Box.find(minfBoxes, 'stbl');
  if (stblBox == null) throw Mp4RemuxException('minf فاقد stbl است');
  final stblBoxes = _Mp4Box.parseTop(stblBox.payload);
  final stsdBox = _Mp4Box.find(stblBoxes, 'stsd');
  if (stsdBox == null) throw Mp4RemuxException('stbl فاقد stsd است');

  // --- پارس فرگمنت‌ها و ساخت جدول سمپل‌ها ---
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
        throw Mp4RemuxException(
          'سمپل بدون duration/size — tfhd default ناقصه یا trun فلگ لازم رو نداره',
        );
      }
      durations.add(s.duration!);
      sizes.add(s.size!);
    }
  }

  if (durations.isEmpty) {
    throw Mp4RemuxException('هیچ سمپلی از فرگمنت‌ها استخراج نشد');
  }

  final totalDurationMediaTs = durations.fold<int>(0, (a, b) => a + b);
  final totalDurationMovieTs =
      (totalDurationMediaTs / mediaTimescale * movieTimescale).round();

  final sttsBox = _buildStts(durations);
  final stszBox = _buildStsz(sizes);
  final stscBox = _buildStsc(chunkSampleCounts);

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
        continue; // بعد از remux، edit list قدیمی معتبر نیست
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
        continue; // فایل نهایی fragmented نیست، mvex بی‌معنیه
      } else {
        newMoovPayload.add(_Mp4Box.build(b.type, b.payload));
      }
    }
    return _Mp4Box.build('moov', newMoovPayload.toBytes());
  }

  // مرحله‌ی اول: moov با stco placeholder (آفست صفر) فقط برای دونستن اندازه‌ی moov.
  final placeholderStco = _buildStco(List.filled(chunkSampleCounts.length, 0));
  final moovForSizing = buildMoov(placeholderStco);

  final ftypBox = _Mp4Box.build('ftyp', ftyp.payload);
  final mdatDataOffset =
      ftypBox.length + moovForSizing.length + 8; // +8 = هدر mdat

  final chunkOffsets = <int>[];
  int running = mdatDataOffset;
  for (final part in mdatParts) {
    chunkOffsets.add(running);
    running += part.length;
  }
  final finalStco = _buildStco(chunkOffsets);
  final finalMoov = buildMoov(finalStco);

  // چون stco (uint32) هم در placeholder هم در نسخه‌ی نهایی دقیقاً هم‌طوله
  // (مگر فایل >4GB بشه که برای موزیک عملاً پیش نمیاد)، اندازه‌ی moov ثابت
  // می‌مونه و offsetهای محاسبه‌شده معتبرن.
  if (finalMoov.length != moovForSizing.length) {
    throw Mp4RemuxException(
      'اندازه moov بعد از محاسبه‌ی offset واقعی تغییر کرد — احتمالاً فایل >4GB است (نیاز به co64)',
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

// ------------------------- پارس فرگمنت (moof+mdat) -------------------------

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
    throw Mp4RemuxException('یک segment فاقد moof یا mdat است');
  }

  final moofBoxes = _Mp4Box.parseTop(moof.payload);
  final traf = _Mp4Box.find(moofBoxes, 'traf');
  if (traf == null) throw Mp4RemuxException('moof فاقد traf است');
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
    // default-sample-flags (0x000020) رو لازم نداریم (فقط برای stss/sync لازمه)
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

// ------------------------- ساخت باکس‌های stbl -------------------------

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

// ------------------------- patch کردن duration -------------------------

/// برای mvhd و mdhd: هر دو layout یکسان دارن
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

/// tkhd لایه‌بندی متفاوتی داره: creation/modification/track_ID/reserved/duration
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

// ------------------------- helper های عمومی box -------------------------

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
