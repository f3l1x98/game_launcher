import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

// TODO idea: change to non static with const constructor in order to pass into constructor of other with default const ProgramExecutor()
class ProgramExecutor {
  static Future<Process> execute(
    String executable, {
    List<String>? args,
    bool runInShell = false,
    Function(String)? onStdoutData,
    Function(String)? onStderrData,
  }) {
    return _execute(
      executable,
      args: args,
      runInShell: runInShell,
      onStdoutData: onStdoutData,
      onStderrData: onStderrData,
    );
  }

  static Future<Process> executeFile(
    File executable, {
    List<String>? args,
    bool runInShell = false,
    Function(String)? onStdoutData,
    Function(String)? onStderrData,
  }) {
    return _execute(
      executable.absolute.path,
      args: args,
      runInShell: runInShell,
      onStdoutData: onStdoutData,
      onStderrData: onStderrData,
    );
  }

  static Future<Process> _execute(
    String executable, {
    List<String>? args,
    bool runInShell = false,
    Function(String)? onStdoutData,
    Function(String)? onStderrData,
  }) async {
    if (!(await File(executable).exists())) {
      throw ExecutableNotFoundException(executable);
    }
    final process = await Process.start(
      executable,
      args ?? [],
      runInShell: runInShell,
      workingDirectory: p.dirname(executable),
    );
    // TODO handle non utf8 -> try utf16/utf32 https://pub.dev/packages/charset OR perhaps https://pub.dev/packages/charset_converter
    // TODO utf16 crashes if multiple try to use it: Unsupported operation: This converter does not support chunked conversions: Instance of 'Utf16Decoder'
    //  -> THIS ALSO PAUSES THE PROGRAM ITSELF
    if (onStdoutData != null) {
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(onStdoutData);
    }
    if (onStderrData != null) {
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(onStderrData);
    }

    process.exitCode.then((code) {
      if (code != 0) {
        throw ExecutionException("Program exited with code $code");
      }
    });
    return process;
  }
}

class ExecutionException implements Exception {
  String message;
  ExecutionException(this.message);
}

class ExecutableNotFoundException implements Exception {
  String executable;
  ExecutableNotFoundException(this.executable);
}
