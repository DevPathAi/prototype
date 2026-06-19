import 'package:devpath_prototype/learning_loop/fixtures.dart';
import 'package:devpath_prototype/learning_loop/models.dart';
import 'package:devpath_prototype/learning_loop/selectors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('all privacy combinations exclude disabled context values', () {
    final fields = ContextFieldId.values;

    for (var mask = 0; mask < 16; mask += 1) {
      final included = <ContextFieldId>{
        for (var i = 0; i < fields.length; i += 1)
          if ((mask & (1 << i)) != 0) fields[i],
      };
      final state = LearningLoopState.initial(
        lcsFirstScenario,
      ).copyWith(includedFields: included);

      final summary = mentorSummary(state);
      if (included.isEmpty) {
        expect(summary, isA<Unavailable<String>>());
        expect(contextualReview(state), isA<Unavailable<String>>());
        expect(pathDelta(state), isA<Unavailable<PathDeltaView>>());
        expect(
          employmentEvidence(state),
          isA<Unavailable<EmploymentEvidence>>(),
        );
        continue;
      }

      expect(summary, isA<Derived<String>>());
      final text = (summary as Derived<String>).value;
      for (final field in lcsFirstScenario.contextFields) {
        if (included.contains(field.id)) {
          expect(text, contains(field.value));
        } else {
          expect(text, isNot(contains(field.value)));
        }
      }
    }
  });

  test('stale dependency makes contextual outputs unavailable', () {
    final state = LearningLoopState.initial(
      lcsFirstScenario,
    ).copyWith(downstreamStale: true);

    expect(contextualReview(state), isA<Unavailable<String>>());
    expect(pathDelta(state), isA<Unavailable<PathDeltaView>>());
    expect(mentorSummary(state), isA<Unavailable<String>>());
  });

  test('clipboard payload is exactly the visible mentor summary', () {
    final state = LearningLoopState.initial(lcsFirstScenario);
    final summary = mentorSummary(state) as Derived<String>;

    expect(clipboardPayload(state), summary.value);
  });

  test('clipboard payload is empty when context is unavailable', () {
    final state = LearningLoopState.initial(
      lcsFirstScenario,
    ).copyWith(includedFields: <ContextFieldId>{});

    expect(clipboardPayload(state), isEmpty);
  });
}
