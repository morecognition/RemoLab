import 'dart:io';

import 'package:design_sync/design_sync.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../l10n/app_localizations.dart';

class PairingPage extends StatelessWidget {
  const PairingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          "assets/page_background.png",
          width: 375.adaptedWidth,
          height: 812.adaptedHeight,
          fit: BoxFit.cover,
        ),
        Scaffold(
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20.adaptedFontSize,
                fontWeight: FontWeight.w600),
            toolbarHeight: 65.adaptedHeight,
            title: Center(
                child: Text(AppLocalizations.of(context)!.welcome,
                    textAlign: TextAlign.center)),
          ),
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: 15.adaptedHeight),
                  child: Text(AppLocalizations.of(context)!.wear_remo),
                ),
                Text(AppLocalizations.of(context)!.turn_on_bt),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 25.adaptedHeight),
                  child: Image.asset(
                    'assets/wear_remo.png',
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 40.adaptedHeight),
                  child: Image.asset(
                    'assets/bluetooth_connection.png',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    goToNextPage(context);
                  },
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
                  child: Text(AppLocalizations.of(context)!.start_pairing,
                      style: TextStyle(
                          fontSize: 20.adaptedFontSize,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            top: 38.adaptedHeight,
            left: 16.adaptedWidth,
            child: BlocBuilder<RemoFileBloc, RemoFileState>(
                builder: (context, remoFileState) {
              return IconButton(
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
                      width: 36.adaptedWidth, height: 36.adaptedHeight));
            }))
      ],
    );
  }

  void goToNextPage(BuildContext context) async {
    var bluetoothScan = PermissionStatus.granted;
    var bluetoothConnect = PermissionStatus.granted;
    var locationUse = PermissionStatus.granted;

    if (Platform.isAndroid) {
      bluetoothScan = await Permission.bluetoothScan.request();
      bluetoothConnect = await Permission.bluetoothConnect.request();

      var androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 30) {
        locationUse = await Permission.locationWhenInUse.request();
      }
    } else if (Platform.isIOS) {
      // iOS mostra il prompt Bluetooth solo quando si avvia lo scan/connessione.
      // Non bloccare la navigazione sui permessi location.
      locationUse = PermissionStatus.granted;
    }

    bool allGranted = bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        locationUse.isGranted;

    if (allGranted && context.mounted) {
      //Set bt state to initial
      context.read<BluetoothBloc>().add(OnReset());
      Navigator.pushNamed(context, '/pairing/connection');
    } else {
      if (context.mounted) {
        // Controlla se qualche permesso è permanentemente negato
        bool hasPermamentlyDenied = locationUse.isPermanentlyDenied;

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.permission_bt),
              content: Text(hasPermamentlyDenied
                  ? 'Il permesso di posizione è stato negato. Per utilizzare l\'app e cercare dispositivi Bluetooth, vai nelle Impostazioni e abilita il permesso di Posizione.'
                  : AppLocalizations.of(context)!.permission_bt_request),
              actions: <Widget>[
                if (hasPermamentlyDenied)
                  TextButton(
                    onPressed: () {
                      openAppSettings();
                      Navigator.pop(context);
                    },
                    child: Text('Apri Impostazioni'),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(hasPermamentlyDenied
                      ? 'Annulla'
                      : AppLocalizations.of(context)!.ok),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
