import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

enum PermissionType { storage, notification, audio, manageExternalStorage }

class PermissionHandler {
  // 1. تعریف نمونه singleton
  static final PermissionHandler _instance = PermissionHandler._internal();

  // 2. سازنده خصوصی
  PermissionHandler._internal();

  // 3. سازنده factory برای برگردوندن همون instance
  factory PermissionHandler() {
    return _instance;
  }

  Future<bool> checkPermission(PermissionType type) async {
    if (kIsWeb || Platform.isLinux) {
      return true;
    }
    final permission = _mapPermission(type);
    return await permission.status.isGranted;
  }

  Future<bool> requestPermission(PermissionType type) async {
    if (kIsWeb || Platform.isLinux) {
      return true;
    }
    final permission = _mapPermission(type);
    final result = await permission.request();
    return result.isGranted;
  }

  Permission _mapPermission(PermissionType type) {
    switch (type) {
      case PermissionType.storage:
        return Permission.storage;
      case PermissionType.notification:
        return Permission.notification;
      case PermissionType.audio:
        return Permission.audio;
      case PermissionType.manageExternalStorage:
        return Permission.manageExternalStorage;
    }
  }
}
