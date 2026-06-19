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
    expect(isSensitiveFixtureValue('C:\\Users\\secret\\file.log'), isTrue);
    expect(isSensitiveFixtureValue('Spring MVC 예외 처리'), isFalse);
  });
}
