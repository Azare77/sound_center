import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class MetadataExtractor {
  Future<AudioMetadata?> readAudioMetadataFromUrl(String url) async {
    final lowerUrl = url.toLowerCase();

    if (lowerUrl.endsWith('.mp3')) {
      return await _readMetadataFromUrl(url); // تابع قبلی MP3 که داشتیم
    } else if (lowerUrl.endsWith('.flac')) {
      return await _readFlacMetadataFromUrl(url); // تابع FLAC که قبلاً دادم
    } else if (lowerUrl.endsWith('.ogg') || lowerUrl.endsWith('.opus')) {
      return await _readOggMetadataFromUrl(url); // تابع جدید بالا
    } else {
      debugPrint('❌ فرمت فایل پشتیبانی نمی‌شود: $url');
      return null;
    }
  }

  Future<AudioMetadata?> _readMetadataFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      // مرحله ۱: فقط ۱۰ بایت اول رو بگیر تا چک کنیم ID3v2 داریم یا نه
      final headerResponse = await http.get(
        uri,
        headers: {'Range': 'bytes=0-9'},
      );

      if (headerResponse.statusCode != 206) {
        debugPrint(
          'Range Request کار نکرد - Status: ${headerResponse.statusCode}',
        );
        return null;
      }

      final headerBytes = headerResponse.bodyBytes;
      debugPrint('هدر اولیه دانلود شد: ${headerBytes.length} بایت');

      // چک کردن وجود ID3v2
      if (headerBytes.length < 10 ||
          headerBytes[0] != 0x49 || // 'I'
          headerBytes[1] != 0x44 || // 'D'
          headerBytes[2] != 0x33) {
        // '3'
        debugPrint(
          'ID3v2 در ابتدای فایل پیدا نشد (ممکنه ID3v1 یا بدون تگ باشه)',
        );
        // اگر می‌خوای ادامه بدی، اینجا می‌تونی ۵۰KB بگیری یا null برگردونی
        return null;
      }

      // محاسبه اندازه دقیق تگ ID3v2 (فرمول استاندارد)
      final sizeBytes = headerBytes.sublist(6, 10);
      int tagSize = 0;
      for (int i = 0; i < 4; i++) {
        tagSize = (tagSize << 7) | (sizeBytes[i] & 0x7F);
      }
      tagSize += 10; // خود هدر ۱۰ بایتی

      debugPrint('اندازه تگ ID3v2: $tagSize بایت');

      // مرحله ۲: فقط به اندازه تگ + حاشیه کوچک دانلود کن (برای کاور و فریم‌های اضافی)
      final neededBytes =
          tagSize + 32768; // ۳۲ کیلوبایت حاشیه (کافی برای اکثر کاورها)

      final metadataResponse = await http.get(
        uri,
        headers: {'Range': 'bytes=0-${neededBytes - 1}'},
      );

      if (metadataResponse.statusCode != 206) {
        debugPrint('خطا در دانلود متادیتا');
        return null;
      }

      final audioBytes = metadataResponse.bodyBytes;
      debugPrint(
        '✅ دانلود واقعی برای متادیتا: ${audioBytes.length} بایت',
      ); // باید خیلی کمتر از کل فایل باشه

      // مرحله ۳: نوشتن در فایل موقتی و خواندن متادیتا
      final tempFile = File(
        '${Directory.systemTemp.path}/temp_meta_${DateTime.now().millisecondsSinceEpoch}.mp3',
      );

      await tempFile.writeAsBytes(audioBytes);

      // getImage: false برای سرعت بیشتر (اگر کاور نیاز نداری)
      final metadata = readMetadata(tempFile, getImage: true);

      await tempFile.delete(); // پاک کردن فایل موقتی

      debugPrint('عنوان: ${metadata.title}');
      debugPrint('آرتیست: ${metadata.artist}');
      debugPrint('آلبوم: ${metadata.album}');
      debugPrint('مدت زمان: ${metadata.duration}');
      debugPrint('تعداد تصویر: ${metadata.pictures.length}');

      return metadata;
    } catch (e, stack) {
      debugPrint('خطای کلی: $e');
      debugPrint(stack.toString());
      return null;
    }
  }

  /// فقط برای فایل‌های FLAC
  Future<AudioMetadata?> _readFlacMetadataFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      // برای FLAC معمولاً ۱۲۸ کیلوبایت اول کافیه (STREAMINFO + Vorbis + Picture)
      // اگر کاور بزرگ باشه ممکنه بیشتر نیاز باشه
      const int maxBytesForFlac = 256 * 1024; // ۲۵۶ کیلوبایت (خیلی ایمن)

      final response = await http.get(
        uri,
        headers: {'Range': 'bytes=0-${maxBytesForFlac - 1}'},
      );

      if (response.statusCode != 206) {
        debugPrint(
          '❌ Range Request برای FLAC کار نکرد (Status: ${response.statusCode})',
        );
        return null;
      }

      final bytes = response.bodyBytes;
      debugPrint(
        '✅ دانلود برای FLAC: ${bytes.length} بایت (${(bytes.length / 1024).toStringAsFixed(1)} KB)',
      );

      // چک اولیه که واقعاً FLAC باشه
      if (bytes.length < 4 ||
          bytes[0] != 0x66 ||
          bytes[1] != 0x4C ||
          bytes[2] != 0x61 ||
          bytes[3] != 0x43) {
        // "fLaC"
        debugPrint('❌ این فایل FLAC نیست');
        return null;
      }

      final tempFile = File(
        '${Directory.systemTemp.path}/temp_flac_${DateTime.now().millisecondsSinceEpoch}.flac',
      );
      await tempFile.writeAsBytes(bytes);

      final metadata = readMetadata(tempFile, getImage: true);

      await tempFile.delete();

      debugPrint('\n✅ متادیتای FLAC خوانده شد:');
      debugPrint('عنوان     : ${metadata.title ?? "نامشخص"}');
      debugPrint('آرتیست    : ${metadata.artist ?? "نامشخص"}');
      debugPrint('آلبوم     : ${metadata.album ?? "نامشخص"}');
      debugPrint(
        'کاور       : ${metadata.pictures.isNotEmpty ? "دارد" : "ندارد"}',
      );

      return metadata;
    } catch (e) {
      debugPrint('خطا در خواندن FLAC: $e');
      return null;
    }
  }

  /// خواندن متادیتا از فایل‌های OGG / Opus
  Future<AudioMetadata?> _readOggMetadataFromUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      // برای OGG معمولاً ۱۲۸ تا ۲۵۶ کیلوبایت اول کافی است
      // (شامل Identification header + Comment header + ممکنه Picture)
      const int safeBytesForOgg = 256 * 1024; // ۲۵۶ کیلوبایت (خیلی ایمن)

      final response = await http.get(
        uri,
        headers: {'Range': 'bytes=0-${safeBytesForOgg - 1}'},
      );

      if (response.statusCode != 206) {
        debugPrint(
          '❌ Range Request برای OGG کار نکرد (Status: ${response.statusCode})',
        );
        return null;
      }

      final bytes = response.bodyBytes;
      debugPrint(
        '✅ دانلود برای OGG: ${bytes.length} بایت (${(bytes.length / 1024).toStringAsFixed(1)} KB)',
      );

      // چک اولیه که فایل OGG باشه
      if (bytes.length < 4 ||
          bytes[0] != 0x4F ||
          bytes[1] != 0x67 ||
          bytes[2] != 0x67 ||
          bytes[3] != 0x53) {
        // "OggS"
        debugPrint('❌ این فایل OGG نیست');
        return null;
      }

      // ایجاد فایل موقتی
      final tempFile = File(
        '${Directory.systemTemp.path}/temp_ogg_${DateTime.now().millisecondsSinceEpoch}.ogg',
      );
      await tempFile.writeAsBytes(bytes);

      // خواندن متادیتا (پکیج خودش Vorbis Comment رو هندل می‌کنه)
      final metadata = readMetadata(tempFile, getImage: true);

      await tempFile.delete();

      debugPrint('\n✅ متادیتای OGG با موفقیت خوانده شد:');
      debugPrint('عنوان     : ${metadata.title ?? "نامشخص"}');
      debugPrint('آرتیست    : ${metadata.artist ?? "نامشخص"}');
      debugPrint('آلبوم     : ${metadata.album ?? "نامشخص"}');
      debugPrint(
        'کاور       : ${metadata.pictures.isNotEmpty ? "دارد (${metadata.pictures.length} تصویر)" : "ندارد"}',
      );

      return metadata;
    } catch (e) {
      debugPrint('❌ خطا در خواندن متادیتای OGG: $e');
      return null;
    }
  }
}
