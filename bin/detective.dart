import 'dart:convert';
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


  var binUri = await getBinUri();

  if(Platform.isWindows) {
    var filePath = join(binUri.resolve('windows').toFilePath(windows: true), 'debuggable.exe');
    await Process.start(filePath, [], workingDirectory: Directory.current.path);
  } else if(Platform.isMacOS) {
    var filePath = join(binUri.resolve('macos').toFilePath(), 'debuggable.app');
    await Process.start('chmod', ['+x', filePath]);
    await Process.start('open', ['-a', filePath], workingDirectory: Directory.current.path);
  } else if(Platform.isLinux) {
    var filePath = join(binUri.resolve('linux').toFilePath(), 'debuggable');
    await Process.start('chmod', ['+x', filePath]);
    await Process.start(filePath, [], workingDirectory: Directory.current.path);
  }
}

Future<Uri> getBinUri() async {

  var packageConfigPath = Platform.script.resolve('..').resolve('.dart_tool/').resolve('package_config.json').toFilePath(windows: Platform.isWindows);
  var packageConfigContent = await File(packageConfigPath).readAsString();

  Map<dynamic, dynamic> parsed = json.decode(packageConfigContent);

  var pkg = parsed['packages'].where((it) => it['name'] == 'detective').first;
  String rootUriString = pkg['rootUri'];

  return Uri.parse(rootUriString).resolve('bin');
}