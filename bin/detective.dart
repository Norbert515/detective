import 'dart:io';
import 'package:path/path.dart';

/// Main function to start the debugger
///
/// This is needed to launch the correct desktop application
void main() async {

  var file = File(Directory.current.uri.resolve('detective_connect.txt').toFilePath(windows: Platform.isWindows));

  if(!await file.exists()) {
    print('You app doesn\'t seem to be running or you didn\'t launch it with the "--vmservice-out-file=detective_connect.txt --disable-service-auth-codes" arguments\n'
        '\n'
        'Make sure that "${file.path}" exists after you launched your app.');
    exit(22);
  }

  if(Platform.isWindows) {
    var filePath = join(Platform.script.resolve('app').toFilePath(windows: true), 'debuggable.exe');
    await Process.start(filePath, [], workingDirectory: Directory.current.path);
  }
}