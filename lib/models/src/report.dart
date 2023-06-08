import 'package:hive/hive.dart';

part 'report.g.dart';

@HiveType(typeId: 1)
class Report {
  Report({
    required this.feel,
    required this.sleepingTime,
    required this.consumedMedicine,
    required this.dateCreated,
  });

  @HiveField(0)
  int feel;

  @HiveField(1)
  int sleepingTime;

  @HiveField(2)
  bool consumedMedicine;

  @HiveField(3)
  DateTime dateCreated;
}
