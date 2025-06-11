import 'dart:async';

import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/components/imu_data_visualization.dart';
import 'package:remorder/ui/components/rotation_guizmo.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../components/data_chart.dart';

class ImuDebug extends StatelessWidget {
  const ImuDebug({super.key});

  @override
  Widget build(BuildContext context) {
    WakelockPlus.enable();
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F7FF),
        toolbarHeight: 50.adaptedHeight,
        flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            child: Text("Gyro Debug",
                style: TextStyle(
                    color: Color(0xFF2B3A51),
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w700))),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F7FF),
      body: BlocBuilder<RemoBloc, RemoState>(
        builder: (builderContext, remoState) {
          if (remoState is Connected) {
            builderContext.read<RemoBloc>().add(OnStartTransmission());
          }

          if (remoState is StartingTransmission ||
              remoState is StoppingTransmission) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
              child: Stack(
                children: [
                  ImuDataVisualization(imuDataStream: remoState is TransmissionStarted ? remoState.imuDataStream : Stream.empty()),
                  RotationGizmo(imuDataStream: remoState is TransmissionStarted ? remoState.imuDataStream : Stream.empty()),
                ],
              )
          );

        },
      ),
    );
  }
}
