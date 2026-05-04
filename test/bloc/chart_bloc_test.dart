import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remorder/bloc/chart/chart_bloc.dart';

void main() {
  group('ChartBloc', () {
    test('initial state is LineState', () {
      expect(ChartBloc().state, isA<LineState>());
    });

    blocTest<ChartBloc, ChartState>(
      'emits RadarState when SwitchChart is added from initial LineState',
      build: () => ChartBloc(),
      act: (bloc) => bloc.add(SwitchChart()),
      expect: () => [isA<RadarState>()],
    );

    blocTest<ChartBloc, ChartState>(
      'toggles back to LineState when SwitchChart is added twice',
      build: () => ChartBloc(),
      act: (bloc) {
        bloc.add(SwitchChart());
        bloc.add(SwitchChart());
      },
      expect: () => [isA<RadarState>(), isA<LineState>()],
    );

    blocTest<ChartBloc, ChartState>(
      'cycles correctly through multiple toggles',
      build: () => ChartBloc(),
      act: (bloc) {
        for (var i = 0; i < 4; i++) {
          bloc.add(SwitchChart());
        }
      },
      expect: () => [
        isA<RadarState>(),
        isA<LineState>(),
        isA<RadarState>(),
        isA<LineState>(),
      ],
    );
  });
}
