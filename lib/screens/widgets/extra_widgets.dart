import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minsellprice/size.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

List<Color> get getColorsList => [
      Colors.black12.withOpacity(.3),
      Colors.grey.withOpacity(.3),
    ]..shuffle();

List<Alignment> get getAlignments => [
      Alignment.bottomLeft,
      Alignment.bottomRight,
      Alignment.topRight,
      Alignment.topLeft,
    ];

// ignore: camel_case_types
class AnimatedGradiantContainer extends StatefulWidget {
  const AnimatedGradiantContainer(
      {super.key, required this.width, required this.height});

  final double width, height;

  @override
  State<AnimatedGradiantContainer> createState() =>
      _AnimatedGradiantContainerState();
}

// ignore: camel_case_types
class _AnimatedGradiantContainerState extends State<AnimatedGradiantContainer> {
  var counter = 0;

  late Timer timer;

  /// We will animate the gradient every 5 seconds
  _startBgColorAnimationTimer() {
    if (mounted) {
      ///Animating for the first time.
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        counter++;
        setState(() {});
      });

      const interval = Duration(seconds: 2);
      timer = Timer.periodic(
        interval,
        (Timer timer) {
          counter++;
          setState(() {});
        },
      );
    }
  }

  @override
  void initState() {
    _startBgColorAnimationTimer();
    // TODO: implement initState

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: getAlignments[counter % getAlignments.length],
          end: getAlignments[(counter + 2) % getAlignments.length],
          colors: getColorsList,
          tileMode: TileMode.clamp,
        ),
        borderRadius: BorderRadius.circular(10),
        // color: Colors
        //     .black
        //     .withOpacity(
        //   .2,
        // ),
      ),
      duration: const Duration(seconds: 4),
    );
  }
}

class DonutChart extends StatelessWidget {
  DonutChart({Key? key, required this.chartData}) : super(key: key);
  final List<ChartData> chartData;

  late CircularSeriesController controller;

  void initController(CircularSeriesController controller) {
    this.controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SfCircularChart(
              // title: ChartTitle(
              //     text: 'Competitor Chart',
              //     textStyle: GoogleFonts.montserrat(
              //         color: Colors.black,
              //         fontSize: w * .05,
              //         fontWeight: FontWeight.bold)),
              series: <CircularSeries>[
                // Renders doughnut chart
                DoughnutSeries<ChartData, String>(
                  enableTooltip: true,
                  explodeAll: true,
                  radius: '${w * .27}',
                  innerRadius: '${w * .05}',
                  dataSource: chartData,
                  // pointColorMapper:(ChartData data,  _) => data.color,
                  xValueMapper: (ChartData data, _) => data.x,
                  explodeIndex: 0,
                  yValueMapper: (ChartData data, _) => data.y,
                  explode: true,
                  // explodeAll: true,
                  dataLabelMapper: (ChartData data, _) =>
                      '${data.x}\n${data.y}',
                  pointRenderMode: PointRenderMode.segment,
                  dataLabelSettings: DataLabelSettings(
                      // alignment: ChartAlignment.near,
                      showCumulativeValues: true,
                      labelAlignment: ChartDataLabelAlignment.bottom,
                      labelPosition: ChartDataLabelPosition.inside,
                      textStyle: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: w * .03,
                          fontWeight: FontWeight.bold),
                      // overflowMode: OverflowMode.shift,
                      isVisible: true),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData({required this.x, required this.y});

  final String x;
  final double y;
}
