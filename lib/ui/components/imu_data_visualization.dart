import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_remo/flutter_remo.dart';

class ImuDataVisualization extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ImuDataVisualizationState();
  }

  const ImuDataVisualization({
    super.key,
    required this.imuDataStream,
  });

  final Stream<ImuData> imuDataStream;
}

class _ImuDataVisualizationState extends State<ImuDataVisualization> {
  _ImuDataVisualizationState();

  @override
  Widget build(BuildContext context) {
    return
        Text("Acceleration: [${_latestImuData?.acceleration.x.toStringAsFixed(4)}, ${_latestImuData?.acceleration.y.toStringAsFixed(4)}, ${_latestImuData?.acceleration.z.toStringAsFixed(4)}]\n"
            "AngularVelocity: [${_latestImuData?.angularVelocity.x.toStringAsFixed(4)}, ${_latestImuData?.angularVelocity.y.toStringAsFixed(4)}, ${_latestImuData?.angularVelocity.z.toStringAsFixed(4)}]\n"
            "Magnetometer: [${_latestImuData?.magneticField.x.toStringAsFixed(4)}, ${_latestImuData?.magneticField.y.toStringAsFixed(4)}, ${_latestImuData?.magneticField.z.toStringAsFixed(4)}]");
  }

  @override
  void initState() {
    super.initState();

    _imuStreamSubscription = widget.imuDataStream.listen(
      (imuData) {
        setState(
          () {
            _latestImuData = imuData;
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _imuStreamSubscription.cancel();
  }

  ImuData? _latestImuData;

  late final StreamSubscription<ImuData> _imuStreamSubscription;
}
