import 'dart:async';

import 'package:design_sync/design_sync.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';
import 'package:remorder/ui/components/channel_button.dart';
import 'package:remorder/ui/components/recording_button.dart';
import 'package:remorder/ui/pages/save_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../l10n/app_localizations.dart';
import '../components/data_chart.dart';

class RemoTransmission extends StatefulWidget {
  const RemoTransmission({super.key});

  @override
  State<RemoTransmission> createState() => _RemoTransmissionState();
}

class _RemoTransmissionState extends State<RemoTransmission> {
  static const channelColors = [
    Color(0xFFFC7F8E),
    Color(0xFFFAA869),
    Color(0xFFE5DB80),
    Color(0xFF69C9D7),
    Color(0xFF6988D7),
    Color(0xFFC273E7),
    Color(0xFF7FD769),
    Color(0xFF34AC5D),
  ];

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
            child: Row(children: [
              SizedBox(height: 36.adaptedHeight),
              BlocBuilder<RemoFileBloc, RemoFileState>(
                  builder: (context, remoFileState) {
                return IconButton(
                    padding: EdgeInsets.fromLTRB(
                        16.adaptedWidth, 0, 16.adaptedWidth, 0),
                    onPressed: remoFileState is Recording
                        ? null
                        : () async {
                            var result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['csv']);

                            if (result == null ||
                                result.files.single.path == null) {
                              return;
                            }

                            if (context.mounted) {
                              context.read<RemoFileBloc>().add(
                                  OpenRmsRecord(result.files.single.path!));
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
                        color:
                            remoFileState is Recording ? Colors.grey : null));
              }),
              Expanded(
                  child: Text(
                textAlign: TextAlign.center,
                AppLocalizations.of(context)!.data_visualization,
                style: TextStyle(
                    color: const Color(0xFF2B3A51),
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w700),
              )),
              SizedBox(height: 36.adaptedHeight),
              IconButton(
                  padding: EdgeInsets.fromLTRB(
                      16.adaptedWidth, 0, 16.adaptedWidth, 0),
                  onPressed: () => Navigator.pushNamed(context, "/imu_debug"),
                  icon: Image.asset(
                    "assets/imu_debug_icon.png",
                    width: 26.adaptedWidth,
                    height: 26.adaptedHeight,
                    color: Theme.of(context).primaryColor,
                  )),
            ])),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F7FF),
      body: BlocProvider<ChartBloc>(
        create: (context) => ChartBloc(),
        child: BlocConsumer<RemoBloc, RemoState>(
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

            return BlocListener<RemoFileBloc, RemoFileState>(
              listener: (context, state) async {
                if (state is RecordingComplete) {
                  Navigator.pushNamed(context, "/save_page",
                      arguments: SavePageMode.rms);
                }
              },
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 16.adaptedHeight),
                      Column(children: [
                        _buildChartButtons(),
                        SizedBox(height: 46.adaptedHeight),
                        _buildFilterButtons(),
                        SizedBox(height: 12.adaptedHeight),
                      ]),
                      Container(
                        width: 343.adaptedWidth,
                        height: 432.adaptedHeight,
                        color: Colors.white,
                        child: BlocBuilder<RemoFileBloc, RemoFileState>(
                            builder: (context, remoFileState) {
                          return remoState is TransmissionStarted
                              ? DataChart(
                                  rmsDataStream: remoState.rmsDataStream,
                                  colors: channelColors,
                                  isRecording: remoFileState is Recording,
                                  key: const Key("remo chart"))
                              : DataChart(
                                  rmsDataStream: Stream.empty(),
                                  colors: channelColors,
                                  key: const Key("empty chart"));
                        }),
                      ),
                      SizedBox(height: 15.adaptedHeight),
                      BlocBuilder<RemoFileBloc, RemoFileState>(
                          builder: (context, remoFileState) => RecordButton(
                                recording: remoFileState is Recording,
                                onRecordPressed: () => context
                                    .read<RemoFileBloc>()
                                    .add(StartRecording(
                                        remoState is TransmissionStarted
                                            ? remoState.rmsDataStream
                                            : Stream.empty(),
                                        remoState is TransmissionStarted
                                            ? remoState.imuDataStream
                                            : Stream.empty())),
                                onStopPressed: () => context
                                    .read<RemoFileBloc>()
                                    .add(StopRecording()),
                              )),
                    ]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildChartButtons() {
    return BlocBuilder<ChartBloc, ChartState>(
      builder: (context, chartState) => Row(
        children: [
          const Spacer(),
          FilledButton(
            onPressed: () => chartState is LineState
                ? null
                : context.read<ChartBloc>().add(SwitchChart()),
            style: FilledButton.styleFrom(
              fixedSize: Size(
                164.adaptedWidth,
                32.adaptedHeight,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(25.adaptedRadius))),
              backgroundColor: chartState is LineState
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFE5F3F5),
            ),
            child: Text(AppLocalizations.of(context)!.graph_1,
                style: TextStyle(
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w500,
                    color: chartState is LineState
                        ? Colors.white
                        : const Color(0xFF93959B))),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => chartState is RadarState
                ? null
                : Navigator.pushNamed(
                    context, "/remo_transmission/contractions"),
            style: FilledButton.styleFrom(
              fixedSize: Size(
                164.adaptedWidth,
                32.adaptedHeight,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.all(Radius.circular(25.adaptedRadius))),
              backgroundColor: chartState is RadarState
                  ? Theme.of(context).primaryColor
                  : const Color(0xFFE5F3F5),
            ),
            child: Text(AppLocalizations.of(context)!.graph_2,
                style: TextStyle(
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w500,
                    color: chartState is RadarState
                        ? Colors.white
                        : const Color(0xFF93959B))),
          ),
          const Spacer()
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            ChannelButton(color: channelColors[0], text: 'Ch1'),
            const Spacer(),
            ChannelButton(color: channelColors[1], text: 'Ch2'),
            const Spacer(),
            ChannelButton(color: channelColors[2], text: 'Ch3'),
            const Spacer(),
            ChannelButton(color: channelColors[3], text: 'Ch4'),
            const Spacer(),
          ],
        ),
        SizedBox(height: 12.adaptedHeight),
        Row(children: [
          const Spacer(),
          ChannelButton(color: channelColors[4], text: 'Ch5'),
          const Spacer(),
          ChannelButton(color: channelColors[5], text: 'Ch6'),
          const Spacer(),
          ChannelButton(color: channelColors[6], text: 'Ch7'),
          const Spacer(),
          ChannelButton(color: channelColors[7], text: 'Ch8'),
          const Spacer()
        ]),
      ],
    );
  }
}
