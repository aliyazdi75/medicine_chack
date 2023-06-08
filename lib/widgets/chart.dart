import 'package:daroo_check/models/index.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'line_chart.dart';

class _MeanMonth {
  _MeanMonth(this.dateTime, this.mean);

  final DateTime dateTime;
  final double mean;
}

class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.reports,
    required this.chartType,
  });

  final List<Report> reports;
  final ChartType chartType;

  @override
  Widget build(BuildContext context) {
    return LineChartWidget(
      chartType: chartType,
      dataOneMonth: reports
          .where((report) => (DateTime.now().difference(report.dateCreated) <
              const Duration(days: 31)))
          .map((report) => FlSpot(
              report.dateCreated.difference(DateTime.now()).inDays.toDouble(),
              _dataType(report)))
          .toList(),
      dataOneYear: _yearToMeanMonth(reports
              .where((report) =>
                  (DateTime.now().difference(report.dateCreated) <
                      const Duration(days: 366)))
              .toList())
          .map((meanReport) => FlSpot(
              (meanReport.dateTime.month.toDouble() * 2),
              meanReport.mean.toDouble()))
          .toList(),
    );
  }

  double _dataType(Report report) {
    if (chartType == ChartType.mood) {
      return report.feel.toDouble();
    } else if (chartType == ChartType.sleep) {
      return report.sleepingTime.toDouble();
    } else {
      if (report.consumedMedicine) {
        return 1;
      } else {
        return 0;
      }
    }
  }

  List<_MeanMonth> _yearToMeanMonth(List<Report> reports) {
    final meanMonths = List<_MeanMonth>.empty(growable: true);
    int currentMonth = 0;
    for (var report in reports) {
      if (currentMonth == report.dateCreated.toJalali().month) {
        continue;
      }
      currentMonth = report.dateCreated.toJalali().month;
      final mean = _dataMean(reports
          .where(
              (report) => report.dateCreated.toJalali().month == currentMonth)
          .map((report) => _dataType(report))
          .toList());
      meanMonths.add(_MeanMonth(report.dateCreated, mean));
    }
    return meanMonths;
  }

  double _dataMean(List<double> data) {
    var sum = data.reduce((previousValue, element) => previousValue + element);
    return sum / data.length;
  }
}
