import 'package:flutter/foundation.dart';

/// کنترلر سراسریِ حالت مالتی‌سلکت.
///
/// چون در هر لحظه فقط یک تب/صفحه قابل مشاهده است (TabBarView فقط صفحه‌ی
/// جاری را build نگه می‌دارد)، نگه‌داشتن state به‌صورت global-static هم
/// کم‌کدترین راه است و هم نیازی به پاس دادن کنترلر جداگانه به هر صفحه ندارد.
/// با تغییر تب یا خروج از حالت انتخاب، state پاک می‌شود.
class MultiSelectController {
  MultiSelectController._();

  static final ValueNotifier<bool> multiSelect = ValueNotifier(false);
  static final ValueNotifier<Set<Object>> selected = ValueNotifier(<Object>{});

  static bool get isActive => multiSelect.value;

  /// فعال کردن حالت مالتی‌سلکت؛ در صورت پاس دادن یک آیتم، همان آیتم هم
  /// بلافاصله انتخاب می‌شود (مناسب برای long-press روی اولین آیتم).
  static void enable([Object? item]) {
    multiSelect.value = true;
    if (item != null) toggle(item);
  }

  static void disable() {
    if (!multiSelect.value && selected.value.isEmpty) return;
    multiSelect.value = false;
    selected.value = <Object>{};
  }

  static void toggle(Object item) {
    final next = Set<Object>.from(selected.value);
    next.contains(item) ? next.remove(item) : next.add(item);
    selected.value = next;
  }

  static bool isSelected(Object item) => selected.value.contains(item);
}
