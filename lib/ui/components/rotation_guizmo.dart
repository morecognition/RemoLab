import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:design_sync/design_sync.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';

class RotationGizmo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RotationGizmoState();
  }

  const RotationGizmo({
    super.key,
    required this.imuDataStream,
  });

  final Stream<ImuData> imuDataStream;
}

class _RotationGizmoState extends State<RotationGizmo> {
  _RotationGizmoState();

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

    widget.imuDataStream
        .first
        .then((imuData) => _lastTimestamp = imuData.timestamp);

    _imuStreamSubscription = widget.imuDataStream.listen(
      (imuData) {
        setState(
          () {
            var deltaTime = (imuData.timestamp - _lastTimestamp) / 1000;

            var velocity = Vector3(0, 10, 0);
            _smoothVelocity = _smoothVelocity * alpha + Vector3(imuData.angularVelocity.x, imuData.angularVelocity.y, imuData.angularVelocity.z) * (1 - alpha);
            //_rotation += _smoothVelocity * rotationSpeed * deltaTime;

            //var omega = Quaternion(radians(_smoothVelocity.x), radians(_smoothVelocity.y), radians(_smoothVelocity.z), 0);
            //var delta = (_rotation * omega)..scale(0.5 * deltaTime);
            //_rotation = _rotation + delta;

            //var delta = angularVelocityToQuaternion(_smoothVelocity * degrees2Radians, deltaTime);
            //_rotation = _rotation * delta;
            //_rotation = _rotation.normalized();
            _rotation +=  _smoothVelocity * deltaTime * rotationSpeed;
            _cube.rotation.setFrom(_rotation);

            _cube.updateTransform();

            _lastTimestamp = imuData.timestamp;
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

  Vector3 quaternionToEuler(Quaternion q) {
    double ysqr = q.y * q.y;

    // Roll (x-axis rotation)
    double t0 = 2.0 * (q.w * q.x + q.y * q.z);
    double t1 = 1.0 - 2.0 * (q.x * q.x + ysqr);
    double roll = atan2(t0, t1);

    // Pitch (y-axis rotation)
    double t2 = 2.0 * (q.w * q.y - q.z * q.x);
    t2 = t2.clamp(-1.0, 1.0);
    double pitch = asin(t2);

    // Yaw (z-axis rotation)
    double t3 = 2.0 * (q.w * q.z + q.x * q.y);
    double t4 = 1.0 - 2.0 * (ysqr + q.z * q.z);
    double yaw = atan2(t3, t4);

    return Vector3(degrees(roll), degrees(pitch), degrees(yaw));
  }

  Quaternion angularVelocityToQuaternion(Vector3 omega, double dt) {
    // Convert angular velocity to half-angle quaternion
    Vector3 halfTheta = omega * (0.5 * dt);
    Quaternion deltaQuat = Quaternion(halfTheta.x, halfTheta.y, halfTheta.z, 1.0);
    return deltaQuat.normalized();
  }

  static const double alpha = 0;
  static const double rotationSpeed = 0.1;

  late Object _cube;
  late Vector3 _rotation;
  late Vector3 _smoothVelocity;
  late double _lastTimestamp;

  late final StreamSubscription<ImuData> _imuStreamSubscription;
}
