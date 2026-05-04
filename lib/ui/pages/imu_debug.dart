import 'dart:async';

import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/components/imu_data_visualization.dart';
import 'package:remorder/ui/components/rotation_guizmo.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ImuDebug extends StatefulWidget {
  const ImuDebug({super.key});

  @override
  State<ImuDebug> createState() => _ImuDebugState();
}

class _ImuDebugState extends State<ImuDebug> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    final remoState = context.read<RemoBloc>().state;
    if (remoState is Connected) {
      context.read<RemoBloc>().add(OnStartTransmission());
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F7FF),
        toolbarHeight: 50.adaptedHeight,
        flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            child: Text("Gyro Debug",
                style: TextStyle(
                    color: const Color(0xFF2B3A51),
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w700))),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F7FF),
      body: BlocConsumer<RemoBloc, RemoState>(
        listener: (context, remoState) {
          if (remoState is Connected) {
            context.read<RemoBloc>().add(OnStartTransmission());
          }
        },
        builder: (builderContext, remoState) {
          if (remoState is StartingTransmission ||
              remoState is StoppingTransmission) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
              child: Stack(
            children: [
              ImuDataVisualization(
                  imuDataStream: remoState is TransmissionStarted
                      ? remoState.imuDataStream
                      : Stream.empty()),
              RotationGizmo(
                  imuDataStream: remoState is TransmissionStarted
                      ? remoState.imuDataStream
                      : Stream.empty()),
            ],
          ));
        },
      ),
    );
  }
}
