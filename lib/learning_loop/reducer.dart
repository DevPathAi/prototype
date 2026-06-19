import 'models.dart';

sealed class LearningLoopAction {
  const LearningLoopAction();
}

class CompleteStage extends LearningLoopAction {
  const CompleteStage(this.expectedStage);

  final LearningLoopStage expectedStage;
}

class ActivateStage extends LearningLoopAction {
  const ActivateStage(this.stage);

  final LearningLoopStage stage;
}

class ToggleContextField extends LearningLoopAction {
  const ToggleContextField(this.field);

  final ContextFieldId field;
}

class RegenerateAfterContextChange extends LearningLoopAction {
  const RegenerateAfterContextChange();
}

class RestartLoop extends LearningLoopAction {
  const RestartLoop();
}

class CopyRequested extends LearningLoopAction {
  const CopyRequested(this.attemptId);

  final int attemptId;
}

class CopySucceeded extends LearningLoopAction {
  const CopySucceeded(this.attemptId);

  final int attemptId;
}

class CopyFailed extends LearningLoopAction {
  const CopyFailed(this.attemptId);

  final int attemptId;
}

TransitionResult transition(
  LearningLoopState state,
  LearningLoopAction action,
) {
  if (!_isStateReachable(state)) {
    return const Failed(TransitionFailure.invalidLoopState);
  }

  return switch (action) {
    CompleteStage(:final expectedStage) => _completeStage(state, expectedStage),
    ActivateStage(:final stage) => _activateStage(state, stage),
    ToggleContextField(:final field) => _toggleContextField(state, field),
    RegenerateAfterContextChange() => Applied(
      state.copyWith(downstreamStale: false, liveMessage: '새 결과를 생성했습니다.'),
    ),
    RestartLoop() => Applied(
      LearningLoopState.initial(
        state.scenario,
      ).copyWith(liveMessage: '학습 루프를 처음 상태로 재시작했습니다.'),
    ),
    CopyRequested(:final attemptId) => _copyRequested(state, attemptId),
    CopySucceeded(:final attemptId) => _copyCompleted(
      state,
      attemptId,
      CopyStatus.succeeded,
      '현재 보이는 멘토 요약을 복사했습니다.',
    ),
    CopyFailed(:final attemptId) => _copyCompleted(
      state,
      attemptId,
      CopyStatus.failed,
      '복사에 실패했습니다. 요약을 직접 선택해 복사할 수 있습니다.',
    ),
  };
}

TransitionResult _completeStage(
  LearningLoopState state,
  LearningLoopStage expectedStage,
) {
  if (state.currentStage != expectedStage) {
    return const Rejected(TransitionRejectedReason.duplicateAction);
  }

  if (expectedStage == LearningLoopStage.context &&
      state.includedFields.isEmpty) {
    return Applied(
      state.copyWith(
        completedStages: {...state.completedStages, expectedStage},
        liveMessage: '승인된 LCS 필드가 없어 맥락 기반 결과가 비활성화되었습니다.',
      ),
    );
  }

  final index = LearningLoopStage.values.indexOf(expectedStage);
  if (index == LearningLoopStage.values.length - 1) {
    return const Rejected(TransitionRejectedReason.duplicateAction);
  }

  final nextStage = LearningLoopStage.values[index + 1];
  return Applied(
    state.copyWith(
      currentStage: nextStage,
      completedStages: {...state.completedStages, expectedStage},
      downstreamStale: false,
      liveMessage: '${nextStage.label} 단계로 이동했습니다.',
    ),
  );
}

TransitionResult _activateStage(
  LearningLoopState state,
  LearningLoopStage stage,
) {
  final targetIndex = LearningLoopStage.values.indexOf(stage);
  if (targetIndex > state.furthestReachableIndex) {
    return const Rejected(TransitionRejectedReason.prerequisiteMissing);
  }

  return Applied(
    state.copyWith(
      currentStage: stage,
      liveMessage: '${stage.label} 단계를 열었습니다.',
    ),
  );
}

TransitionResult _toggleContextField(
  LearningLoopState state,
  ContextFieldId field,
) {
  final included = {...state.includedFields};
  if (included.contains(field)) {
    included.remove(field);
  } else {
    included.add(field);
  }

  final contextIndex = LearningLoopStage.values.indexOf(
    LearningLoopStage.context,
  );
  final completed = state.completedStages
      .where((stage) => LearningLoopStage.values.indexOf(stage) < contextIndex)
      .toSet();

  return Applied(
    state.copyWith(
      currentStage: LearningLoopStage.context,
      completedStages: completed,
      includedFields: included,
      downstreamStale: true,
      copyStatus: CopyStatus.idle,
      clearCopyAttemptId: true,
      liveMessage: '선택이 바뀌어 이후 결과가 초기화되었습니다.',
    ),
  );
}

TransitionResult _copyRequested(LearningLoopState state, int attemptId) {
  if (state.copyStatus == CopyStatus.inFlight) {
    return const Rejected(TransitionRejectedReason.duplicateAction);
  }
  return Applied(
    state.copyWith(
      copyStatus: CopyStatus.inFlight,
      copyAttemptId: attemptId,
      clearLiveMessage: true,
    ),
  );
}

TransitionResult _copyCompleted(
  LearningLoopState state,
  int attemptId,
  CopyStatus status,
  String message,
) {
  if (state.copyAttemptId != attemptId) {
    return const Rejected(TransitionRejectedReason.duplicateAction);
  }
  return Applied(
    state.copyWith(
      copyStatus: status,
      clearCopyAttemptId: true,
      liveMessage: message,
    ),
  );
}

bool _isStateReachable(LearningLoopState state) {
  final currentIndex = LearningLoopStage.values.indexOf(state.currentStage);
  if (currentIndex < 0) {
    return false;
  }
  return state.completedStages.every((stage) {
    final stageIndex = LearningLoopStage.values.indexOf(stage);
    return stageIndex >= 0 && stageIndex < LearningLoopStage.values.length;
  });
}
