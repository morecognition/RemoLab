import 'dart:ui';

import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';

import '../../l10n/app_localizations.dart';

class ContractionsPage extends StatelessWidget {
  const ContractionsPage({super.key});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFFF6F7FF),
        toolbarHeight: 50.adaptedHeight,
        flexibleSpace: Container(
            alignment: Alignment.bottomCenter,
            child: Row(children: [
              SizedBox(height: 36.adaptedHeight),
              Expanded(
                  child: Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.feed_back,
                style: TextStyle(
                    color: Color(0xFF2B3A51),
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w700),
              ))
            ])),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F7FF),
      body: BlocBuilder<RemoBloc, RemoState>(
          builder: (builderContext, remoState) {
        return _getCorrectBody(builderContext, remoState);
      }),
    );
  }

  Widget _getCorrectBody(BuildContext context, RemoState remoState) {
    return BlocProvider(
        create: (context) => ProportionalControlBloc(),
        child: BlocBuilder<ProportionalControlBloc, PropotionalControlState>(
            builder: (context, state) {
          switch (state) {
            case Inactive _:
              return _buildPreCalibrationBody(context, remoState);

            case RecordingBaseValue recordingBaseState:
              return _buildRestCalibrationBody(context, recordingBaseState);

            case RecordingMvc recordingMvcState:
              return _buildMaxCalibrationBody(context, recordingMvcState);

            case Active active:
              return _buildBiofeedbackBody(context, active);
          }

          return Container();
        }));
  }

  Widget _buildPreCalibrationBody(BuildContext context, RemoState remoState) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
          SizedBox(height: 100.adaptedHeight),
          Image.asset(
            'assets/remo_icon.png',
          ),
          Text(
            AppLocalizations.of(context)!.pre_calibration_message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18.adaptedFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
          SizedBox(height: 100.adaptedHeight),
          FilledButton(
              onPressed: () => context.read<ProportionalControlBloc>().add(
                  StartRecordingBaseValue(remoState is TransmissionStarted
                      ? remoState.rmsDataStream
                      : Stream.empty())),
              style: FilledButton.styleFrom(
                fixedSize: Size(
                  343.adaptedWidth,
                  48.adaptedHeight,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(24.adaptedRadius))),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                AppLocalizations.of(context)!.start_calibrating,
                style: TextStyle(
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )),
        ]));
  }

  Widget _buildRestCalibrationBody(
      BuildContext context, RecordingBaseValue state) {
    return StreamBuilder(
        stream: state.progressStream,
        builder: (context, progressValue) {
          return StreamBuilder(
              stream: state.baseValueStream,
              builder: (context, baseValue) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                      SizedBox(height: 100.adaptedHeight),
                      Image.asset(
                        'assets/remo_icon.png',
                      ),
                      Text(
                        AppLocalizations.of(context)!.rest_calibration_message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18.adaptedFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(height: 30.adaptedHeight),
                      SizedBox(
                          width: 200.adaptedWidth,
                          child: LinearProgressIndicator(
                              value: baseValue.data,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 40.adaptedHeight)),
                      SizedBox(
                          width: 200.adaptedWidth,
                          child: LinearProgressIndicator(
                              value: progressValue.data,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 20.adaptedHeight)),
                      SizedBox(height: 70.adaptedHeight),
                    ]));
              });
        });
  }

  Widget _buildMaxCalibrationBody(BuildContext context, RecordingMvc state) {
    return StreamBuilder(
        stream: state.progressStream,
        builder: (context, progressValue) {
          return StreamBuilder(
              stream: state.mvcStream,
              builder: (context, mvcValue) {
                return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 20,
                        children: [
                      SizedBox(height: 100.adaptedHeight),
                      Image.asset(
                        'assets/remo_icon.png',
                      ),
                      Text(
                        AppLocalizations.of(context)!.max_calibration_message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18.adaptedFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(height: 30.adaptedHeight),
                      SizedBox(
                          width: 200.adaptedWidth,
                          child: LinearProgressIndicator(
                              value: mvcValue.data,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 40.adaptedHeight)),
                      SizedBox(
                          width: 200.adaptedWidth,
                          child: LinearProgressIndicator(
                              value: progressValue.data,
                              backgroundColor: Colors.grey[300],
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.blue),
                              minHeight: 20.adaptedHeight)),
                      SizedBox(height: 70.adaptedHeight),
                    ]));
              });
        });
  }

  Widget _buildBiofeedbackBody(BuildContext context, Active state) {
    return StreamBuilder(
        stream: state.cyclicFeedbackStream,
        builder: (context, feedbackValue) {
          return Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 20,
                  children: [
                SizedBox(height: 100.adaptedHeight),
                Image.asset(
                  'assets/remo_icon.png',
                ),
                Text(
                  AppLocalizations.of(context)!.biofeedback_message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18.adaptedFontSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black),
                ),
                SizedBox(height: 30.adaptedHeight),
                SizedBox(
                    width: 200.adaptedWidth,
                    child: LinearProgressIndicator(
                        value: feedbackValue.data,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 40.adaptedHeight)),
                SizedBox(height: 70.adaptedHeight),
              ]));
        });
  }
}
