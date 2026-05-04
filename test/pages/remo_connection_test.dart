import 'package:bloc_test/bloc_test.dart';
import 'package:design_sync/design_sync.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:remorder/l10n/app_localizations.dart';
import 'package:remorder/ui/components/loading_ring.dart';
import 'package:remorder/ui/pages/remo_connection.dart';

class MockBluetoothBloc extends MockBloc<BluetoothEvent, BluetoothState>
    implements BluetoothBloc {}

class MockRemoBloc extends MockBloc<RemoEvent, RemoState>
    implements RemoBloc {}

// Fallbacks required by mocktail for any() matchers on abstract types.
class _FakeBluetoothEvent extends Fake implements BluetoothEvent {}
class _FakeRemoEvent extends Fake implements RemoEvent {}

Widget _buildTestWidget({
  required BluetoothBloc bluetoothBloc,
  required RemoBloc remoBloc,
  Future<bool> Function()? bluetoothChecker,
}) {
  DesignSync.initialize(figmaCanvasSize: const Size(375, 812));
  return MultiBlocProvider(
    providers: [
      BlocProvider<BluetoothBloc>.value(value: bluetoothBloc),
      BlocProvider<RemoBloc>.value(value: remoBloc),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RemoConnection(
        // SynchronousFuture resolves during the first build so LoadingRing
        // timers are created during pumpWidget (not mid-pump).
        bluetoothChecker: bluetoothChecker ?? () => SynchronousFuture(true),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeBluetoothEvent());
    registerFallbackValue(_FakeRemoEvent());
  });

  late MockBluetoothBloc bluetoothBloc;
  late MockRemoBloc remoBloc;

  setUp(() {
    bluetoothBloc = MockBluetoothBloc();
    remoBloc = MockRemoBloc();
    // MockBloc.close() must be stubbed because mocktail returns null by default.
    when(() => bluetoothBloc.close()).thenAnswer((_) async {});
    when(() => remoBloc.close()).thenAnswer((_) async {});
  });

  tearDown(() {
    bluetoothBloc.close();
    remoBloc.close();
  });

  void stubBluetoothState(BluetoothState state) {
    when(() => bluetoothBloc.state).thenReturn(state);
    // Empty stream avoids BlocBuilder rebuilds that recreate LoadingRing mid-pump.
    when(() => bluetoothBloc.stream).thenAnswer((_) => const Stream.empty());
  }

  void stubRemoState(RemoState state) {
    when(() => remoBloc.state).thenReturn(state);
    when(() => remoBloc.stream).thenAnswer((_) => const Stream.empty());
  }

  group('RemoConnection', () {
    testWidgets('shows loading ring while discovering devices', (tester) async {
      stubBluetoothState(DiscoveringDevices());
      stubRemoState(Disconnected());

      await tester.pumpWidget(_buildTestWidget(
        bluetoothBloc: bluetoothBloc,
        remoBloc: remoBloc,
      ));
      // Advance past the 1500ms LoadingRing startDelay timer.
      await tester.pump(const Duration(milliseconds: 1600));

      expect(find.byType(LoadingRing), findsWidgets);
    });

    testWidgets('shows device list when devices are discovered', (tester) async {
      stubBluetoothState(
          DiscoveredDevices(['RemoDevice1', 'RemoDevice2'], ['AA:BB', 'CC:DD']));
      stubRemoState(Disconnected());

      await tester.pumpWidget(_buildTestWidget(
        bluetoothBloc: bluetoothBloc,
        remoBloc: remoBloc,
      ));
      await tester.pump();

      expect(find.text('RemoDevice1'), findsOneWidget);
      expect(find.text('RemoDevice2'), findsOneWidget);
    });

    testWidgets('shows loading ring while connecting', (tester) async {
      stubBluetoothState(BluetoothInitial());
      stubRemoState(Connecting());

      await tester.pumpWidget(_buildTestWidget(
        bluetoothBloc: bluetoothBloc,
        remoBloc: remoBloc,
      ));
      await tester.pump(const Duration(milliseconds: 1600));

      expect(find.byType(LoadingRing), findsWidgets);
    });

    testWidgets('hides device list when discovery fails', (tester) async {
      stubBluetoothState(DiscoveryError());
      stubRemoState(Disconnected());

      await tester.pumpWidget(_buildTestWidget(
        bluetoothBloc: bluetoothBloc,
        remoBloc: remoBloc,
      ));
      await tester.pump();

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('hides device list when bluetooth is off', (tester) async {
      stubBluetoothState(DiscoveringDevices());
      stubRemoState(Disconnected());

      // Larger view to avoid overflow errors from the error widget's layout.
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_buildTestWidget(
        bluetoothBloc: bluetoothBloc,
        remoBloc: remoBloc,
        bluetoothChecker: () => SynchronousFuture(false),
      ));
      await tester.pump();

      expect(find.byType(ListView), findsNothing);
      expect(find.byType(LoadingRing), findsNothing);
    });

    testWidgets('dispatches OnConnectDevice when device is tapped',
        (tester) async {
      stubBluetoothState(
          DiscoveredDevices(['RemoDevice'], ['AA:BB:CC:DD:EE:FF']));
      stubRemoState(Disconnected());

      await tester.pumpWidget(_buildTestWidget(
        bluetoothBloc: bluetoothBloc,
        remoBloc: remoBloc,
      ));
      await tester.pump();

      await tester.tap(find.text('RemoDevice'));
      await tester.pump();

      verify(() => remoBloc.add(any(that: isA<OnConnectDevice>()))).called(1);
    });
  });
}
