import 'dart:math';

import 'package:daroo_check/main.dart';
import 'package:daroo_check/models/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

class AlarmPage extends StatefulWidget {
  const AlarmPage({super.key, required this.alarmBox});

  final Box<Alarm> alarmBox;

  @override
  AlarmPageState createState() => AlarmPageState();
}

class AlarmPageState extends State<AlarmPage> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.alarmBox.listenable(),
        builder: (context, alarmBox, widget) {
          final alarms = alarmBox.values;
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'یاد آورها',
              ),
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'alarm',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return AlarmDialog(alarmBox: alarmBox);
                  },
                );
              },
              child: const Tooltip(
                message: 'یادآور جدید',
                child: Icon(Icons.add),
              ),
            ),
            body: alarms.isEmpty
                ? const Center(child: Text('یادآوری وجود ندارد!'))
                : ListView.builder(
                    itemCount: alarms.length,
                    itemBuilder: (BuildContext context, int index) {
                      final alarm = alarms.elementAt(index);
                      return ListTile(
                        leading: Text(index.toString()),
                        title: Text(alarm.name),
                        subtitle: Text(
                          alarm.periodHourIndex != null
                              ? _convertHour(alarm.periodHourIndex!)
                              : _convertSelectedDays(alarm.selectedDays),
                        ),
                        trailing: IconButton(
                          tooltip: 'یادآور جدید',
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            for (var alarmId in alarm.alarmIds) {
                              await flutterLocalNotificationsPlugin
                                  .cancel(alarmId);
                            }
                            alarmBox.delete(alarm.id);
                          },
                        ),
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return AlarmDialog(
                                alarmBox: alarmBox,
                                alarm: alarm,
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
          );
        });
  }

  String _convertDay(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return 'شنبه';
      case 1:
        return 'یک شنبه';
      case 2:
        return 'دو شنبه';
      case 3:
        return 'سه شنبه';
      case 4:
        return 'چهار شنبه';
      case 5:
        return 'پنج شنبه';
      case 6:
        return 'جمعه';
      default:
        return 'شنبه';
    }
  }

  String _convertSelectedDays(List<bool> selectedDays) {
    var selectedDaysTitle = '';
    for (int selectedDay = 0;
        selectedDay < selectedDays.length;
        selectedDay++) {
      selectedDaysTitle += _convertDay(selectedDay) +
          (selectedDay == selectedDays.length - 1 ? '' : '، ');
    }
    return selectedDaysTitle;
  }

  String _convertHour(int index) {
    switch (index) {
      case 0:
        return 'شش ساعت';
      case 1:
        return 'هشت ساعت';
      case 2:
        return 'دوازده ساعت';
      case 3:
        return 'روزانه';
      default:
        return 'روزانه';
    }
  }
}

class AlarmDialog extends StatefulWidget {
  const AlarmDialog({
    super.key,
    required this.alarmBox,
    this.alarm,
  });

  final Box<Alarm> alarmBox;
  final Alarm? alarm;

  @override
  State<AlarmDialog> createState() => _AlarmDialogState();
}

class _AlarmDialogState extends State<AlarmDialog> with RestorationMixin {
  late RestorableRouteFuture<TimeOfDay> _restorableTimePickerRouteFuture;
  late TextEditingController _nameTextController;
  late List<bool> _selectedDays;
  late int? _hourPeriod;
  final formKey = GlobalKey<FormState>();
  RestorableTimeOfDay _fromTime = RestorableTimeOfDay(
    const TimeOfDay(hour: 8, minute: 0),
  );

  void _selectTime(TimeOfDay selectedTime) {
    if (selectedTime != _fromTime.value) {
      setState(() {
        _fromTime.value = selectedTime;
      });
    }
  }

  static Route<TimeOfDay> _timePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    final args = arguments as List<Object>;
    final initialTime = TimeOfDay(
      hour: args[0] as int,
      minute: args[1] as int,
    );

    return DialogRoute<TimeOfDay>(
      context: context,
      builder: (context) {
        return TimePickerDialog(
          restorationId: 'time_picker_dialog',
          initialTime: initialTime,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _nameTextController = TextEditingController(text: widget.alarm?.name ?? '');
    _selectedDays = widget.alarm?.selectedDays ?? List<bool>.filled(7, true);
    _hourPeriod = widget.alarm?.periodHourIndex ?? 3;
    _fromTime = RestorableTimeOfDay(
      TimeOfDay(
        hour: widget.alarm?.startAt.hour ?? 8,
        minute: widget.alarm?.startAt.minute ?? 0,
      ),
    );
    _restorableTimePickerRouteFuture = RestorableRouteFuture<TimeOfDay>(
      onComplete: _selectTime,
      onPresent: (navigator, arguments) => navigator.restorablePush(
        _timePickerRoute,
        arguments: [_fromTime.value.hour, _fromTime.value.minute],
      ),
    );
  }

  @override
  String get restorationId => 'picker_demo';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_fromTime, 'from_time');
    registerForRestoration(
      _restorableTimePickerRouteFuture,
      'time_picker_route',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              maxLines: 1,
              keyboardType: TextInputType.text,
              controller: _nameTextController,
              decoration: const InputDecoration(hintText: 'اسم دارو'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'لطفا اسم دارو را وارد کنید';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          FormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (val) {
              if (!_selectedDays.contains(true)) {
                return 'حداقل یک روز را انتخاب کنید!';
              }
              return null;
            },
            builder: (formFieldState) {
              return Column(
                children: [
                  Text(
                    formFieldState.hasError && formFieldState.errorText != null
                        ? formFieldState.errorText!
                        : 'تکرار دارو:',
                    style: TextStyle(
                      color: formFieldState.hasError ? Colors.red : null,
                    ),
                  ),
                  _DaysHoursButtons(
                    selectedDays: _selectedDays,
                    hourPeriod: _hourPeriod,
                    onDayChanged: (selectedDays) {
                      setState(() {
                        _selectedDays = selectedDays;
                        formFieldState.didChange(formFieldState);
                      });
                    },
                    onHourChanged: (index) {
                      setState(() {
                        _hourPeriod = index;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          const Text('ساعت مصرف دارو:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => _restorableTimePickerRouteFuture.present(),
                child: Text(_fromTime.value.minute.toString()),
              ),
              OutlinedButton(
                onPressed: () => _restorableTimePickerRouteFuture.present(),
                child: Text(_fromTime.value.hour.toString()),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final navigator = Navigator.of(context);
                  if (widget.alarm != null) {
                    for (var alarmId in widget.alarm!.alarmIds) {
                      await flutterLocalNotificationsPlugin.cancel(alarmId);
                    }
                  }
                  _scheduleAllNotifications(widget.alarm?.id ?? _randomId());
                  navigator.pop();
                }
              },
              child: const Center(
                child: Text('ثبت'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _randomId() => Random().nextInt(pow(2, 31) as int);

  Future<void> _scheduleAllNotifications(int alarmId) async {
    var alarmIds = <int>[];
    final startAt = DateTime.now().copyWith(
      hour: _fromTime.value.hour,
      minute: _fromTime.value.minute,
    );
    // alarmIds = List.generate(2, (index) => _randomId());
    // _scheduleWeeklyNotification(0, alarmIds[0], 16, 39);
    // _scheduleWeeklyNotification(0, alarmIds[1], 16, 40);
    for (int dayIndex = 0; dayIndex < _selectedDays.length; dayIndex++) {
      if (_selectedDays[dayIndex]) {
        switch (_hourPeriod) {
          case 0:
            alarmIds = List.generate(4, (index) => _randomId());
            _scheduleWeeklyNotification(dayIndex, alarmIds[0],
                _fromTime.value.hour, _fromTime.value.minute);
            _scheduleWeeklyNotification(dayIndex, alarmIds[1],
                _fromTime.value.hour + 6, _fromTime.value.minute);
            _scheduleWeeklyNotification(dayIndex, alarmIds[2],
                _fromTime.value.hour + 12, _fromTime.value.minute);
            _scheduleWeeklyNotification(dayIndex, alarmIds[3],
                _fromTime.value.hour + 18, _fromTime.value.minute);
            break;
          case 1:
            alarmIds = List.generate(3, (index) => _randomId());
            _scheduleWeeklyNotification(dayIndex, alarmIds[0],
                _fromTime.value.hour, _fromTime.value.minute);
            _scheduleWeeklyNotification(dayIndex, alarmIds[1],
                _fromTime.value.hour + 8, _fromTime.value.minute);
            _scheduleWeeklyNotification(dayIndex, alarmIds[2],
                _fromTime.value.hour + 16, _fromTime.value.minute);
            break;
          case 2:
            alarmIds = List.generate(2, (index) => _randomId());
            _scheduleWeeklyNotification(dayIndex, alarmIds[0],
                _fromTime.value.hour, _fromTime.value.minute);
            _scheduleWeeklyNotification(dayIndex, alarmIds[1],
                _fromTime.value.hour + 12, _fromTime.value.minute);
            break;
          case 3:
          default:
            alarmIds = List.generate(1, (index) => _randomId());
            _scheduleWeeklyNotification(dayIndex, alarmIds[0],
                _fromTime.value.hour, _fromTime.value.minute);
        }
      }
    }
    widget.alarmBox.put(
      alarmId,
      Alarm(
        id: alarmId,
        alarmIds: alarmIds,
        name: _nameTextController.text,
        startAt: startAt,
        selectedDays: _selectedDays,
        periodHourIndex: _hourPeriod,
        isActive: true,
      ),
    );
  }

  Future<void> _scheduleWeeklyNotification(
    int dayIndex,
    int alarmId,
    int hour,
    int minute,
  ) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      alarmId,
      'یاد آور دارو',
      _nameTextController.text,
      _nextInstanceOfDay(dayIndex, hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'Daroo Check Notification',
          'Daroo Check Alarm',
          channelDescription: 'Alarm for consuming medicines',
          priority: Priority.max,
          importance: Importance.max,
          fullScreenIntent: true,
          sound: RawResourceAndroidNotificationSound('audio'),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfDaily(int dayIndex, int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  int _convertDay(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return DateTime.saturday;
      case 1:
        return DateTime.sunday;
      case 2:
        return DateTime.monday;
      case 3:
        return DateTime.tuesday;
      case 4:
        return DateTime.wednesday;
      case 5:
        return DateTime.thursday;
      case 6:
        return DateTime.friday;
      default:
        return DateTime.saturday;
    }
  }

  tz.TZDateTime _nextInstanceOfDay(int dayIndex, int hour, int minute) {
    tz.TZDateTime scheduledDate = _nextInstanceOfDaily(dayIndex, hour, minute);
    while (scheduledDate.weekday != _convertDay(dayIndex)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

class _DaysHoursButtons extends StatefulWidget {
  const _DaysHoursButtons({
    required this.selectedDays,
    required this.hourPeriod,
    required this.onDayChanged,
    required this.onHourChanged,
  });

  final List<bool> selectedDays;
  final int? hourPeriod;
  final ValueChanged<List<bool>> onDayChanged;
  final ValueChanged<int?> onHourChanged;

  @override
  _DaysHoursButtonsState createState() => _DaysHoursButtonsState();
}

class _DaysHoursButtonsState extends State<_DaysHoursButtons>
    with RestorationMixin {
  late List<RestorableBool> isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = [
      RestorableBool(widget.selectedDays[0]),
      RestorableBool(widget.selectedDays[1]),
      RestorableBool(widget.selectedDays[2]),
      RestorableBool(widget.selectedDays[3]),
      RestorableBool(widget.selectedDays[4]),
      RestorableBool(widget.selectedDays[5]),
      RestorableBool(widget.selectedDays[6]),
    ];
  }

  @override
  String get restorationId => 'days_button';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(isSelected[0], 'sat');
    registerForRestoration(isSelected[1], 'sun');
    registerForRestoration(isSelected[2], 'mon');
    registerForRestoration(isSelected[3], 'tue');
    registerForRestoration(isSelected[4], 'wed');
    registerForRestoration(isSelected[5], 'thu');
    registerForRestoration(isSelected[6], 'fri');
  }

  @override
  void dispose() {
    for (final restorableBool in isSelected) {
      restorableBool.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ToggleButtons(
          onPressed: (index) {
            setState(() {
              isSelected[index].value = !isSelected[index].value;
              widget.onDayChanged(isSelected.map((e) => e.value).toList());
              if (!isSelected.contains(RestorableBool(false))) {
                widget.onHourChanged(null);
              }
            });
          },
          isSelected: isSelected.map((element) => element.value).toList(),
          children: const [
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('شنبه'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('۱شنبه'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('۲شنبه'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('۳شنبه'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('۴شنبه'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('۵شنبه'),
            ),
            Padding(
              padding: EdgeInsets.all(5.0),
              child: Text('جمعه'),
            ),
          ],
        ),
        if (!isSelected.contains(RestorableBool(false))) ...[
          const Text('تکرار ساعت دارو:'),
          _HoursButtons(
            hourPeriod: widget.hourPeriod,
            onHourChanged: widget.onHourChanged,
          ),
        ],
      ],
    );
  }
}

class _HoursButtons extends StatefulWidget {
  const _HoursButtons({
    required this.hourPeriod,
    required this.onHourChanged,
  });

  final int? hourPeriod;
  final ValueChanged<int?> onHourChanged;

  @override
  _HoursButtonsState createState() => _HoursButtonsState();
}

class _HoursButtonsState extends State<_HoursButtons> with RestorationMixin {
  late List<RestorableBool> isSelected;

  @override
  void initState() {
    super.initState();
    isSelected = [
      RestorableBool(widget.hourPeriod == 0),
      RestorableBool(widget.hourPeriod == 1),
      RestorableBool(widget.hourPeriod == 2),
      RestorableBool(widget.hourPeriod == 3),
    ];
  }

  @override
  String get restorationId => 'hours_button';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(isSelected[0], 'six_hours');
    registerForRestoration(isSelected[1], 'eight_hours');
    registerForRestoration(isSelected[2], 'twelve_hours');
    registerForRestoration(isSelected[3], 'twenty_four_hours');
  }

  @override
  void dispose() {
    for (final restorableBool in isSelected) {
      restorableBool.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      onPressed: (index) {
        if (isSelected[index].value) return;
        setState(() {
          isSelected[index].value = true;
          widget.onHourChanged(index);
          for (int i = 0; i < isSelected.length; i++) {
            if (i == index) {
              continue;
            }
            isSelected[i].value = false;
          }
        });
      },
      isSelected: isSelected.map((element) => element.value).toList(),
      children: const [
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text('۶ ساعت یکبار'),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text('۸ ساعت یکبار'),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text('۱۲ ساعت یکبار'),
        ),
        Padding(
          padding: EdgeInsets.all(5.0),
          child: Text('۲۴ ساعت یکبار'),
        ),
      ],
    );
  }
}
