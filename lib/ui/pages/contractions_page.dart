import 'dart:ui';

import 'package:design_sync/design_sync.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';

import '../../l10n/app_localizations.dart';

class ContractionsPage extends StatelessWidget {
  const ContractionsPage({super.key});

  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
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
          return Column(children: [
            SizedBox(height: 16.adaptedHeight),
            _buildChartButtons(context),
            SizedBox(height: 46.adaptedHeight),
            _getCorrectBody(builderContext, remoState),
            SizedBox(height: 12.adaptedHeight),
          ]);
        }),
      ),
      _drawLoadFileButton(),
    ]);
  }

  Widget _drawLoadFileButton() {
    return Positioned(
        top: 38.adaptedHeight,
        left: 16.adaptedWidth,
        child: BlocBuilder<RemoFileBloc, RemoFileState>(
            builder: (context, remoFileState) {
          return IconButton(
              onPressed: remoFileState is Recording
                  ? null
                  : () async {
                      var result = await FilePicker.platform.pickFiles(
                          type: FileType.custom, allowedExtensions: ['csv']);

                      if (result == null || result.files.single.path == null) {
                        return;
                      }

                      if (context.mounted) {
                        context
                            .read<RemoFileBloc>()
                            .add(OpenRmsRecord(result.files.single.path!));
                        Navigator.pushNamed(context, "/playback_page")
                            .then((c) {
                          if (context.mounted) {
                            context.read<RemoFileBloc>().add(Reset());
                          }
                        });
                      }
                    },
              icon: Image.asset("assets/add_file_icon.png",
                  width: 36.adaptedWidth,
                  height: 36.adaptedHeight,
                  color: remoFileState is Recording ? Colors.grey : null));
        }));
  }

  Widget _getCorrectBody(BuildContext context, RemoState remoState) {
    return BlocProvider(
        create: (context) => ProportionalControlBloc(),
        child: BlocBuilder<ProportionalControlBloc, PropotionalControlState>(
            builder: (context, state) {
          switch (state) {
            case Inactive _:
              return _buildPreExerciseBody(
                context,
                remoState,
                AppLocalizations.of(context)!.step_1,
                AppLocalizations.of(context)!.pre_calibration_message,
                () => context.read<ProportionalControlBloc>().add(
                    StartRecordingBaseValue(remoState is TransmissionStarted
                        ? remoState.rmsDataStream
                        : Stream.empty())),
              );

            case RecordingBaseValue recordingBaseState:
              return _buildRestCalibrationBody(context, recordingBaseState);

            case PostBaseValue prepareRecordingMvc:
              return _buildNextExerciseBody(
                  context,
                  remoState,
                  () => context
                      .read<ProportionalControlBloc>()
                      .add(PrepareRecordingMvc()),
                  () => context.read<ProportionalControlBloc>().add(
                      StartRecordingBaseValue(remoState is TransmissionStarted
                          ? remoState.rmsDataStream
                          : Stream.empty())));

            case ReadyToRecordMvc readyRecordingBaseState:
              return _buildPreExerciseBody(
                context,
                remoState,
                AppLocalizations.of(context)!.step_2,
                AppLocalizations.of(context)!.pre_max_calibration_message,
                () => context.read<ProportionalControlBloc>().add(
                    StartRecordingMvc(remoState is TransmissionStarted
                        ? remoState.rmsDataStream
                        : Stream.empty())),
              );

            case RecordingMvc recordingMvcState:
              return _buildMaxCalibrationBody(context, recordingMvcState);

            case PostMvcValue prepareActive:
              return _buildNextExerciseBody(
                  context,
                  remoState,
                  () => context
                      .read<ProportionalControlBloc>()
                      .add(PrepareProportionalControl()),
                  () => context.read<ProportionalControlBloc>().add(
                      StartRecordingMvc(remoState is TransmissionStarted
                          ? remoState.rmsDataStream
                          : Stream.empty())));

            case ReadyToStart readyActive:
              return _buildPreExerciseBody(
                context,
                remoState,
                AppLocalizations.of(context)!.step_3,
                AppLocalizations.of(context)!.pre_biofeedback_message,
                () => context.read<ProportionalControlBloc>().add(
                    StartProportionalControl(remoState is TransmissionStarted
                        ? remoState.rmsDataStream
                        : Stream.empty())),
              );

            case Active active:
              return _buildBiofeedbackBody(context, active);
          }

          return Container();
        }));
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
                        spacing: 10,
                        children: [
                      Text(
                        AppLocalizations.of(context)!.step_1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26.adaptedFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      Text(
                        AppLocalizations.of(context)!.rest_calibration_message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15.adaptedFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      Text(
                        "00:05",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26.adaptedFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF66A6AA)),
                      ),
                      SizedBox(height: 10.adaptedHeight),
                      Stack(alignment: Alignment.center, children: [
                        Container(
                          height: 246.adaptedFontSize,
                          width: 246.adaptedFontSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(246.adaptedFontSize)),
                            color: Colors.white,
                            gradient: RadialGradient(
                              radius: 0.5,
                              colors: <Color>[
                                Color(0x00FDBAB9),
                                Color(0xCCFDBAB9),
                              ],
                              stops: <double>[0.7, 1.0],
                            ),
                          ),
                        ),
                        //Red Gradient
                        Container(
                          height: 170.adaptedFontSize,
                          width: 170.adaptedFontSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(170.adaptedFontSize)),
                            color: Colors.white,
                            gradient:
                                RadialGradient(radius: 0.5, colors: <Color>[
                              Color(0x00B3E4E6),
                              Color(0xFFB3E3E5),
                            ], stops: <double>[
                              0.2,
                              1.0
                            ]),
                          ),
                        ),
                        //Blue Gradient
                        Image.asset("assets/mascotte_emoji.png"),
                        //Remo Icon
                      ]),
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
                      SizedBox(height: 0.adaptedHeight),
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

  Widget _buildPreExerciseBody(BuildContext context, RemoState remoState,
      String stepText, String message, VoidCallback? buttonCallback) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
          SizedBox(height: 60.adaptedHeight),
          Text(
            stepText,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26.adaptedFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15.adaptedFontSize,
                fontWeight: FontWeight.w500,
                color: Colors.black),
          ),
          SizedBox(height: 20.adaptedHeight),
          Image.asset(
            'assets/wear_remo_2.png',
          ),
          SizedBox(height: 80.adaptedHeight),
          FilledButton(
              onPressed: buttonCallback,
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
                AppLocalizations.of(context)!.start,
                style: TextStyle(
                    fontSize: 24.adaptedFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )),
        ]));
  }

  Widget _buildNextExerciseBody(BuildContext context, RemoState remoState,
      VoidCallback? nextCallback, VoidCallback? repeatCallback) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
          SizedBox(height: 60.adaptedHeight),
          Image.asset(
            'assets/mascotte.png',
          ),
          Text(
            AppLocalizations.of(context)!.exercise_completed,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 26.adaptedFontSize,
                fontWeight: FontWeight.w600,
                color: Colors.black),
          ),
          SizedBox(height: 120.adaptedHeight),
          FilledButton(
              onPressed: nextCallback,
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
                AppLocalizations.of(context)!.next_exercise,
                style: TextStyle(
                    fontSize: 24.adaptedFontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              )),
          FilledButton(
              onPressed: repeatCallback,
              style: FilledButton.styleFrom(
                fixedSize: Size(
                  343.adaptedWidth,
                  48.adaptedHeight,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.all(Radius.circular(24.adaptedRadius))),
                backgroundColor: Colors.transparent,
              ),
              child: Text(
                AppLocalizations.of(context)!.repeat,
                style: TextStyle(
                    fontSize: 24.adaptedFontSize,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor),
              )),
        ]));
  }

  Widget _buildChartButtons(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
            fixedSize: Size(
              164.adaptedWidth,
              32.adaptedHeight,
            ),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(25.adaptedRadius))),
            backgroundColor: const Color(0xFFE5F3F5),
          ),
          child: Text(AppLocalizations.of(context)!.graph_1,
              style: TextStyle(
                  fontSize: 20.adaptedFontSize,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF93959B))),
        ),
        Spacer(),
        FilledButton(
          onPressed: () {},
          style: FilledButton.styleFrom(
              fixedSize: Size(
                164.adaptedWidth,
                32.adaptedHeight,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(25.adaptedRadius))),
              backgroundColor: Theme.of(context).primaryColor),
          child: Text(
            AppLocalizations.of(context)!.graph_2,
            style: TextStyle(
              fontSize: 20.adaptedFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        Spacer()
      ],
    );
  }
}
