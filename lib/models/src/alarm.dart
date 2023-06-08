import 'package:hive/hive.dart';

part 'alarm.g.dart';

@HiveType(typeId: 2)
class Alarm {
  Alarm({
    required this.id,
    required this.alarmIds,
    required this.name,
    required this.startAt,
    required this.selectedDays,
    required this.periodHourIndex,
    required this.isActive,
  });

  @HiveField(0)
  int id;

  @HiveField(1)
  List<int> alarmIds;

  @HiveField(2)
  String name;

  @HiveField(3)
  DateTime startAt;

  @HiveField(4)
  List<bool> selectedDays;

  @HiveField(5)
  int? periodHourIndex;

  @HiveField(6)
  bool isActive;
}
