import 'dart:io';

void main(List<String> args) {
  final lcovPath = args.isEmpty ? 'coverage/lcov.info' : args.first;
  final minimum = args.length >= 2 ? double.parse(args[1]) : 100.0;
  final file = File(lcovPath);
  if (!file.existsSync()) {
    stderr.writeln('Coverage file not found: $lcovPath');
    exitCode = 1;
    return;
  }

  final coverage = learningLoopCoverage(file.readAsStringSync());
  if (coverage == null) {
    stderr.writeln('No lib/learning_loop records found in $lcovPath');
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'lib/learning_loop line coverage: ${coverage.toStringAsFixed(2)}%',
  );
  if (coverage < minimum) {
    stderr.writeln(
      'Coverage ${coverage.toStringAsFixed(2)}% is below $minimum%',
    );
    exitCode = 1;
  }
}

double? learningLoopCoverage(String lcov) {
  var found = false;
  var hit = 0;
  var total = 0;
  var inLearningLoopFile = false;

  for (final line in lcov.split('\n')) {
    if (line.startsWith('SF:')) {
      final sourcePath = line.substring(3).replaceAll('\\', '/');
      inLearningLoopFile = sourcePath.contains('lib/learning_loop/');
      if (inLearningLoopFile) {
        found = true;
      }
      continue;
    }
    if (!inLearningLoopFile || !line.startsWith('DA:')) {
      continue;
    }
    final parts = line.substring(3).split(',');
    if (parts.length != 2) {
      continue;
    }
    total += 1;
    if (int.parse(parts[1]) > 0) {
      hit += 1;
    }
  }

  if (!found || total == 0) {
    return null;
  }
  return hit * 100 / total;
}
