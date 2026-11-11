import 'dart:async';

import 'package:flutter/services.dart';

class ScopedStorageWriter {
  static const MethodChannel _channel = MethodChannel('scoped_storage_writer');
  static const Duration _timeout = Duration(seconds: 30);

  /// فقط روی Android 11+ معنا دارد؛ روی نسخه‌های پایین‌تر همیشه true برمی‌گرداند
  /// چون اجازه در لحظه‌ی writeBytes گرفته می‌شود، نه قبل از آن.
  Future<bool> requestWriteAccess(String uri) async {
    try {
      return await _channel
              .invokeMethod<bool>('requestWriteAccess', {'uri': uri})
              .timeout(_timeout, onTimeout: () => false) ??
          false;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> writeBytes(String uri, Uint8List bytes) async {
    try {
      return await _channel
              .invokeMethod<bool>('writeBytes', {'uri': uri, 'bytes': bytes})
              .timeout(_timeout, onTimeout: () => false) ??
          false;
    } on PlatformException {
      return false;
    }
  }
}
