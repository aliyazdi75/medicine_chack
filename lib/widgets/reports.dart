import 'package:daroo_check/models/index.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class Reports extends StatelessWidget {
  const Reports({
    super.key,
    required this.reports,
    required this.chartType,
  });

  final List<Report> reports;
  final ChartType chartType;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: reports
          .map(
            (report) => ListTile(
              title: Text(
                  '${report.dateCreated.toJalali().day}-${report.dateCreated.toJalali().month}-${report.dateCreated.toJalali().year}'),
              trailing: chartType == ChartType.mood
                  ? Text(_convertFeel(report.feel))
                  : chartType == ChartType.sleep
                      ? Text('${report.sleepingTime} ساعت')
                      : Text(report.consumedMedicine ? 'بله' : 'خیر'),
            ),
          )
          .toList(),
    );
  }

  String _convertFeel(int feel) {
    switch (feel) {
      case 0:
        return 'غمگین ☹️';
      case 1:
        return 'مضطرب 😒';
      case 2:
        return 'معمولی 🙂';
      case 3:
        return 'عصبانی 😡';
      case 4:
        return 'شاد 😁';
      default:
        return '';
    }
  }
}
