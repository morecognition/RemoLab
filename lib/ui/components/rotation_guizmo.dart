import 'dart:async';
import 'dart:collection';

import 'package:design_sync/design_sync.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';

class RotationGuizmo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RotationGuizmoState();
  }

  const RotationGuizmo({
    super.key,
    required this.imuDataStream,
  });

  final Stream<ImuData> imuDataStream;
}

class _RotationGuizmoState extends State<RotationGuizmo> {
  _RotationGuizmoState();

  @override
  Widget build(BuildContext context) {
    return Cube(
      interactive: false,
      onSceneCreated: (Scene scene) {
        scene.world.add(_cube);
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _rotation = Vector3.zero();
    _smoothVelocity = Vector3.zero();

    _cube = Object(
      fileName: 'assets/guizmo.obj',
      scale: Vector3.all(5),
      rotation: _rotation
    );


    _imuStreamSubscription = widget.imuDataStream.listen(
      (imuData) {
        setState(
          () {
            _smoothVelocity = _smoothVelocity * alpha + Vector3(imuData.angularVelocity.x, imuData.angularVelocity.y, imuData.angularVelocity.z) * (1 - alpha);
            _rotation += _smoothVelocity;
            _cube.rotation.setFrom(_rotation);

            _cube.updateTransform();
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

  static const double alpha = 0.7;
  
  late Object _cube;
  late Vector3 _rotation;
  late Vector3 _smoothVelocity;

  late final StreamSubscription<ImuData> _imuStreamSubscription;
}
