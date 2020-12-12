import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> getDirectory() async {
  Directory _directory;
  if (Platform.isIOS) {
    _directory = await getApplicationDocumentsDirectory();
  } else {
    _directory = await getExternalStorageDirectory();
  }
  return '${_directory.path}/${DateTime.now().millisecondsSinceEpoch.toString()}';
}
