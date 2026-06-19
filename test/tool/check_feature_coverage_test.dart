import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_feature_coverage.dart';

void main() {
  test('computes learning_loop coverage from lcov records', () {
    const lcov = '''
SF:lib/learning_loop/reducer.dart
DA:1,1
DA:2,0
SF:lib/main.dart
DA:1,0
''';

    final report = learningLoopCoverage(lcov);

    expect(report!.percent, 50);
    expect(report.uncoveredLines, ['lib/learning_loop/reducer.dart:2']);
  });
}
