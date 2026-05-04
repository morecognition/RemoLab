import 'dart:async';

import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';
import 'package:remorder/ui/components/channel_button.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../l10n/app_localizations.dart';
import '../components/data_chart.dart';

class RemoPlayback extends StatefulWidget {
  const RemoPlayback({super.key});

  @override
  State<RemoPlayback> createState() => _RemoPlaybackState();
}

class _RemoPlaybackState extends State<RemoPlayback> {
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
          child: BlocBuilder<RemoFileBloc, RemoFileState>(
            builder: (context, remoFileState) {
              var pageName = AppLocalizations.of(context)!.data_visualization;

              if (remoFileState is RmsRecordOpened) {
                pageName = remoFileState.filePath.split('/').last;
              }

              return Text(pageName,
                  style: TextStyle(
                      color: const Color(0xFF2B3A51),
                      fontSize: 20.adaptedFontSize,
                      fontWeight: FontWeight.w700));
            },
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF6F7FF),
      body: BlocProvider<ChartBloc>(
        create: (context) => ChartBloc(),
        child: BlocBuilder<RemoFileBloc, RemoFileState>(
          builder: (builderContext, remoFileState) {
            return Center(
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
                      child: remoFileState is RmsRecordOpened
                          ? DataChart(
                              rmsDataStream:
                                  Stream.fromIterable(remoFileState.rmsData),
                              colors: channelColors,
                              showAll: true,
                              key: const Key("remo chart"))
                          : DataChart(
                              rmsDataStream: Stream.empty(),
                              colors: channelColors,
                              key: const Key("empty chart")),
                    ),
                    SizedBox(height: 15.adaptedHeight),
                  ]),
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
            onPressed: () {},
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
            child: Text(AppLocalizations.of(context)!.graph_2,
                style: TextStyle(
                    fontSize: 20.adaptedFontSize,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF93959B))),
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
