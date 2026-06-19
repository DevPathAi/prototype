import 'package:devpath_prototype/learning_loop/fixtures.dart';
import 'package:devpath_prototype/learning_loop/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scenario catalog validates the approved four-field LCS contract', () {
    final result = validateScenarioCatalog();

    expect(result.isValid, isTrue);
    expect(
      result.scenario!.contextFields.map((field) => field.id).toSet(),
      ContextFieldId.values.toSet(),
    );
    expect(
      result.scenario!.contextFields
          .singleWhere((field) => field.id == ContextFieldId.recentErrors)
          .defaultIncluded,
      isFalse,
    );
  });

  test('sensitive fixture patterns are rejected', () {
    expect(isSensitiveFixtureValue('email user@example.com'), isTrue);
    expect(isSensitiveFixtureValue('api_key=abcdefghi'), isTrue);
    expect(isSensitiveFixtureValue('Bearer abcdefghi'), isTrue);
    expect(isSensitiveFixtureValue('C:\\Users\\secret\\file.log'), isTrue);
    expect(isSensitiveFixtureValue('/home/student/raw-error.log'), isTrue);
    expect(isSensitiveFixtureValue('실명 홍길동'), isTrue);
    expect(isSensitiveFixtureValue('Spring MVC 예외 처리'), isFalse);
  });

  test('scenario catalog rejects missing fields and missing source facts', () {
    final missingField = LearningLoopScenario(
      id: lcsFirstScenario.id,
      roleLabel: lcsFirstScenario.roleLabel,
      failedTask: lcsFirstScenario.failedTask,
      failedCode: lcsFirstScenario.failedCode,
      testOutput: lcsFirstScenario.testOutput,
      genericReview: lcsFirstScenario.genericReview,
      contextFields: lcsFirstScenario.contextFields
          .where((field) => field.id != ContextFieldId.recentErrors)
          .toList(growable: false),
      contextualFindings: lcsFirstScenario.contextualFindings,
      pathBefore: lcsFirstScenario.pathBefore,
      pathAfter: lcsFirstScenario.pathAfter,
      pathReason: lcsFirstScenario.pathReason,
      evidence: lcsFirstScenario.evidence,
    );
    expect(validateScenarioCatalog(missingField).isValid, isFalse);

    final missingFacts = LearningLoopScenario(
      id: lcsFirstScenario.id,
      roleLabel: lcsFirstScenario.roleLabel,
      failedTask: lcsFirstScenario.failedTask,
      failedCode: lcsFirstScenario.failedCode,
      testOutput: lcsFirstScenario.testOutput,
      genericReview: lcsFirstScenario.genericReview,
      contextFields: lcsFirstScenario.contextFields,
      contextualFindings: const [],
      pathBefore: lcsFirstScenario.pathBefore,
      pathAfter: lcsFirstScenario.pathBefore,
      pathReason: lcsFirstScenario.pathReason,
      evidence: const EmploymentEvidence(
        verifiedOutcome: '검증 가능',
        beforeCorrection: '이전',
        afterCorrection: '이후',
        competencyTags: [],
        nextTask: '다음',
      ),
    );
    expect(validateScenarioCatalog(missingFacts).isValid, isFalse);
  });
}
