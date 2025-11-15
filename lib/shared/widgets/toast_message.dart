import 'package:flutter/material.dart';
import 'package:sound_center/core/constants/query_constants.dart';
import 'package:toastification/toastification.dart';

class ToastMessage {
  static void showErrorMessage({
    required String title,
    BuildContext? context,
    String? description,
    Icon? icon,
  }) {
    toastification.show(
      context: context,
      overlayState: NAVIGATOR_KEY.currentState?.overlay,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      title: Text(title),
      description: description != null ? Text(description) : null,
      alignment: Alignment.bottomCenter,
      autoCloseDuration: const Duration(seconds: 2),
      icon: icon,
      borderRadius: BorderRadius.circular(12.0),
      closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
      dragToClose: true,
    );
  }
}
