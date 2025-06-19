import 'dart:ui';

import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';

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
              Expanded(child: Text(
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
      body: Container(

      )
    );
  }
}
