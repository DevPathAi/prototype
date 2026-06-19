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

  final report = learningLoopCoverage(file.readAsStringSync());
  if (report == null) {
    stderr.writeln('No lib/learning_loop records found in $lcovPath');
    exitCode = 1;
    return;
  }

  stdout.writeln(
    'lib/learning_loop line coverage: ${report.percent.toStringAsFixed(2)}%',
  );
  if (report.percent < minimum) {
    stderr.writeln(
      'Coverage ${report.percent.toStringAsFixed(2)}% is below $minimum%',
    );
    if (report.uncoveredLines.isNotEmpty) {
      stderr.writeln('Uncovered learning_loop lines:');
      for (final line in report.uncoveredLines) {
        stderr.writeln('- $line');
      }
    }
    exitCode = 1;
  }
}

CoverageReport? learningLoopCoverage(String lcov) {
  var found = false;
  var hit = 0;
  var total = 0;
  var inLearningLoopFile = false;
  var sourcePath = '';
  final uncovered = <String>[];

  for (final line in lcov.split('\n')) {
    if (line.startsWith('SF:')) {
      sourcePath = line.substring(3).replaceAll('\\', '/');
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
    final lineNumber = parts[0];
    final count = int.parse(parts[1]);
    if (count > 0) {
      hit += 1;
    } else {
      uncovered.add('$sourcePath:$lineNumber');
    }
  }

  if (!found || total == 0) {
    return null;
  }
  return CoverageReport(
    hit: hit,
    total: total,
    uncoveredLines: List.unmodifiable(uncovered),
  );
}

class CoverageReport {
  const CoverageReport({
    required this.hit,
    required this.total,
    required this.uncoveredLines,
  });

  final int hit;
  final int total;
  final List<String> uncoveredLines;

  double get percent => hit * 100 / total;
}
