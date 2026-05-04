import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothState;
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/components/loading_ring.dart';

import '../../l10n/app_localizations.dart';

class RemoConnection extends StatefulWidget {
  const RemoConnection({super.key});

  @override
  State<RemoConnection> createState() => _RemoConnectionState();
}

class _RemoConnectionState extends State<RemoConnection> {
  late Future<bool> _isBluetoothOnFuture;
  bool _navigatingToHome = false;

  @override
  void initState() {
    super.initState();
    _isBluetoothOnFuture = _checkBluetoothIsOn();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.read<BluetoothBloc>().state is BluetoothInitial) {
        context.read<BluetoothBloc>().add(OnStartDiscovery());
      }
    });
  }

  Future<bool> _checkBluetoothIsOn() async {
    return await FlutterBluePlus.adapterState.first ==
        BluetoothAdapterState.on;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
        builder: (context, bluetoothState) {
      return BlocBuilder<RemoBloc, RemoState>(builder: (context, remoState) {
        return Stack(
          children: [
            SizedBox.expand(
              child: Image.asset(
                "assets/page_background.png",
                fit: BoxFit.cover,
              ),
            ),
            Scaffold(
                appBar: AppBar(
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    backgroundColor: Colors.transparent,
                    titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 20.adaptedFontSize,
                        fontWeight: FontWeight.w600),
                    toolbarHeight: 65.adaptedHeight,
                    title: _getAppTitle(bluetoothState, remoState)),
                backgroundColor: Colors.transparent,
                body: FutureBuilder<bool>(
                    future: _isBluetoothOnFuture,
                    builder: (context, AsyncSnapshot<bool> snapshot) {
                      if (remoState is Disconnected) {
                        var isBluetoothOn =
                            snapshot.data != null && snapshot.data!;
                        if (!isBluetoothOn) {
                          return _buildParingFailedWidget(context);
                        }
                        if (bluetoothState is DiscoveringDevices) {
                          return _buildWaitingWidget();
                        } else if (bluetoothState is DiscoveredDevices) {
                          if (bluetoothState.deviceNames.isEmpty) {
                            return _buildParingFailedWidget(context);
                          } else {
                            return _buildDeviceListWidget(
                                context, bluetoothState);
                          }
                        } else if (bluetoothState is DiscoveryError) {
                          return _buildParingFailedWidget(context);
                        } else {
                          return Text("$bluetoothState");
                        }
                      } else if (remoState is Connecting) {
                        return _buildWaitingWidget();
                      } else if (remoState is Connected) {
                        return _buildParingSuccessfulWidget();
                      } else if (remoState is ConnectionError) {
                        return _buildParingFailedWidget(context);
                      } else {
                        return Text("$remoState");
                      }
                    })),
          ],
        );
      });
    });
  }

  Widget _getAppTitle(BluetoothState bluetoothState, RemoState remoState) {
    return FutureBuilder<bool>(
        future: _isBluetoothOnFuture,
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (remoState is Disconnected) {
              var isBluetoothOn = snapshot.data != null && snapshot.data!;
              if (!isBluetoothOn) {
                return Text(AppLocalizations.of(context)!.pairing_fail);
              }
              if (bluetoothState is DiscoveringDevices) {
                return Text(AppLocalizations.of(context)!.looking_for_remo);
              } else if (bluetoothState is DiscoveredDevices) {
                if (bluetoothState.deviceNames.isEmpty) {
                  return Text(AppLocalizations.of(context)!.pairing_fail);
                } else {
                  return Text(AppLocalizations.of(context)!.choose_device);
                }
              } else if (bluetoothState is DiscoveryError) {
                return Text(AppLocalizations.of(context)!.pairing_fail);
              } else {
                return Text("$bluetoothState");
              }
            } else if (remoState is Connecting) {
              return Text(AppLocalizations.of(context)!.pairing);
            } else if (remoState is Connected) {
              return Text(AppLocalizations.of(context)!.pairing_successful);
            } else if (remoState is ConnectionError) {
              return Text(AppLocalizations.of(context)!.pairing_fail);
            } else {
              return Text("$remoState");
            }
          }
          return const SizedBox.shrink();
        });
  }

  Widget _buildWaitingWidget() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: <Widget>[
            Image.asset(
              'assets/remo_icon.png',
            ),
            const LoadingRing(),
            const LoadingRing(startDelay: Duration(milliseconds: 1500))
          ])
        ],
      ),
    );
  }

  Widget _buildDeviceListWidget(
      BuildContext context, DiscoveredDevices bluetoothState) {
    return Padding(
      padding: EdgeInsets.only(top: 70.adaptedHeight),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: List.generate(bluetoothState.deviceNames.length, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(
                vertical: 8.adaptedHeight, horizontal: 17.adaptedWidth),
            child: ListTile(
              leading: Image.asset("assets/remo.png"),
              title: Text(
                bluetoothState.deviceNames[index],
                style: const TextStyle(
                    color: Color(0xFF2B3A51), fontWeight: FontWeight.w600),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.adaptedRadius),
              ),
              tileColor: const Color(0x6680D0D4),
              onTap: () {
                context.read<RemoBloc>().add(
                      OnConnectDevice(bluetoothState.deviceAddresses[index],
                          bluetoothState.deviceNames[index]),
                    );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildParingSuccessfulWidget() {
    if (!_navigatingToHome) {
      _navigatingToHome = true;
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        Navigator.pop(context);
        Navigator.pushNamed(context, "/home");
      });
    }
    return Center(
        child: Column(children: [
      SizedBox(height: 200.adaptedHeight),
      Image.asset(
        'assets/remo_success.png',
      ),
    ]));
  }

  Widget _buildParingFailedWidget(BuildContext context) {
    return Center(
        child: Column(children: [
      SizedBox(height: 200.adaptedHeight),
      Image.asset(
        'assets/remo_fail.png',
      ),
      SizedBox(height: 170.adaptedHeight),
      Text(AppLocalizations.of(context)!.wear_remo),
      SizedBox(height: 10.adaptedHeight),
      Text(AppLocalizations.of(context)!.turn_on_bt),
      SizedBox(height: 42.adaptedHeight),
      FilledButton(
        onPressed: () {
          Navigator.pop(context);
        },
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
        child: Text(AppLocalizations.of(context)!.try_again,
            style: TextStyle(
                fontSize: 20.adaptedFontSize, fontWeight: FontWeight.w600)),
      ),
    ]));
  }
}
