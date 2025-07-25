import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';

class RemoSlider extends StatelessWidget {
  const RemoSlider(this.progress, {super.key});

  final List<double> circleThresholds = const [0.25, 0.75];
  final double progress;

  @override
  Widget build(BuildContext context) {
    var barHeight = 220.adaptedHeight;
    var iconWidth = 128.adaptedWidth;
    var iconHeight = 63.adaptedHeight;

    var offset = Offset(0, ((1 - progress) * barHeight / iconHeight) - barHeight / iconHeight / 2);

    return SizedBox(
      height: 245.adaptedHeight,
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 15.adaptedWidth,
              height: barHeight,
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius:
                      BorderRadius.all(Radius.circular(4.adaptedRadius)))),
          ),
          Center(
            child: AnimatedSlide(
                offset: offset,
                duration: const Duration(milliseconds: 100),
                curve: Curves.linear,
                child: _sliderIcon(progress, iconWidth, iconHeight)),
          )
        ],
      ),
    );
  }

  Widget _sliderIcon(double progress, double width, double height) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        AnimatedOpacity(
            opacity: progress >= circleThresholds[1] ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Transform.scale(
                scale: 1.5,
                child: Image.asset('assets/mascotte_rythm_circle2.png',
                    width: width, height: height))),
        AnimatedOpacity(
            opacity: progress >= circleThresholds[0] ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: Transform.scale(
                scale: 1.25,
                child: Image.asset('assets/mascotte_rythm_circle1.png',
                    width: width, height: height))),
        Image.asset('assets/mascotte_rythm.png', width: width, height: height)
      ],
    );
  }
}
