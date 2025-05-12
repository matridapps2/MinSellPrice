import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LineChart extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  LineChart({Key? key, required this.data}) : super(key: key);
  final List<ChartData> data;

  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends State<LineChart> {
  late List<ChartData> data;
  late TooltipBehavior _tooltip;

  @override
  void initState() {
    setState(() {
      data = widget.data;
    });
    _tooltip = TooltipBehavior(enable: true,duration: 4,activationMode: ActivationMode.singleTap);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: Colors.white,
        // height: MediaQuery.of(context).size.width * .6,
        child: SfCartesianChart(
            primaryXAxis: CategoryAxis(
              labelStyle: GoogleFonts.openSans(
                color: Colors.black,
                fontSize: 10,
              ),
            ),
            primaryYAxis: NumericAxis(
              labelStyle: GoogleFonts.openSans(
                color: Colors.black,
                fontSize: 10,
              ),

            ),
            tooltipBehavior: _tooltip,
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(3),topRight: Radius.circular(4)),
                  width: .4,
                  // spacing: 2,
                  dataSource: data,
                  xAxisName: 'Vendor Name',
                  yAxisName: 'Vendor Price',
                  xValueMapper: (ChartData data, _) => data.x??'',
                  yValueMapper: (ChartData data, _) => data.y??0.0,
                  name: 'Competitor Price',
                  color: const Color.fromRGBO(8, 142, 255, 1))
            ]),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}
