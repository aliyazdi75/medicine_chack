import 'package:daroo_check/models/index.dart';
import 'package:daroo_check/widgets/custom_slider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:reviews_slider/reviews_slider.dart';

class ReportDialog extends StatefulWidget {
  const ReportDialog({super.key, required this.reportBox});

  final Box<Report> reportBox;

  @override
  ReportDialogState createState() => ReportDialogState();
}

class ReportDialogState extends State<ReportDialog> {
  int _feel = 2;
  int _sleepingTime = 8;
  bool _consumedMedicine = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('امروز بیشتر چه حسی دارید؟'),
        Directionality(
          textDirection: TextDirection.ltr,
          child: ReviewSlider(
            options: const ['عصبانی', 'غمگین', 'مضطرب', 'معمولی', 'شاد'],
            initialValue: _feel,
            onChange: (value) {
              switch (value) {
                case 0:
                  _feel = 3;
                  break;
                case 1:
                  _feel = 0;
                  break;
                case 2:
                  _feel = 1;
                  break;
                case 3:
                  _feel = 2;
                  break;
                case 4:
                  _feel = 4;
                  break;
                default:
                  _feel = 2;
              }
            },
          ),
        ),
        const Text('مجموع ساعت خواب؟'),
        Directionality(
          textDirection: TextDirection.ltr,
          child: CustomSlider(
            onChanged: (value) {
              _sleepingTime = value;
            },
          ),
        ),
        Row(
          children: [
            const Text('داروی خود را مصرف کردید؟'),
            Switch(
              value: _consumedMedicine,
              onChanged: (value) {
                setState(() {
                  _consumedMedicine = value;
                });
              },
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            final now = DateUtils.dateOnly(DateTime.now());
            widget.reportBox.put(
              now.toString(),
              Report(
                feel: _feel,
                sleepingTime: _sleepingTime,
                consumedMedicine: _consumedMedicine,
                dateCreated: DateTime(now.year, now.month, now.day),
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Center(
            child: Text('ثبت'),
          ),
        ),
      ],
    );
  }
}
