import 'package:flutter/material.dart';

import 'widgets/extra_widgets.dart';

class BlurMultipleWidgetsPage extends StatefulWidget {
  const BlurMultipleWidgetsPage({Key? key}) : super(key: key);

  @override
  _BlurMultipleWidgetsState createState() => _BlurMultipleWidgetsState();
}

class _BlurMultipleWidgetsState extends State<BlurMultipleWidgetsPage> {
  final double _width = 50;
  final double _height = 00;
  int _imageIndex = 0;
  double _sigmaX = 0.0;
  double _sigmaY = 0.0;
  double _opacity = 0.0;

  final images = ["background1.jpg", "background2.jpg", "background3.jpg"];

  @override
  Widget build(BuildContext context) {
    print('rebuild with sigmaX=${_sigmaX.toStringAsFixed(2)}, '
        'sigmaY=${_sigmaY.toStringAsFixed(2)}, '
        'opacity=${_opacity.toStringAsFixed(2)}');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blur multiple widgets'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            _buildImageContainer(),
            const SizedBox(height: 5),
            GestureDetector(
              child: const Text('Next image'),
              onTap: () {
                setState(() {
                  _imageIndex = (_imageIndex + 1) % images.length;
                });
              },
            ),
            const SizedBox(height: 5),
            ..._buildBlurSigmaAndOpacity(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer() {
    return const AnimatedGradiantContainer(
      height: 250,
      width: 250,
    );
  }

  List<Widget> _buildBlurSigmaAndOpacity() {
    return [
      Text('Change blur sigmaX: ${_sigmaX.toStringAsFixed(2)}'),
      Slider(
        min: 0,
        max: 10,
        value: _sigmaX,
        label: '$_sigmaX',
        onChanged: (value) {
          setState(() {
            _sigmaX = value;
          });
        },
      ),
      const SizedBox(height: 5),
      Text('Change blur sigmaY: ${_sigmaY.toStringAsFixed(2)}'),
      Slider(
        min: 0,
        max: 10,
        value: _sigmaY,
        onChanged: (value) {
          setState(() {
            _sigmaY = value;
          });
        },
      ),
      const SizedBox(height: 5),
      Text('Change blur opacity: ${_opacity.toStringAsFixed(2)}'),
      Slider(
        min: 0,
        max: 1,
        value: _opacity,
        onChanged: (value) {
          setState(() {
            _opacity = value;
          });
        },
      ),
    ];
  }
}
