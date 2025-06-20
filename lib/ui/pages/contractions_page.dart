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

            case RecordingBaseValue _:
              return _buildRestCalibrationBody(context);

            case RecordingMvc _:
              return _buildMaxCalibrationBody(context);

            case Active active:
              return StreamBuilder(
                  stream: active.cyclicFeedbackStream,
                  builder: (context, value) {
                    return _buildBiofeedbackBody(context, value);
                  });
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

  Widget _buildRestCalibrationBody(BuildContext context) {
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
                  value: 0.7,
                  //Todo: to be linked to 5 secs timer progress, change body state at the end
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 40.adaptedHeight)),
          SizedBox(height: 70.adaptedHeight),
        ]));
  }

  Widget _buildMaxCalibrationBody(BuildContext context) {
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
                  value: 0.3,
                  //Todo: to be linked and normalized to user muscle strength, change body state after 3 seconds
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 40.adaptedHeight)),
          SizedBox(height: 70.adaptedHeight),
        ]));
  }

  Widget _buildBiofeedbackBody(
      BuildContext context, AsyncSnapshot<double> data) {
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
                  value: 0.3,
                  //Todo: to be linked to user current muscle strength
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  minHeight: 40.adaptedHeight)),
          SizedBox(height: 70.adaptedHeight),
        ]));
  }
}
