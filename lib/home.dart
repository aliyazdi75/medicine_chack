import 'package:daroo_check/widgets/alarm_page.dart';
import 'package:daroo_check/widgets/report_dialog.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/index.dart';
import 'widgets/chart.dart';
import 'widgets/reports.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.personName,
    required this.alarmBox,
    required this.reportBox,
  });

  final String personName;
  final Box<Alarm> alarmBox;
  final Box<Report> reportBox;

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int _selectedIndex = 0;
  bool _useSample = true;

  @override
  Widget build(BuildContext context) {
    final chartType = _selectedIndex == 0
        ? ChartType.mood
        : _selectedIndex == 1
            ? ChartType.sleep
            : ChartType.medicine;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'خوش آمدی ${widget.personName}',
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.accessible,
              color: _useSample ? Colors.white : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _useSample = !_useSample;
              });
            },
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            FloatingActionButton(
              heroTag: 'alarm',
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        AlarmPage(alarmBox: widget.alarmBox),
                  ),
                );
              },
              child: const Tooltip(
                message: 'یادآور دارو',
                child: Icon(
                  Icons.alarm,
                ),
              ),
            ),
            const SizedBox(height: 15),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                builder: (context) {
                  return ReportDialog(reportBox: widget.reportBox);
                },
              );
            },
            child: const Tooltip(
              message: 'گزارش وضعیت',
              child: Icon(
                Icons.add,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'احوال',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'خواب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_information),
            label: 'دارو',
          ),
        ],
      ),
      body: Center(
        child: ValueListenableBuilder(
          valueListenable: widget.reportBox.listenable(),
          builder: (context, reportBox, widget) {
            final reports = reportBox.values.toList();
            return reports.isEmpty && !_useSample
                ? const Text(
                    'گزارشی ثبت نشده است',
                  )
                : Column(
                    children: [
                      Chart(
                        reports: _useSample ? samples : reports,
                        chartType: chartType,
                      ),
                      Expanded(
                        child: Reports(
                          reports: _useSample ? samples : reports,
                          chartType: chartType,
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }
}

final samples = [
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 1, 1),
  ),
  Report(
    feel: 4,
    sleepingTime: 8,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 1, 2),
  ),
  Report(
    feel: 3,
    sleepingTime: 6,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 1, 5),
  ),
  Report(
    feel: 0,
    sleepingTime: 7,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 2, 10),
  ),
  Report(
    feel: 3,
    sleepingTime: 7,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 2, 15),
  ),
  Report(
    feel: 1,
    sleepingTime: 6,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 2, 23),
  ),
  Report(
    feel: 2,
    sleepingTime: 6,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 2, 30),
  ),
  Report(
    feel: 2,
    sleepingTime: 5,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 3, 5),
  ),
  Report(
    feel: 3,
    sleepingTime: 11,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 3, 17),
  ),
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 1),
  ),
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 2),
  ),
  Report(
    feel: 2,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 4),
  ),
  Report(
    feel: 3,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 6),
  ),
  Report(
    feel: 2,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 8),
  ),
  Report(
    feel: 2,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 10),
  ),
  Report(
    feel: 4,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 12),
  ),
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 14),
  ),
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 16),
  ),
  Report(
    feel: 0,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 18),
  ),
  Report(
    feel: 4,
    sleepingTime: 8,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 4, 20),
  ),
  Report(
    feel: 1,
    sleepingTime: 8,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 4, 22),
  ),
  Report(
    feel: 1,
    sleepingTime: 8,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 4, 24),
  ),
  Report(
    feel: 2,
    sleepingTime: 8,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 4, 26),
  ),
  Report(
    feel: 1,
    sleepingTime: 6,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 4, 27),
  ),
  Report(
    feel: 2,
    sleepingTime: 6,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 5, 1),
  ),
  Report(
    feel: 4,
    sleepingTime: 6,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 5, 2),
  ),
  Report(
    feel: 0,
    sleepingTime: 6,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 5, 3),
  ),
  Report(
    feel: 3,
    sleepingTime: 6,
    consumedMedicine: false,
    dateCreated: DateTime(2023, 5, 4),
  ),
  Report(
    feel: 1,
    sleepingTime: 7,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 5, 5),
  ),
  Report(
    feel: 2,
    sleepingTime: 7,
    consumedMedicine: true,
    dateCreated: DateTime(2023, 5, 6),
  ),
  Report(
    feel: 3,
    sleepingTime: 8,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 6, 14),
  ),
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 6, 27),
  ),
  Report(
    feel: 0,
    sleepingTime: 6,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 7, 1),
  ),
  Report(
    feel: 4,
    sleepingTime: 4,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 7, 26),
  ),
  Report(
    feel: 3,
    sleepingTime: 8,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 8, 9),
  ),
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 8, 19),
  ),
  Report(
    feel: 4,
    sleepingTime: 10,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 9, 19),
  ),
  Report(
    feel: 1,
    sleepingTime: 9,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 9, 29),
  ),
  Report(
    feel: 3,
    sleepingTime: 8,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 10, 13),
  ),
  Report(
    feel: 3,
    sleepingTime: 8,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 10, 30),
  ),
  Report(
    feel: 2,
    sleepingTime: 7,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 11, 7),
  ),
  Report(
    feel: 2,
    sleepingTime: 4,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 11, 20),
  ),
  Report(
    feel: 1,
    sleepingTime: 5,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 12, 3),
  ),
  Report(
    feel: 0,
    sleepingTime: 4,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 12, 7),
  ),
  Report(
    feel: 1,
    sleepingTime: 5,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 12, 11),
  ),
  Report(
    feel: 3,
    sleepingTime: 7,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 12, 17),
  ),
  Report(
    feel: 1,
    sleepingTime: 5,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 12, 20),
  ),
  Report(
    feel: 3,
    sleepingTime: 6,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 12, 22),
  ),
  Report(
    feel: 2,
    sleepingTime: 5,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 12, 26),
  ),
  Report(
    feel: 4,
    sleepingTime: 7,
    consumedMedicine: true,
    dateCreated: DateTime(2022, 12, 29),
  ),
  Report(
    feel: 4,
    sleepingTime: 6,
    consumedMedicine: false,
    dateCreated: DateTime(2022, 12, 30),
  ),
];
