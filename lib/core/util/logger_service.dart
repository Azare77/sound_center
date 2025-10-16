import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LoggerService {
  static File? _logFile;

  static Future<void> init() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      debugPrint('Storage permission not granted');
      return;
    }

    // مسیر مجاز مخصوص اپ
    final dir = await getExternalStorageDirectory();

    final logDir = Directory('${dir!.path}/AAP');
    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    final path = '${logDir.path}/error_logs.txt';
    _logFile = File(path);

    if (!await _logFile!.exists()) {
      await _logFile!.create(recursive: true);
    }

    debugPrint('✅ Log file initialized at: $path');
  }

  static Future<void> log(String message) async {
    try {
      if (_logFile == null) await init();

      final now = DateTime.now().toIso8601String();
      final logMessage = '[$now] $message\n';
      await _logFile!.writeAsString(logMessage, mode: FileMode.append);
    } catch (_) {
      return;
    }
  }

  static Future<String?> getLogFilePath() async {
    if (_logFile == null) await init();
    return _logFile?.path;
  }
}
