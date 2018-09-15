// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library dartdoc.utils;

import 'dart:async';
import 'dart:io' hide Platform;

import 'package:platform/platform.dart';
import 'package:process/process.dart';

final RegExp leadingWhiteSpace = new RegExp(r'^([ \t]*)[^ ]');

String stripCommonWhitespace(String str) {
  StringBuffer buf = new StringBuffer();
  List<String> lines = str.split('\n');
  int minimumSeen;

  for (String line in lines) {
    if (line.isNotEmpty) {
      Match m = leadingWhiteSpace.firstMatch(line);
      if (m != null) {
        if (minimumSeen == null || m.group(1).length < minimumSeen) {
          minimumSeen = m.group(1).length;
        }
      }
    }
  }
  minimumSeen ??= 0;
  int lineno = 1;
  for (String line in lines) {
    if (line.length >= minimumSeen) {
      buf.write('${line.substring(minimumSeen)}\n');
    } else {
      if (lineno < lines.length) {
        buf.write('\n');
      }
    }
    ++lineno;
  }
  return buf.toString();
}

String stripComments(String str) {
  bool cStyle = false;
  if (str == null) return null;
  StringBuffer buf = new StringBuffer();

  if (str.startsWith('///')) {
    str = stripCommonWhitespace(str);
    for (String line in str.split('\n')) {
      if (line.startsWith('/// ')) {
        buf.write('${line.substring(4)}\n');
      } else if (line.startsWith('///')) {
        buf.write('${line.substring(3)}\n');
      } else {
        buf.write('$line\n');
      }
    }
  } else {
    if (str.startsWith('/**')) {
      str = str.substring(3);
      cStyle = true;
    }
    if (str.endsWith('*/')) {
      str = str.substring(0, str.length - 2);
    }
    str = stripCommonWhitespace(str);
    for (String line in str.split('\n')) {
      if (cStyle && line.startsWith('* ')) {
        buf.write('${line.substring(2)}\n');
      } else if (cStyle && line.startsWith('*')) {
        buf.write('${line.substring(1)}\n');
      } else {
        buf.write('$line\n');
      }
    }
  }
  return buf.toString().trim();
}

String truncateString(String str, int length) {
  if (str != null && str.length > length) {
    // Do not call this on unsanitized HTML.
    assert(!str.contains("<"));
    return '${str.substring(0, length)}…';
  }
  return str;
}

String pluralize(String word, int count) => count == 1 ? word : '${word}s';

abstract class ToolRunner {
  ToolRunner._();

  factory ToolRunner.create(String toolPath,
      {List<String> args = const <String>[], String content = ""}) {
    if (testingFake != null) {
      return testingFake;
    }
    return new ConcreteToolRunner._(toolPath, args: args, content: content);
  }

  static ToolRunner testingFake;

  String get stderr;
  String get stdout;
  int get exitCode;

  Future<bool> run();
}

class FakeToolRunner extends ToolRunner {
  FakeToolRunner(this.toolPath,
      {this.args = const <String>[], this.content = ""})
      : assert(args != null),
        assert(content != null),
        assert(toolPath != null && toolPath.isNotEmpty),
        super._();

  final String toolPath;
  final List<String> args;
  final String content;

  @override
  int exitCode = 0;

  @override
  Future<bool> run() async => exitCode == 0;

  @override
  String stderr = "";

  @override
  String stdout = "";
}

class ConcreteToolRunner extends ToolRunner {
  ConcreteToolRunner._(this.toolPath,
      {this.args = const <String>[], this.content = ""})
      : assert(args != null),
        assert(content != null),
        assert(toolPath != null && toolPath.isNotEmpty),
        super._();

  final String toolPath;
  final List<String> args;
  final String content;

  String _stderr = '';
  String _stdout = '';
  int _exitCode = 0;

  @override
  String get stderr => _stderr;
  @override
  String get stdout => _stdout;
  @override
  int get exitCode => _exitCode;

  @override
  Future<bool> run() async {
    try {
      ProcessRunner runner = new ProcessRunner();
      var controller = new StreamController<List<int>>();
      controller.add(content.codeUnits);
      List<int> output = await runner.runProcess([toolPath] + args,
          printOutput: false, failOk: false, stdin: controller.stream);
      _stdout = new String.fromCharCodes(output);
      _exitCode = 0;
    } on ProcessRunnerException catch (exception) {
      _stderr = exception.result?.stderr ?? '';
      _exitCode = exception.exitCode;
      return false;
    }
    return true;
  }
}

/// Exception class for when a process fails to run, so we can catch
/// it and provide something more readable than a stack trace.
class ProcessRunnerException implements Exception {
  ProcessRunnerException(this.message, [this.result]);

  final String message;
  final ProcessResult result;
  int get exitCode => result?.exitCode ?? -1;

  @override
  String toString() {
    String output = runtimeType.toString();
    if (message != null) {
      output += ': $message';
    }
    final String stderr = result?.stderr ?? '';
    if (stderr.isNotEmpty) {
      output += ':\n$stderr';
    }
    return output;
  }
}

/// A helper class for classes that want to run a process, optionally have the
/// stderr and stdout reported as the process runs, and capture the stdout
/// properly without dropping any.
class ProcessRunner {
  ProcessRunner({
    ProcessManager processManager,
    this.defaultWorkingDirectory,
    this.platform: const LocalPlatform(),
  }) : processManager = processManager ?? const LocalProcessManager() {
    environment = new Map<String, String>.from(platform.environment);
  }

  /// The platform to use for a starting environment.
  final Platform platform;

  /// Set the [processManager] in order to inject a test instance to perform
  /// testing.
  final ProcessManager processManager;

  /// Sets the default directory used when `workingDirectory` is not specified
  /// to [runProcess].
  final Directory defaultWorkingDirectory;

  /// The environment to run processes with.
  Map<String, String> environment;

  /// Run the command and arguments in `commandLine` as a sub-process from
  /// `workingDirectory` if set, or the [defaultWorkingDirectory] if not. Uses
  /// [Directory.current] if [defaultWorkingDirectory] is not set.
  ///
  /// Set `failOk` if [runProcess] should not throw an exception when the
  /// command completes with a a non-zero exit code.
  Future<List<int>> runProcess(
    List<String> commandLine, {
    Directory workingDirectory,
    bool printOutput: true,
    bool failOk: false,
    Stream<List<int>> stdin,
  }) async {
    workingDirectory ??= defaultWorkingDirectory ?? Directory.current;
    if (printOutput) {
      stderr.write(
          'Running "${commandLine.join(' ')}" in ${workingDirectory.path}.\n');
    }
    final List<int> output = <int>[];
    final Completer<Null> stdoutComplete = new Completer<Null>();
    final Completer<Null> stderrComplete = new Completer<Null>();
    final Completer<Null> stdinComplete = new Completer<Null>();

    Process process;
    Future<int> allComplete() async {
      if (stdin != null) {
        await stdinComplete.future;
        await process.stdin.close();
      }
      await stderrComplete.future;
      await stdoutComplete.future;
      return process.exitCode;
    }

    try {
      process = await processManager.start(
        commandLine,
        workingDirectory: workingDirectory.absolute.path,
        environment: environment,
      );
      if (stdin != null) {
        stdin.listen((List<int> data) {
          process.stdin.add(data);
        }, onDone: () async => stdinComplete.complete());
      }
      process.stdout.listen(
        (List<int> event) {
          output.addAll(event);
          if (printOutput) {
            stdout.add(event);
          }
        },
        onDone: () async => stdoutComplete.complete(),
      );
      if (printOutput) {
        process.stderr.listen(
          (List<int> event) {
            stderr.add(event);
          },
          onDone: () async => stderrComplete.complete(),
        );
      } else {
        stderrComplete.complete();
      }
    } on ProcessException catch (e) {
      final String message =
          'Running "${commandLine.join(' ')}" in ${workingDirectory.path} '
          'failed with:\n${e.toString()}';
      throw new ProcessRunnerException(message);
    } on ArgumentError catch (e) {
      final String message =
          'Running "${commandLine.join(' ')}" in ${workingDirectory.path} '
          'failed with:\n${e.toString()}';
      throw new ProcessRunnerException(message);
    }

    final int exitCode = await allComplete();
    if (exitCode != 0 && !failOk) {
      final String message =
          'Running "${commandLine.join(' ')}" in ${workingDirectory.path} failed';
      throw new ProcessRunnerException(
        message,
        new ProcessResult(0, exitCode, null, 'returned $exitCode'),
      );
    }
    return output;
  }
}

typedef AsyncMappingFunction = Future<String> Function(Match match);

/// Allows the equivalent of replaceAllMapped, but using an async mapping function.
Future<String> replaceAllMappedAsync(String source, RegExp expression, AsyncMappingFunction mapper) async {
  List<String> replacements = [];
  for (Match match in expression.allMatches(source)) {
    replacements.add(await mapper(match));
  }
  int index = 0;
  return source.replaceAllMapped(expression, (Match match) => replacements[index++]);
}