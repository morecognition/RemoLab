import 'package:design_sync/design_sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_remo/flutter_remo.dart';
import 'package:remorder/ui/components/loading_loop.dart';

import '../../l10n/app_localizations.dart';

class SavePage extends StatefulWidget {
  const SavePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _SaveState();
  }
}

class _SaveState extends State<SavePage> {
  _SaveState();

  String selectedFileName = "";
  final _formKey = GlobalKey<FormState>();
  late SavePageMode _mode;
  bool _modeInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_modeInitialized) {
      _mode =
          ModalRoute.of(context)?.settings.arguments as SavePageMode? ??
          SavePageMode.rms;
      _modeInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset("assets/page_background.png", fit: BoxFit.cover),
          ),
          Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.transparent,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20.adaptedFontSize,
                fontWeight: FontWeight.w600,
              ),
              toolbarHeight: 65.adaptedHeight,
              title: _getAppTitle(),
            ),
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: EdgeInsets.only(
                right: 16.adaptedWidth,
                left: 16.adaptedWidth,
                top: 80.adaptedHeight,
                bottom: 30.adaptedHeight,
              ),
              child: Center(
                child: _getBuilder(_mode, (context, remoFileState) {
                  if (remoFileState is SavingRecord) {
                    return LoadingLoop();
                  }

                  if (remoFileState is RemoFileReady) {
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) Navigator.pop(context);
                    });
                  }

                  if (remoFileState is RecordSaved ||
                      remoFileState is RemoFileReady) {
                    return Image.asset("assets/check_mark.png");
                  }

                  return _buildSaveScreen();
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getBuilder(
    SavePageMode mode,
    Widget Function(BuildContext, RemoFileState) builder,
  ) {
    switch (mode) {
      case SavePageMode.rms:
        return BlocBuilder<RemoFileBloc, RemoFileState>(builder: builder);

      case SavePageMode.biofeedback:
        return BlocBuilder<ProportionalControlFileBloc, RemoFileState>(
          builder: builder,
        );
    }
  }

  void _sendEvent(SavePageMode mode, RemoFileEvent event) {
    switch (mode) {
      case SavePageMode.rms:
        context.read<RemoFileBloc>().add(event);
        break;

      case SavePageMode.biofeedback:
        context.read<ProportionalControlFileBloc>().add(event);
        break;
    }
  }

  Widget _buildSaveScreen() {
    return Column(
      children: [
        SizedBox(height: 46.adaptedHeight),
        Text(AppLocalizations.of(context)!.insert_file_name),
        SizedBox(height: 15.adaptedHeight),
        _buildForm(),
        Spacer(),
        FilledButton(
          onPressed: () => _saveFile(),
          style: FilledButton.styleFrom(
            fixedSize: Size(343.adaptedWidth, 48.adaptedHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(60.adaptedRadius)),
            ),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          child: Text(
            AppLocalizations.of(context)!.save,
            style: TextStyle(
              fontSize: 20.adaptedFontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 25.adaptedHeight),
        TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (context) => _buildDiscardConfirmDialog(),
          ),
          child: Text(
            AppLocalizations.of(context)!.delete,
            style: TextStyle(
              fontSize: 20.adaptedFontSize,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 26.adaptedHeight),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: TextFormField(
        autocorrect: false,
        enableSuggestions: false,
        textAlign: TextAlign.center,
        onChanged: (String value) {
          selectedFileName = value;
        },
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEDEDF5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFEDEDF5)),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: AppLocalizations.of(context)!.record_name,
          hintStyle: TextStyle(color: Color(0xFFC2C8D2)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return AppLocalizations.of(context)!.you_need_to_name;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDiscardConfirmDialog() {
    return AlertDialog(
      title: null,
      contentPadding: EdgeInsets.all(0),
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.adaptedRadius)),
      ),
      content: SizedBox(
        width: 343.adaptedWidth,
        height: 352.adaptedHeight,
        child: Column(
          children: [
            SizedBox(height: 33.adaptedHeight),
            Image.asset("assets/trash_icon.png"),
            SizedBox(height: 17.adaptedHeight),
            Text(
              AppLocalizations.of(context)!.want_delete,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.adaptedFontSize,
                color: Color(0xFF2B3A51),
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.delete_confirm_text,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 34.adaptedHeight),
            FilledButton(
              onPressed: () {
                _sendEvent(_mode, DiscardRecord());
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(
                fixedSize: Size(163.adaptedWidth, 48.adaptedHeight),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(60.adaptedRadius),
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: TextStyle(
                  fontSize: 20.adaptedFontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 25.adaptedHeight),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  fontSize: 20.adaptedFontSize,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAppTitle() {
    return _getBuilder(_mode, (context, remoFileState) {
      if (remoFileState is RecordSaved || remoFileState is RemoFileReady) {
        return Text(AppLocalizations.of(context)!.saved);
      }

      if (remoFileState is SavingRecord) {
        return Text(AppLocalizations.of(context)!.saving);
      }

      return Text(AppLocalizations.of(context)!.want_save);
    });
  }

  void _saveFile() {
    _sendEvent(_mode, SaveRecord(selectedFileName));
  }
}

enum SavePageMode { rms, biofeedback }
