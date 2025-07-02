import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:minsellprice/app.dart';
import 'package:minsellprice/services/extra_functions.dart';
import 'package:minsellprice/screens/custom_paints/dount_chart.dart';
import 'package:minsellprice/size.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class PricePropositionChart extends StatefulWidget {
  const PricePropositionChart({
    super.key,
    required this.chartData,
    required this.donutData,
    required this.sliderController,
  });

  final List<PricePropositionModel> chartData, donutData;
  final CarouselSliderController sliderController;

  @override
  State<PricePropositionChart> createState() => _PricePropositionChartState();
}

class _PricePropositionChartState extends State<PricePropositionChart> {
  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      controller: widget.sliderController,
      onSlideChanged: (index) {},
      viewportFraction: 1,
      slideTransform: const DepthTransform(),
      slideIndicator: CircularWaveSlideIndicator(
        itemSpacing: 15,
        indicatorRadius: 6,
        // padding: EdgeInsets.only(top: h * .62),
      ),
      children: List.generate(
        widget.chartData.length,
        (index) => _donutChart(index),
      ),
    );
  }

  Center _customDonutChart(int index) {
    return Center(
      child: CustomPaint(
        painter: DountChart(chartData: widget.chartData[index].color),
        // child: Container(),
        size: Size(w * .7, w * .7),
      ),
    );
  }

  PieChart buildPieChart(int index) {
    return PieChart(
      swapAnimationCurve: Curves.easeInBack,
      PieChartData(
        startDegreeOffset: 150,
        sectionsSpace: 5,
        centerSpaceRadius: 100,
        borderData: FlBorderData(
            show: true, border: Border.all(color: Colors.black, width: 1)),
        pieTouchData: PieTouchData(
            // touchCallback: (FlTouchEvent event, pieTouchResponse) {
            //   setState(() {
            //     if (!event.isInterestedForInteractions ||
            //         pieTouchResponse == null ||
            //         pieTouchResponse.touchedSection == null) {
            //       return;
            //     }
            //   });
            // },
            ),
        sections: List.generate(
          widget.donutData[index].color.length,
          (index1) => PieChartSectionData(
            radius: 60,
            value: double.parse(
                widget.donutData[index].color[index1].value.toString()),
            color: widget.donutData[index].color[index1].color,
            showTitle: true,
          ),
        ),
      ),
    );
  }

  Column _donutChart(int index) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Card(
          child: Container(
            width: w,
            height: w,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Stack(
              children: [
                SfCircularChart(
                  series: <CircularSeries>[
                    // Renders doughnut chart
                    DoughnutSeries<PricePropositionColor, String>(
                      enableTooltip: true,
                      // startAngle: 1,
                      // endAngle: 359,
                      explode: false,
                      radius: '${w * .31}',
                      strokeColor: Colors.white,
                      strokeWidth: 2,
                      innerRadius: '${w * .2}',
                      dataSource: widget.donutData[index].color,

                      pointColorMapper: (data, index1) => data.color,
                      xValueMapper: (data, index1) => widget
                          .donutData[index].color[index1].value
                          .toString(),
                      yValueMapper: (data, index2) {
                        return widget.donutData[index].color[index2].value;
                      },
                      explodeAll: false,
                      // explodeOffset: "4",
                      cornerStyle: CornerStyle.bothFlat,

                      // pointColorMapper: pointColorMapper,
                      // explodeAll: true,
                      // dataLabelMapper: (ChartData data, _) =>
                      // '${data.x}\n${data.y}',
                      pointRenderMode: PointRenderMode.segment,
                      sortingOrder: SortingOrder.none,
                      dataLabelSettings: DataLabelSettings(
                        alignment: ChartAlignment.center,
                        showCumulativeValues: false,
                        labelAlignment: ChartDataLabelAlignment.bottom,
                        labelPosition: ChartDataLabelPosition.inside,
                        labelIntersectAction: LabelIntersectAction.shift,
                        textStyle: GoogleFonts.montserrat(
                            color: Colors.black,
                            fontSize: w * .028,
                            fontWeight: FontWeight.bold),
                        // overflowMode: OverflowMode.shift,
                        isVisible: true,
                      ),
                    )
                  ],
                ),
                Center(
                  child: CachedNetworkImage(
                    imageUrl: index == 0
                        ? "${AppInfo.kBaseUrl(stagingSelector: 1)}vendor-logo/${widget.chartData[index].brandName}.jpg"
                        : '${AppInfo.kBaseUrl(stagingSelector: 1)}brand-logo/brands/${widget.chartData[index].brandName}.png',
                    height: w * .3,
                    width: w * .3,
                  ),
                )
              ],
            ),
          ),
        ),
        SizedBox(
          width: w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              widget.chartData[index].color.length,
              (index1) => Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      color: widget.chartData[index].color[index1].color,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Flexible(
                        child: RichText(
                      text: TextSpan(
                        text: widget.chartData[index].color[index1].labelName,
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: w * .035,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          const TextSpan(text: ' :  '),
                          TextSpan(
                            text: widget.chartData[index].color[index1].value
                                .toString(),
                            style: GoogleFonts.montserrat(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: w * .04,
                            ),
                          ),
                        ],
                      ),
                    )
                        // AutoSizeText(
                        //   '${getLabelName(index: index1)}: ${widget.chartData[index].color[index1].value}',
                        //   style: GoogleFonts.montserrat(
                        //     fontSize: w * .035,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PricePropositionModel {
  String brandName;

  // List<int> chartData;
  List<PricePropositionColor> color;

  PricePropositionModel({
    required this.brandName,
    required this.color,
    // required this.chartData,
  });
}

class PricePropositionColor {
  final Color color;
  final int value;
  final String labelName;

  const PricePropositionColor(
      {required this.color, required this.value, required this.labelName});
}

Map<int, Color> getSwatch() {
  return {
    1: '#d579c7'.toColor(),
    2: '#ea91b5'.toColor(),
    3: '#ffa9a2'.toColor(),
    4: '#9531ff'.toColor(),
    5: '#aa49ec'.toColor(),
    6: '#bf61da'.toColor(),
  };
}

Map<int, Color> getSwatchForRow() {
  return {
    1: Colors.blue,
    2: Colors.blue.shade200,
    3: Colors.green,
    4: Colors.lightGreenAccent,
    5: Colors.pinkAccent,
    6: Colors.redAccent,
  };
}

List<Color> getColors() {
  return getSwatch().values.toList();
}

List<Color> getColorsForRow() {
  return getSwatchForRow().values.toList();
}

ChartValueMapper<int, Color>? pointColorMapper = (int data, int index) {
  List<Color> colors =
      getColors(); // get the list of colors from the previous function
  return colors[index]; // return the color based on the index
};

String formatString(String input) {
  // Replace _ with space in the input and store it in a new string
  String newInput = input.replaceAll('_', ' ');
  // Capitalize the first letter of the new string and return it
  return newInput[0].toUpperCase() + newInput.substring(1);
}
