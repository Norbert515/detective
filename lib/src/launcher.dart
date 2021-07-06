import 'dart:io';

import 'package:path/path.dart';

class Launcher {

  Future<void> launchDetective(Uri binUri, Map<String, String> env) async {
    if(Platform.isWindows) {
      var filePath = join(binUri.resolve('windows').toFilePath(windows: true), 'debuggable.exe');
      await Process.start(filePath, [], workingDirectory: Directory.current.path, environment: env);
    } else if(Platform.isMacOS) {
      var filePath = join(binUri.resolve('macos').toFilePath(), 'detective.app');
      var macosContent = binUri.resolve('macos/').resolve('detective.app/').resolve('Contents/').resolve('MacOS/').resolve('detective');
      await Process.start('chmod', ['+x', filePath]);
      await Process.start('chmod', ['+x', macosContent.toFilePath()]);
      await Process.start('open', ['-a', filePath], workingDirectory: Directory.current.path, environment: env);
    } else if(Platform.isLinux) {
      var filePath = join(binUri.resolve('linux').toFilePath(), 'debuggable');
      await Process.start('chmod', ['+x', filePath]);
      await Process.start(filePath, [], workingDirectory: Directory.current.path, environment: env);
    }
  }
}