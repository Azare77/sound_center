import 'package:drift/drift.dart';

mixin TableMixin on Table {
  late final id = integer().autoIncrement()();
  late final createdAt = dateTime().withDefault(currentDateAndTime)();
}
