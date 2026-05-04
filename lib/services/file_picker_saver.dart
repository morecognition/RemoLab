import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_remo/flutter_remo.dart';

class FilePickerSaver extends FileSaver {
  @override
  Future<void> save(String name, Uint8List bytes) async {
    await FilePicker.platform.saveFile(
      fileName: name,
      type: FileType.custom,
      allowedExtensions: ['csv'],
      bytes: bytes,
    );
  }
}
