

import 'dart:io';

import 'package:uuid/uuid.dart';

/// To transfer commands into detective, files are used.
///
/// Each command creates a new file with a random uuid. The running detective
/// application can listen to file creations and execute the commands in response to that
class CommandSaver {

  Future<void> saveCommand(Uri binUri, String command) async {
    if(command == null) {
      return;
    }

    var fileName = '${Uuid().v4()}.detectivecmd';
    var file = File.fromUri(binUri.resolve(fileName));
    await file.create();
    await file.writeAsString(command);

  }
}