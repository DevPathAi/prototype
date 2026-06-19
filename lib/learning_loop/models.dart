enum LearningLoopStage {
  failure('실습 실패', '무엇이 실패했는지 확인'),
  context('LCS 승인', '학습 맥락 선택'),
  review('맥락 리뷰', '일반 AI와 DevPath 비교'),
  pathDelta('경로 보정', '다음 학습 과제 변경'),
  evidence('증거/멘토 요약', '남길 수 있는 결과');

  const LearningLoopStage(this.label, this.shortLabel);

  final String label;
  final String shortLabel;
}

enum ContextFieldId {
  currentContent('현재 학습 콘텐츠'),
  currentPath('현재 학습 경로'),
  activeTags('활성 약점 태그'),
  recentErrors('최근 오류 요약');

  const ContextFieldId(this.label);

  final String label;
}

enum TransitionRejectedReason { duplicateAction, prerequisiteMissing }

enum TransitionFailure { invalidLoopState }

enum CopyStatus { idle, inFlight, succeeded, failed }

enum DerivedUnavailableReason { emptyContext, staleDependency }

class LearningLoopScenario {
  const LearningLoopScenario({
    required this.id,
    required this.roleLabel,
    required this.failedTask,
    required this.failedCode,
    required this.testOutput,
    required this.genericReview,
    required this.contextFields,
    required this.contextualFindings,
    required this.pathBefore,
    required this.pathAfter,
    required this.pathReason,
    required this.evidence,
  });

  final String id;
  final String roleLabel;
  final String failedTask;
  final String failedCode;
  final String testOutput;
  final String genericReview;
  final List<LearningContextField> contextFields;
  final List<ContextualFinding> contextualFindings;
  final String pathBefore;
  final String pathAfter;
  final String pathReason;
  final EmploymentEvidence evidence;
}

class LearningContextField {
  const LearningContextField({
    required this.id,
    required this.value,
    required this.source,
    required this.freshness,
    required this.defaultIncluded,
    required this.sensitive,
  });

  final ContextFieldId id;
  final String value;
  final String source;
  final String freshness;
  final bool defaultIncluded;
  final bool sensitive;
}

class ContextualFinding {
  const ContextualFinding({
    required this.requiredFields,
    required this.title,
    required this.body,
  });

  final Set<ContextFieldId> requiredFields;
  final String title;
  final String body;
}

class EmploymentEvidence {
  const EmploymentEvidence({
    required this.verifiedOutcome,
    required this.beforeCorrection,
    required this.afterCorrection,
    required this.competencyTags,
    required this.nextTask,
  });

  final String verifiedOutcome;
  final String beforeCorrection;
  final String afterCorrection;
  final List<String> competencyTags;
  final String nextTask;
}

class LearningLoopState {
  const LearningLoopState({
    required this.scenario,
    required this.currentStage,
    required this.completedStages,
    required this.includedFields,
    this.downstreamStale = false,
    this.copyStatus = CopyStatus.idle,
    this.copyAttemptId,
    this.liveMessage,
  });

  factory LearningLoopState.initial(LearningLoopScenario scenario) {
    return LearningLoopState(
      scenario: scenario,
      currentStage: LearningLoopStage.failure,
      completedStages: const <LearningLoopStage>{},
      includedFields: {
        for (final field in scenario.contextFields)
          if (field.defaultIncluded) field.id,
      },
    );
  }

  final LearningLoopScenario scenario;
  final LearningLoopStage currentStage;
  final Set<LearningLoopStage> completedStages;
  final Set<ContextFieldId> includedFields;
  final bool downstreamStale;
  final CopyStatus copyStatus;
  final int? copyAttemptId;
  final String? liveMessage;

  bool get hasApprovedContext => includedFields.isNotEmpty;

  int get currentIndex => LearningLoopStage.values.indexOf(currentStage);

  int get furthestReachableIndex {
    var index = 0;
    for (final stage in completedStages) {
      final stageIndex = LearningLoopStage.values.indexOf(stage);
      if (stageIndex + 1 > index) {
        index = stageIndex + 1;
      }
    }
    return index.clamp(0, LearningLoopStage.values.length - 1);
  }

  LearningLoopState copyWith({
    LearningLoopStage? currentStage,
    Set<LearningLoopStage>? completedStages,
    Set<ContextFieldId>? includedFields,
    bool? downstreamStale,
    CopyStatus? copyStatus,
    int? copyAttemptId,
    bool clearCopyAttemptId = false,
    String? liveMessage,
    bool clearLiveMessage = false,
  }) {
    return LearningLoopState(
      scenario: scenario,
      currentStage: currentStage ?? this.currentStage,
      completedStages: completedStages ?? this.completedStages,
      includedFields: includedFields ?? this.includedFields,
      downstreamStale: downstreamStale ?? this.downstreamStale,
      copyStatus: copyStatus ?? this.copyStatus,
      copyAttemptId: clearCopyAttemptId
          ? null
          : copyAttemptId ?? this.copyAttemptId,
      liveMessage: clearLiveMessage ? null : liveMessage ?? this.liveMessage,
    );
  }
}

sealed class TransitionResult {
  const TransitionResult();
}

class Applied extends TransitionResult {
  const Applied(this.state);

  final LearningLoopState state;
}

class Rejected extends TransitionResult {
  const Rejected(this.reason);

  final TransitionRejectedReason reason;
}

class Failed extends TransitionResult {
  const Failed(this.failure);

  final TransitionFailure failure;
}

sealed class DerivedResult<T> {
  const DerivedResult();
}

class Derived<T> extends DerivedResult<T> {
  const Derived(this.value);

  final T value;
}

class Unavailable<T> extends DerivedResult<T> {
  const Unavailable(this.reason);

  final DerivedUnavailableReason reason;
}
