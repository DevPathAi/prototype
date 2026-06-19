// coverage:ignore-file
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/prototype_theme.dart';
import '../widgets/prototype_components.dart';
import 'models.dart';
import 'reducer.dart';
import 'selectors.dart';

typedef ClipboardWriter = Future<void> Function(String payload);
typedef DiagnosticSink = void Function(LearningLoopDiagnostic event);

class LearningLoopDiagnostic {
  const LearningLoopDiagnostic({
    required this.stage,
    required this.action,
    required this.error,
    this.attemptId,
  });

  final LearningLoopStage stage;
  final String action;
  final String error;
  final int? attemptId;
}

class GuidedLearningLoop extends StatefulWidget {
  const GuidedLearningLoop({
    required this.state,
    required this.onStateChanged,
    this.clipboardWriter,
    this.diagnosticSink,
    super.key,
  });

  final LearningLoopState state;
  final ValueChanged<LearningLoopState> onStateChanged;
  final ClipboardWriter? clipboardWriter;
  final DiagnosticSink? diagnosticSink;

  @override
  State<GuidedLearningLoop> createState() => _GuidedLearningLoopState();
}

class _GuidedLearningLoopState extends State<GuidedLearningLoop> {
  var _copyAttemptSeed = 0;

  ClipboardWriter get _clipboardWriter {
    return widget.clipboardWriter ??
        (payload) => Clipboard.setData(ClipboardData(text: payload));
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PrototypeSectionHeader(
          eyebrow: '3분 데모',
          title: 'LCS가 실패 원인을 이해하고 다음 학습을 바꾸는 흐름',
          body:
              '부트캠프 수료자가 백엔드 실습에 실패한 뒤, 승인한 학습 맥락만 DevPath 리뷰와 다음 과제 보정에 쓰이는 과정을 확인합니다.',
        ),
        const SizedBox(height: 18),
        _StageNavigation(state: state, onStageSelected: _activateStage),
        const SizedBox(height: 18),
        Semantics(
          liveRegion: true,
          label: state.liveMessage,
          child: state.liveMessage == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _Notice(message: state.liveMessage!),
                ),
        ),
        _StageBody(
          state: state,
          onComplete: () => _dispatch(CompleteStage(state.currentStage)),
          onToggleField: (field) => _dispatch(ToggleContextField(field)),
          onRegenerate: () => _dispatch(const RegenerateAfterContextChange()),
          onCopy: _copySummary,
          onRestart: _confirmRestart,
        ),
      ],
    );
  }

  void _activateStage(LearningLoopStage stage) {
    final result = transition(widget.state, ActivateStage(stage));
    _applyResult(result, action: 'activate-stage');
  }

  void _dispatch(LearningLoopAction action) {
    final result = transition(widget.state, action);
    _applyResult(result, action: action.runtimeType.toString());
  }

  Future<void> _copySummary() async {
    final payload = clipboardPayload(widget.state);
    if (payload.isEmpty) {
      return;
    }
    final attemptId = ++_copyAttemptSeed;
    final requested = transition(widget.state, CopyRequested(attemptId));
    if (requested is! Applied) {
      _applyResult(requested, action: 'copy-request');
      return;
    }
    widget.onStateChanged(requested.state);

    try {
      await _clipboardWriter(payload);
      final result = transition(requested.state, CopySucceeded(attemptId));
      _applyResult(result, action: 'copy-success', attemptId: attemptId);
    } on PlatformException {
      final result = transition(requested.state, CopyFailed(attemptId));
      _applyResult(result, action: 'copy-failed', attemptId: attemptId);
    } catch (_) {
      final result = transition(requested.state, CopyFailed(attemptId));
      _applyResult(result, action: 'copy-failed', attemptId: attemptId);
    }
  }

  Future<void> _confirmRestart() async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('학습 루프를 재시작할까요?'),
        content: const Text('선택한 LCS 필드와 생성된 결과가 모두 초기화됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('재시작'),
          ),
        ],
      ),
    );
    if (shouldRestart == true) {
      _dispatch(const RestartLoop());
    }
  }

  void _applyResult(
    TransitionResult result, {
    required String action,
    int? attemptId,
  }) {
    switch (result) {
      case Applied(:final state):
        widget.onStateChanged(state);
      case Rejected(:final reason):
        if (reason == TransitionRejectedReason.prerequisiteMissing) {
          final state = widget.state.copyWith(
            liveMessage: '이전 단계를 먼저 완료해야 열 수 있습니다.',
          );
          widget.onStateChanged(state);
        }
      case Failed(:final failure):
        widget.diagnosticSink?.call(
          LearningLoopDiagnostic(
            stage: widget.state.currentStage,
            action: action,
            error: failure.name,
            attemptId: attemptId,
          ),
        );
        widget.onStateChanged(
          widget.state.copyWith(
            liveMessage: '상태 오류가 감지되었습니다. 재시작 후 다시 시도해 주세요.',
          ),
        );
    }
  }
}

class ScenarioUnavailablePanel extends StatelessWidget {
  const ScenarioUnavailablePanel({required this.error, super.key});

  final String error;

  @override
  Widget build(BuildContext context) {
    return PrototypePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습 루프 fixture를 사용할 수 없습니다',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(error),
          const SizedBox(height: 12),
          const Text('기존 기능 탐색은 계속 사용할 수 있습니다.'),
        ],
      ),
    );
  }
}

class _StageNavigation extends StatelessWidget {
  const _StageNavigation({required this.state, required this.onStageSelected});

  final LearningLoopState state;
  final ValueChanged<LearningLoopStage> onStageSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 600;
        if (compact) {
          return PrototypePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.currentIndex + 1} / ${LearningLoopStage.values.length}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  state.currentStage.label,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('단계 목록'),
                    children: _chips(context),
                  ),
                ),
              ],
            ),
          );
        }
        return PrototypePanel(
          child: Wrap(spacing: 10, runSpacing: 10, children: _chips(context)),
        );
      },
    );
  }

  List<Widget> _chips(BuildContext context) {
    return [
      for (final stage in LearningLoopStage.values)
        Tooltip(
          message: _isReachable(stage) ? stage.shortLabel : '이전 단계를 먼저 완료하세요',
          child: ChoiceChip(
            label: Text(stage.label),
            selected: stage == state.currentStage,
            onSelected: _isReachable(stage)
                ? (_) => onStageSelected(stage)
                : null,
          ),
        ),
    ];
  }

  bool _isReachable(LearningLoopStage stage) {
    return LearningLoopStage.values.indexOf(stage) <=
        state.furthestReachableIndex;
  }
}

class _StageBody extends StatelessWidget {
  const _StageBody({
    required this.state,
    required this.onComplete,
    required this.onToggleField,
    required this.onRegenerate,
    required this.onCopy,
    required this.onRestart,
  });

  final LearningLoopState state;
  final VoidCallback onComplete;
  final ValueChanged<ContextFieldId> onToggleField;
  final VoidCallback onRegenerate;
  final VoidCallback onCopy;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return switch (state.currentStage) {
      LearningLoopStage.failure => _FailureStage(
        state: state,
        onComplete: onComplete,
        onRestart: onRestart,
      ),
      LearningLoopStage.context => _ContextStage(
        state: state,
        onComplete: onComplete,
        onToggleField: onToggleField,
        onRegenerate: onRegenerate,
        onRestart: onRestart,
      ),
      LearningLoopStage.review => _ReviewStage(
        state: state,
        onComplete: onComplete,
        onRestart: onRestart,
      ),
      LearningLoopStage.pathDelta => _PathDeltaStage(
        state: state,
        onComplete: onComplete,
        onRestart: onRestart,
      ),
      LearningLoopStage.evidence => _EvidenceStage(
        state: state,
        onCopy: onCopy,
        onRestart: onRestart,
      ),
    };
  }
}

class _FailureStage extends StatelessWidget {
  const _FailureStage({
    required this.state,
    required this.onComplete,
    required this.onRestart,
  });

  final LearningLoopState state;
  final VoidCallback onComplete;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final tokens = prototypeTokens(context);
    return _StageScaffold(
      title: '1. 실패한 실습과 일반 AI 답변',
      actions: [
        OutlinedButton(onPressed: onRestart, child: const Text('재시작')),
        FilledButton(onPressed: onComplete, child: const Text('LCS 선택으로 이동')),
      ],
      child: PrototypeResponsiveGrid(
        minItemWidth: 330,
        children: [
          PrototypePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('실패 과제', color: tokens.danger),
                const SizedBox(height: 8),
                Text(state.scenario.failedTask),
                const SizedBox(height: 12),
                _CodeBlock(state.scenario.failedCode),
                const SizedBox(height: 12),
                _Notice(
                  message: state.scenario.testOutput,
                  tone: NoticeTone.danger,
                ),
              ],
            ),
          ),
          PrototypePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Label('일반 AI 답변', color: tokens.warning),
                const SizedBox(height: 8),
                Text(state.scenario.genericReview),
                const SizedBox(height: 12),
                const Text(
                  '학습 경로, 현재 단원, 최근 테스트 실패를 모르기 때문에 조언이 넓고 다음 행동이 흐릿합니다.',
                  style: TextStyle(height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextStage extends StatelessWidget {
  const _ContextStage({
    required this.state,
    required this.onComplete,
    required this.onToggleField,
    required this.onRegenerate,
    required this.onRestart,
  });

  final LearningLoopState state;
  final VoidCallback onComplete;
  final ValueChanged<ContextFieldId> onToggleField;
  final VoidCallback onRegenerate;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return _StageScaffold(
      title: '2. 학습자가 승인한 LCS만 사용',
      actions: [
        OutlinedButton(onPressed: onRestart, child: const Text('재시작')),
        if (state.downstreamStale)
          FilledButton(onPressed: onRegenerate, child: const Text('새 결과 생성'))
        else
          FilledButton(
            onPressed: state.includedFields.isEmpty ? null : onComplete,
            child: const Text('맥락 리뷰 생성'),
          ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (state.downstreamStale)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _Notice(
                message: '선택이 바뀌어 이후 결과가 초기화되었습니다. 새 결과 생성 후 다음 단계로 이동합니다.',
              ),
            ),
          if (state.includedFields.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: _Notice(
                message: '승인된 맥락이 없어 DevPath 리뷰, 경로 보정, 증거, 멘토 요약을 만들 수 없습니다.',
                tone: NoticeTone.warning,
              ),
            ),
          PrototypeResponsiveGrid(
            minItemWidth: 320,
            children: [
              for (final field in state.scenario.contextFields)
                _ContextFieldCard(
                  field: field,
                  selected: state.includedFields.contains(field.id),
                  onChanged: () => onToggleField(field.id),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewStage extends StatelessWidget {
  const _ReviewStage({
    required this.state,
    required this.onComplete,
    required this.onRestart,
  });

  final LearningLoopState state;
  final VoidCallback onComplete;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final review = contextualReview(state);
    final columns =
        MediaQuery.sizeOf(context).width >= 600 &&
        MediaQuery.sizeOf(context).width < 980;
    return _StageScaffold(
      title: '3. 일반 AI와 LCS 기반 리뷰 비교',
      actions: [
        OutlinedButton(onPressed: onRestart, child: const Text('재시작')),
        FilledButton(
          onPressed: review is Derived<String> ? onComplete : null,
          child: const Text('경로 보정 보기'),
        ),
      ],
      child: Flex(
        direction: columns ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpandedIf(
            expand: columns,
            child: PrototypePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('일반 AI'),
                  const SizedBox(height: 8),
                  Text(state.scenario.genericReview),
                ],
              ),
            ),
          ),
          SizedBox(width: columns ? 14 : 0, height: columns ? 0 : 14),
          ExpandedIf(
            expand: columns,
            child: PrototypePanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('DevPath LCS 리뷰'),
                  const SizedBox(height: 8),
                  switch (review) {
                    Derived<String>(:final value) => Text(value),
                    Unavailable<String>(:final reason) => _UnavailableMessage(
                      reason: reason,
                    ),
                  },
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathDeltaStage extends StatelessWidget {
  const _PathDeltaStage({
    required this.state,
    required this.onComplete,
    required this.onRestart,
  });

  final LearningLoopState state;
  final VoidCallback onComplete;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final delta = pathDelta(state);
    return _StageScaffold(
      title: '4. 다음 학습 과제 보정',
      actions: [
        OutlinedButton(onPressed: onRestart, child: const Text('재시작')),
        FilledButton(
          onPressed: delta is Derived<PathDeltaView> ? onComplete : null,
          child: const Text('증거와 요약 보기'),
        ),
      ],
      child: PrototypePanel(
        child: switch (delta) {
          Derived<PathDeltaView>(:final value) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StatusRow(label: '기존 다음 과제', value: value.before),
              const SizedBox(height: 12),
              StatusRow(label: '보정 후 과제', value: value.after),
              const SizedBox(height: 12),
              StatusRow(label: '변경 이유', value: value.reason),
            ],
          ),
          Unavailable<PathDeltaView>(:final reason) => _UnavailableMessage(
            reason: reason,
          ),
        },
      ),
    );
  }
}

class _EvidenceStage extends StatelessWidget {
  const _EvidenceStage({
    required this.state,
    required this.onCopy,
    required this.onRestart,
  });

  final LearningLoopState state;
  final VoidCallback onCopy;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final evidence = employmentEvidence(state);
    final summary = mentorSummary(state);
    return _StageScaffold(
      title: '5. 취업 준비 증거와 멘토 요약',
      actions: [
        OutlinedButton(onPressed: onRestart, child: const Text('재시작')),
        FilledButton.icon(
          onPressed:
              state.copyStatus == CopyStatus.inFlight ||
                  summary is! Derived<String>
              ? null
              : onCopy,
          icon: const Icon(Icons.copy_outlined),
          label: Text(
            state.copyStatus == CopyStatus.inFlight ? '복사 중' : '현재 보이는 내용 복사',
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PrototypePanel(
            child: switch (evidence) {
              Derived<EmploymentEvidence>(:final value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Label('관찰 가능한 개선 증거'),
                  const SizedBox(height: 12),
                  StatusRow(label: '검증 결과', value: value.verifiedOutcome),
                  const SizedBox(height: 12),
                  StatusRow(label: '수정 전', value: value.beforeCorrection),
                  const SizedBox(height: 12),
                  StatusRow(label: '수정 후', value: value.afterCorrection),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final tag in value.competencyTags)
                        Chip(label: Text(tag)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StatusRow(label: '다음 강화', value: value.nextTask),
                ],
              ),
              Unavailable<EmploymentEvidence>(:final reason) =>
                _UnavailableMessage(reason: reason),
            },
          ),
          const SizedBox(height: 14),
          PrototypePanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Label('멘토에게 공유할 요약'),
                const SizedBox(height: 10),
                SelectableText(switch (summary) {
                  Derived<String>(:final value) => value,
                  Unavailable<String>(:final reason) => _unavailableText(
                    reason,
                  ),
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StageScaffold extends StatelessWidget {
  const _StageScaffold({
    required this.title,
    required this.child,
    required this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          autofocus: true,
          child: Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(height: 14),
        child,
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: actions),
      ],
    );
  }
}

class _ContextFieldCard extends StatelessWidget {
  const _ContextFieldCard({
    required this.field,
    required this.selected,
    required this.onChanged,
  });

  final LearningContextField field;
  final bool selected;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = prototypeTokens(context);
    return PrototypePanel(
      backgroundColor: selected ? tokens.surfaceMuted : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                field.id.label,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              subtitle: Text(field.sensitive ? '명시적 승인 필요' : '기본 포함'),
              value: selected,
              onChanged: (_) => onChanged(),
            ),
          ),
          const SizedBox(height: 8),
          Text(field.value),
          const SizedBox(height: 10),
          StatusRow(label: '출처', value: field.source),
          const SizedBox(height: 6),
          StatusRow(label: '신선도', value: '${field.freshness} · 정적 샘플'),
        ],
      ),
    );
  }
}

class ExpandedIf extends StatelessWidget {
  const ExpandedIf({required this.expand, required this.child, super.key});

  final bool expand;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return expand ? Expanded(child: child) : child;
  }
}

enum NoticeTone { neutral, warning, danger }

class _Notice extends StatelessWidget {
  const _Notice({required this.message, this.tone = NoticeTone.neutral});

  final String message;
  final NoticeTone tone;

  @override
  Widget build(BuildContext context) {
    final tokens = prototypeTokens(context);
    final color = switch (tone) {
      NoticeTone.neutral => tokens.info,
      NoticeTone.warning => tokens.warning,
      NoticeTone.danger => tokens.danger,
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Text(message, style: const TextStyle(height: 1.4)),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text, {this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? prototypeTokens(context).success,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock(this.code);

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF17201D),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        code,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          height: 1.35,
        ),
      ),
    );
  }
}

class _UnavailableMessage extends StatelessWidget {
  const _UnavailableMessage({required this.reason});

  final DerivedUnavailableReason reason;

  @override
  Widget build(BuildContext context) {
    return _Notice(message: _unavailableText(reason), tone: NoticeTone.warning);
  }
}

String _unavailableText(DerivedUnavailableReason reason) {
  return switch (reason) {
    DerivedUnavailableReason.emptyContext =>
      '승인된 LCS 필드가 없어 맥락 기반 결과를 만들 수 없습니다.',
    DerivedUnavailableReason.staleDependency =>
      '상위 선택이 바뀌어 이전 결과가 초기화되었습니다. 새 결과를 생성해 주세요.',
  };
}
