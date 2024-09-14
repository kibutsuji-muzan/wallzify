import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class FileStorage {
  static Future<String> getExternalDocumentPath() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    Directory _directory = Directory("dir");
    if (Platform.isAndroid) {
      _directory = Directory("/storage/emulated/0/Download/Wallzify");
    } else {
      _directory = await getApplicationDocumentsDirectory();
    }

    final exPath = _directory.path;
    print("Saved Path: $exPath");
    await Directory(exPath).create(recursive: true);
    return exPath;
  }

  static Future<String> get _localPath async {
    final String directory = await getExternalDocumentPath();
    return directory;
  }

  static Future<File> downloadAndSaveImage(Uint8List bytes) async {
    String filePath = join(await _localPath, '${getRandomString(35)}.jpeg');
    File file = File(filePath);

    try {
      await file.writeAsBytes(bytes, flush: true);
      return file; // Move the return statement inside the try block
    } catch (e) {
      throw e; // Rethrow the exception to handle it elsewhere if needed
    }
  }
}

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
