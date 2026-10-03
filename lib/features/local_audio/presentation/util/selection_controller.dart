import 'package:material_ui/material_ui.dart';

class LocalAudioSelectionController extends ChangeNotifier {
  VoidCallback? _exitCallback;
  bool _multipleSelect = false;

  bool get multipleSelect => _multipleSelect;

  void setMultipleSelect(bool value, VoidCallback exitCallback) {
    _multipleSelect = value;

    if (value) {
      _exitCallback = exitCallback;
    } else if (_exitCallback == exitCallback) {
      _exitCallback = null;
    }

    notifyListeners();
  }

  void exitMultipleSelect() {
    _exitCallback?.call();
  }

  void unregister(VoidCallback exitCallback) {
    if (_exitCallback == exitCallback) {
      _exitCallback = null;
      _multipleSelect = false;
    }
  }
}

class LocalAudioSelectionScope
    extends InheritedNotifier<LocalAudioSelectionController> {
  const LocalAudioSelectionScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static LocalAudioSelectionController of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LocalAudioSelectionScope>()!
        .notifier!;
  }
}
