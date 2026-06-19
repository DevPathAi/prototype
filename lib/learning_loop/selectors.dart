import 'models.dart';

DerivedResult<List<LearningContextField>> approvedContextFields(
  LearningLoopState state,
) {
  final fields = state.scenario.contextFields
      .where((field) => state.includedFields.contains(field.id))
      .toList(growable: false);
  if (fields.isEmpty) {
    return const Unavailable(DerivedUnavailableReason.emptyContext);
  }
  return Derived(fields);
}

DerivedResult<String> contextualReview(LearningLoopState state) {
  final fields = approvedContextFields(state);
  if (fields is Unavailable<List<LearningContextField>>) {
    return Unavailable(fields.reason);
  }
  if (state.downstreamStale) {
    return const Unavailable(DerivedUnavailableReason.staleDependency);
  }

  final findings = state.scenario.contextualFindings
      .where((finding) {
        return finding.requiredFields.any(state.includedFields.contains);
      })
      .toList(growable: false);

  return Derived(
    findings.map((finding) => '${finding.title}\n${finding.body}').join('\n\n'),
  );
}

DerivedResult<PathDeltaView> pathDelta(LearningLoopState state) {
  final unavailable = _contextualOutputUnavailable(state);
  if (unavailable != null) {
    return Unavailable(unavailable);
  }
  return Derived(
    PathDeltaView(
      before: state.scenario.pathBefore,
      after: state.scenario.pathAfter,
      reason: _reasonWithApprovedContext(state),
    ),
  );
}

DerivedResult<EmploymentEvidence> employmentEvidence(LearningLoopState state) {
  final unavailable = _contextualOutputUnavailable(state);
  if (unavailable != null) {
    return Unavailable(unavailable);
  }
  return Derived(state.scenario.evidence);
}

DerivedResult<String> mentorSummary(LearningLoopState state) {
  final unavailable = _contextualOutputUnavailable(state);
  if (unavailable != null) {
    return Unavailable(unavailable);
  }

  final fields = state.scenario.contextFields
      .where((field) => state.includedFields.contains(field.id))
      .map((field) => '- ${field.id.label}: ${field.value}')
      .join('\n');
  final evidence = state.scenario.evidence;

  return Derived('''
DevPath 학습 루프 요약

상황: ${state.scenario.roleLabel}
실패 과제: ${state.scenario.failedTask}

승인된 LCS:
$fields

보정된 다음 과제:
${state.scenario.pathAfter}

관찰 가능한 증거:
- ${evidence.verifiedOutcome}
- ${evidence.afterCorrection}
- 다음 강화 과제: ${evidence.nextTask}

일부 학습 맥락은 학습자 선택으로 제외되었을 수 있습니다.''');
}

String clipboardPayload(LearningLoopState state) {
  final summary = mentorSummary(state);
  return switch (summary) {
    Derived<String>(:final value) => value,
    Unavailable<String>() => '',
  };
}

class PathDeltaView {
  const PathDeltaView({
    required this.before,
    required this.after,
    required this.reason,
  });

  final String before;
  final String after;
  final String reason;
}

DerivedUnavailableReason? _contextualOutputUnavailable(
  LearningLoopState state,
) {
  if (state.includedFields.isEmpty) {
    return DerivedUnavailableReason.emptyContext;
  }
  if (state.downstreamStale) {
    return DerivedUnavailableReason.staleDependency;
  }
  return null;
}

String _reasonWithApprovedContext(LearningLoopState state) {
  final approvedLabels = state.scenario.contextFields
      .where((field) => state.includedFields.contains(field.id))
      .map((field) => field.id.label)
      .join(', ');
  return '${state.scenario.pathReason}\n사용된 승인 맥락: $approvedLabels';
}
