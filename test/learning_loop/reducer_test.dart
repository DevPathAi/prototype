import 'package:devpath_prototype/learning_loop/fixtures.dart';
import 'package:devpath_prototype/learning_loop/models.dart';
import 'package:devpath_prototype/learning_loop/reducer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LearningLoopState state;

  setUp(() {
    state = LearningLoopState.initial(lcsFirstScenario);
  });

  test('advances through stages with explicit Applied results', () {
    final result = transition(
      state,
      const CompleteStage(LearningLoopStage.failure),
    );

    expect(result, isA<Applied>());
    final next = (result as Applied).state;
    expect(next.currentStage, LearningLoopStage.context);
    expect(next.completedStages, contains(LearningLoopStage.failure));
  });

  test('model exposes approved-context and reachable-stage helpers', () {
    final completed = state.copyWith(
      completedStages: {LearningLoopStage.failure, LearningLoopStage.context},
      currentStage: LearningLoopStage.review,
    );

    expect(completed.hasApprovedContext, isTrue);
    expect(completed.currentIndex, LearningLoopStage.review.index);
    expect(completed.furthestReachableIndex, LearningLoopStage.review.index);
  });

  test('rejects future stage activation until prerequisites are complete', () {
    final result = transition(
      state,
      const ActivateStage(LearningLoopStage.evidence),
    );

    expect(result, isA<Rejected>());
    expect(
      (result as Rejected).reason,
      TransitionRejectedReason.prerequisiteMissing,
    );
  });

  test('context field change clears downstream state atomically', () {
    final advanced =
        transition(state, const CompleteStage(LearningLoopStage.failure))
            as Applied;

    final result =
        transition(
              advanced.state,
              const ToggleContextField(ContextFieldId.currentContent),
            )
            as Applied;

    expect(result.state.currentStage, LearningLoopStage.context);
    expect(result.state.downstreamStale, isTrue);
    expect(result.state.completedStages, {LearningLoopStage.failure});
    expect(
      result.state.includedFields,
      isNot(contains(ContextFieldId.currentContent)),
    );
  });

  test('context field toggle can add a previously excluded field', () {
    final advanced =
        transition(state, const CompleteStage(LearningLoopStage.failure))
            as Applied;

    final result =
        transition(
              advanced.state,
              const ToggleContextField(ContextFieldId.recentErrors),
            )
            as Applied;

    expect(result.state.includedFields, contains(ContextFieldId.recentErrors));
  });

  test(
    'empty context keeps contextual outputs unavailable after context step',
    () {
      final contextState = state.copyWith(
        currentStage: LearningLoopStage.context,
        completedStages: {LearningLoopStage.failure},
        includedFields: <ContextFieldId>{},
      );

      final result =
          transition(
                contextState,
                const CompleteStage(LearningLoopStage.context),
              )
              as Applied;

      expect(result.state.currentStage, LearningLoopStage.context);
      expect(result.state.completedStages, contains(LearningLoopStage.context));
    },
  );

  test('completed stages can be reopened', () {
    final completed = state.copyWith(
      currentStage: LearningLoopStage.review,
      completedStages: {LearningLoopStage.failure, LearningLoopStage.context},
    );

    final result =
        transition(completed, const ActivateStage(LearningLoopStage.context))
            as Applied;

    expect(result.state.currentStage, LearningLoopStage.context);
  });

  test('regenerate clears stale dependency marker', () {
    final stale = state.copyWith(downstreamStale: true);
    final result = transition(stale, const RegenerateAfterContextChange());

    expect(result, isA<Applied>());
    expect((result as Applied).state.downstreamStale, isFalse);
  });

  test('copy completion ignores stale attempt ids', () {
    final requested = transition(state, const CopyRequested(1)) as Applied;
    final stale = transition(requested.state, const CopySucceeded(2));

    expect(stale, isA<Rejected>());

    final completed = transition(requested.state, const CopySucceeded(1));
    expect(completed, isA<Applied>());
    expect((completed as Applied).state.copyStatus, CopyStatus.succeeded);
  });

  test('copy failure maps to failed copy status', () {
    final requested = transition(state, const CopyRequested(1)) as Applied;
    final failed = transition(requested.state, const CopyFailed(1)) as Applied;

    expect(failed.state.copyStatus, CopyStatus.failed);
  });

  test('duplicate copy request is rejected while in flight', () {
    final requested = transition(state, const CopyRequested(1)) as Applied;
    final duplicate = transition(requested.state, const CopyRequested(2));

    expect(duplicate, isA<Rejected>());
  });

  test('duplicate completion from wrong current stage is rejected', () {
    final result = transition(
      state,
      const CompleteStage(LearningLoopStage.context),
    );

    expect(result, isA<Rejected>());
  });

  test('restart returns to initial defaults and invalidates copy attempts', () {
    final requested = transition(state, const CopyRequested(1)) as Applied;
    final restarted =
        transition(requested.state, const RestartLoop()) as Applied;

    expect(restarted.state.currentStage, LearningLoopStage.failure);
    expect(restarted.state.copyAttemptId, isNull);
    expect(
      restarted.state.includedFields,
      isNot(contains(ContextFieldId.recentErrors)),
    );
  });
}
