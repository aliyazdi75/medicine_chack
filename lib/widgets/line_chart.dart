import 'package:daroo_check/models/index.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum _ChartMode { oneMonth, oneYear }

class LineChartWidget extends StatefulWidget {
  const LineChartWidget({
    super.key,
    required this.chartType,
    required this.dataOneMonth,
    required this.dataOneYear,
  });

  final ChartType chartType;
  final List<FlSpot> dataOneMonth;
  final List<FlSpot> dataOneYear;

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  final gradientColors = [const Color(0xff23b6e6), const Color(0xff02d39a)];
  _ChartMode _chartMode = _ChartMode.oneMonth;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xff232d37),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                right: 18,
                top: 40,
                bottom: 12,
              ),
              child: Column(
                children: [
                  Expanded(child: LineChart(_lineChartData())),
                  widget.chartType == ChartType.mood
                      ? const Text(
                          'غمگین☹️  مضطرب😒  معمولی🙂 عصبانی😡 شاد😁',
                          style: TextStyle(color: Colors.white),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
        Row(
          children: [
            _chartModeButton(
              title: 'یک ماه',
              isSelected: _chartMode == _ChartMode.oneMonth,
              onSetState: () => _chartMode = _ChartMode.oneMonth,
            ),
            _chartModeButton(
              title: 'یکسال',
              isSelected: _chartMode == _ChartMode.oneYear,
              onSetState: () => _chartMode = _ChartMode.oneYear,
            ),
          ],
        ),
      ],
    );
  }

  bool _isOneMonth() => _chartMode == _ChartMode.oneMonth;

  Widget _chartModeButton({
    required String title,
    required bool isSelected,
    required VoidCallback onSetState,
  }) {
    return SizedBox(
      width: 60,
      height: 34,
      child: TextButton(
        onPressed: () {
          setState(() {
            onSetState();
          });
        },
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  String _bottomTitleOneYear(int value) {
    switch (value) {
      case 2:
        return 'فروردین';
      case 4:
        return 'اردیبهشت';
      case 6:
        return 'خرداد';
      case 8:
        return 'تیر';
      case 10:
        return 'مرداد';
      case 12:
        return 'شهریور';
      case 14:
        return 'مهر';
      case 16:
        return 'آبان';
      case 18:
        return 'آذر';
      case 20:
        return 'دی';
      case 22:
        return 'بهمن';
      case 24:
        return 'اسفند';
      default:
        return '';
    }
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 10,
    );
    String text;
    switch (_chartMode) {
      case _ChartMode.oneMonth:
        text = value.toInt().toString();
        break;
      case _ChartMode.oneYear:
        text = _bottomTitleOneYear(value.toInt());
        break;
      default:
        text = value.toInt().toString();
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: _isOneMonth()
          ? Text(text, style: style)
          : RotatedBox(
              quarterTurns: -1,
              child: Text(text, style: style),
            ),
    );
  }

  Widget _leftTitleMood(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontSize: 12,
    );
    String text;
    switch (value.toInt()) {
      case 0:
        text = '☹️';
        break;
      case 1:
        text = '😒';
        break;
      case 2:
        text = '🙂';
        break;
      case 3:
        text = '😡';
        break;
      case 4:
        text = '😁';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  Widget _leftTitleSleep(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontSize: 10,
    );

    return Text(
      value.toInt().toString(),
      style: style,
      textAlign: TextAlign.center,
    );
  }

  Widget _leftTitleMedicine(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontSize: 12,
    );

    return Text(
      value.toInt() == 1 ? 'بله' : 'خیر',
      style: style,
      textAlign: TextAlign.center,
    );
  }

  LineChartData _lineChartData() {
    return LineChartData(
      lineTouchData: LineTouchData(enabled: false),
      gridData: FlGridData(
        show: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 1,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: _isOneMonth() ? 30 : 60,
            getTitlesWidget: _bottomTitleWidgets,
            interval: _isOneMonth() ? 3 : 1,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: widget.chartType == ChartType.mood
                ? _leftTitleMood
                : widget.chartType == ChartType.sleep
                    ? _leftTitleSleep
                    : _leftTitleMedicine,
            reservedSize: 30,
            interval: 1,
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: _isOneMonth() ? -30 : 2,
      maxX: _isOneMonth() ? 0 : 24,
      minY: 0,
      maxY: widget.chartType == ChartType.mood
          ? 4
          : widget.chartType == ChartType.sleep
              ? 12
              : 1,
      lineBarsData: [
        LineChartBarData(
          spots: _isOneMonth() ? widget.dataOneMonth : widget.dataOneYear,
          isCurved: true,
          gradient: LinearGradient(
            colors: [
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
              ColorTween(begin: gradientColors[0], end: gradientColors[1])
                  .lerp(0.2)!,
            ],
          ),
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
                ColorTween(begin: gradientColors[0], end: gradientColors[1])
                    .lerp(0.2)!
                    .withOpacity(0.1),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
