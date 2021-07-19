import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:detective/src/command_saver.dart';
import 'package:detective/src/launcher.dart';

/// Main function to start the debugger
///
/// This is needed to launch the correct desktop application
void main(List<String> args) async {
  var file = File(Directory.current.uri
      .resolve('detective_connect.txt')
      .toFilePath(windows: Platform.isWindows));

  if (!await file.exists()) {
    print(
        'You app doesn\'t seem to be running or you didn\'t launch it with the "--vmservice-out-file=detective_connect.txt" argument\n'
        '\n'
        'Make sure that "${file.path}" exists after you launched your app.');
    exit(22);
  }

  var connectUriString = await file.readAsString();
  var env = <String, String>{
    'CONNECT': connectUriString,
  };

  var parser = ArgParser();
  parser.addOption('key',
      help:
          'The license key you bought at: https://norbertkozsir.gumroad.com/l/detectivedev');

  // A parser for watch commands
  var watchParser = parser.addCommand('watch');
  var callParser = parser.addCommand('call');

  var result = parser.parse(args);

  String command;

  if (result.command != null) {
    if (result.command.name == 'watch') {
      var rest = result.command.rest;
      if (rest.length != 1) {
        print('Please specify the class to watch');
      }
      var className = rest.single;

      command = 'watch $className';
      env['command'] = command;
    } else if (result.command.name == 'call') {
      var rest = result.command.rest;
      if (rest.length != 2) {
        print('Please specify the class and the function to call');
      }
      var className = rest.first;
      var fnName = rest[1];

      command = 'call $className-$fnName';
      env['command'] = command;
    }
  }

  if (result['key'] != null) {
    env['license_key'] = result['key'];
  }

  print('Connecting to $connectUriString');

  var binUri = await getBinUri();

  await CommandSaver().saveCommand(binUri, command);
  await Launcher().launchDetective(binUri, env);
}

Future<Uri> getBinUri() async {
  var packageConfigPath = Platform.script
      .resolve('..')
      .resolve('.dart_tool/')
      .resolve('package_config.json')
      .toFilePath(windows: Platform.isWindows);
  var packageConfigContent = await File(packageConfigPath).readAsString();

  Map<dynamic, dynamic> parsed = json.decode(packageConfigContent);

  var pkg = parsed['packages'].where((it) => it['name'] == 'detective').first;
  String rootUriString = pkg['rootUri'];

  return Uri.parse(rootUriString).resolve('bin/');
}
