import 'dart:ui';

import 'package:design_sync/design_sync.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/components/trapezoid_clip.dart';
import 'package:remorder/ui/components/recording_button.dart';
import 'package:remorder/ui/components/remo_slider.dart';
import 'package:remorder/ui/pages/save_page.dart';

import '../../l10n/app_localizations.dart';
import '../components/ring_widget.dart';

class ContractionsPage extends StatelessWidget {
  const ContractionsPage({super.key});

  @override
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
            SizedBox(height: 30.adaptedHeight),
            _getCorrectBody(builderContext, remoState),
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
          /*context.read<ProportionalControlBloc>().add(StartProportionalControl(
              remoState is TransmissionStarted
                  ? remoState.rmsDataStream
                  : Stream.empty()));*/
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
                        "00:0${((1 - (progressValue.data ?? 0)) * ProportionalControlBloc.baseValueRecordingTime.inSeconds).ceil()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26.adaptedFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF66A6AA)),
                      ),
                      SizedBox(height: 10.adaptedHeight),
                      Stack(alignment: Alignment.center, children: [
                        Container(
                          height: 246.adaptedHeight,
                          width: 246.adaptedHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(246.adaptedHeight)),
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
                          height: 170.adaptedHeight,
                          width: 170.adaptedHeight,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(170.adaptedHeight)),
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
                        _drawBaseValueRing(30.adaptedHeight, 246.adaptedHeight,
                            baseValue.data ?? 0)
                      ])
                    ]));
              });
        });
  }

  Widget _drawBaseValueRing(
      double minSize, double maxSize, double progressValue) {
    return SizedBox(
      width: lerpDouble(minSize, maxSize, progressValue),
      height: lerpDouble(minSize, maxSize, progressValue),
      child: CustomPaint(
        painter: RingPainter(
            strokeWidth: 6,
            color: progressValue > 0.7 ? Color(0xFFFA7572) : Color(0xFF80D0D4)),
      ),
    );
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        spacing: 5,
                        children: [
                      Text(
                        AppLocalizations.of(context)!.step_2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26.adaptedFontSize,
                            fontWeight: FontWeight.w600,
                            color: Colors.black),
                      ),
                      Text(
                        AppLocalizations.of(context)!.max_calibration_message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15.adaptedFontSize,
                            fontWeight: FontWeight.w500,
                            color: Colors.black),
                      ),
                      SizedBox(height: 15.adaptedHeight),
                      Text(
                        "00:0${((1 - (progressValue.data ?? 0)) * ProportionalControlBloc.mvcRecordingTime.inSeconds).ceil()}",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 26.adaptedFontSize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF66A6AA)),
                      ),
                      SizedBox(height: 5.adaptedHeight),
                      Image.asset(
                          width: 150.adaptedHeight,
                          height: 86.adaptedHeight,
                          "assets/mascotte_rythm.png"),
                      Stack(children: [
                        ClipPath(
                          clipper: TrapezoidClip(),
                          child: Stack(children: [
                            Container(
                              color: Color(0xFFBEE2E5),
                              width: 97.adaptedWidth,
                              height: 240.adaptedHeight,
                            ),
                            Positioned(
                                bottom: 0,
                                child: Container(
                                  color: Color(0xFF80D0D4),
                                  width: 97.adaptedWidth,
                                  height:
                                      240.adaptedHeight * (mvcValue.data ?? 0),
                                )),
                          ]),
                        ),
                        Positioned(
                            bottom: 240.adaptedHeight * (mvcValue.data ?? 0),
                            left: 97.adaptedWidth / 2 -
                                (lerpDouble(45.adaptedWidth, 110.adaptedWidth,
                                            (mvcValue.data ?? 0)) ??
                                        0) /
                                    2,
                            child: Container(
                              color: Color(0xFF80D0D4),
                              width: lerpDouble(45.adaptedWidth,
                                  110.adaptedWidth, (mvcValue.data ?? 0)),
                              height: 4.adaptedHeight,
                            )),
                      ]),
                      Image.asset(
                          width: 81.adaptedHeight,
                          height: 40.adaptedHeight,
                          "assets/mascotte_rythm_chill.png"),
                    ]));
              });
        });
  }

  Widget _buildBiofeedbackBody(BuildContext context, Active state) {
    if (context.read<ProportionalControlFileBloc>().state is! Recording) {
      context.read<ProportionalControlFileBloc>().add(StartRecordingBiofeedback(
          state.cyclicFeedbackStream,
          state.repetitionsStream,
          state.baseValue,
          state.mvc));
    }

    return BlocListener<ProportionalControlFileBloc, RemoFileState>(
      listener: (context, state) async {
        if (state is RecordingComplete) {
          Navigator.pushNamed(context, "/save_page", arguments: SavePageMode.biofeedback);
        }
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.step_3,
                style: TextStyle(
                    fontSize: 26.adaptedFontSize,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2B3A51))),
            SizedBox(height: 8.adaptedHeight),
            Text(
              AppLocalizations.of(context)!.biofeedback_message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15.adaptedFontSize,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2B3A51)),
            ),
            SizedBox(height: 25.adaptedHeight),
            StreamBuilder(
                stream: state.repetitionsStream,
                builder: (context, repetitions) => Text(
                      AppLocalizations.of(context)!.repetitions(repetitions.data ?? 0),
                      style: TextStyle(
                          fontSize: 26.adaptedFontSize,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF66A6AA)),
                    )),
            StreamBuilder(
                stream: state.cyclicFeedbackStream,
                builder: (context, feedbackValue) =>
                    RemoSlider(feedbackValue.data ?? 0)),
            SizedBox(height: 35.adaptedHeight),
            Text(
              AppLocalizations.of(context)!.stop_exercise,
              style: TextStyle(
                  fontSize: 14.adaptedFontSize,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF4C5460)),
            ),
            RecordButton(
                key: Key("test"),
                recording: true,
                onStopPressed: () => context
                    .read<ProportionalControlFileBloc>()
                    .add(StopRecording()))
          ]),
    );
  }

  Widget _buildPreExerciseBody(BuildContext context, RemoState remoState,
      String stepText, String message, VoidCallback? buttonCallback) {
    return Padding(
        padding: EdgeInsets.fromLTRB(17.adaptedWidth, 0, 17.adaptedWidth, 0),
        child: Center(
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
              Transform.rotate(
                  angle: 0.5,
                  child: Image.asset(
                    'assets/wear_remo_2.png',
                  )),
              SizedBox(height: 80.adaptedHeight),
              FilledButton(
                  onPressed: buttonCallback,
                  style: FilledButton.styleFrom(
                    fixedSize: Size(
                      343.adaptedWidth,
                      48.adaptedHeight,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(24.adaptedRadius))),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.start,
                    style: TextStyle(
                        fontSize: 24.adaptedFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  )),
            ])));
  }

  Widget _buildNextExerciseBody(BuildContext context, RemoState remoState,
      VoidCallback? nextCallback, VoidCallback? repeatCallback) {
    return Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 20,
            children: [
          SizedBox(height: 110.adaptedHeight),
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
