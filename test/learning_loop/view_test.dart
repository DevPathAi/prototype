import 'package:devpath_prototype/learning_loop/fixtures.dart';
import 'package:devpath_prototype/learning_loop/models.dart';
import 'package:devpath_prototype/learning_loop/view.dart';
import 'package:devpath_prototype/theme/prototype_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('review comparison uses only medium width two-column layout', (
    tester,
  ) async {
    for (final entry in const [
      (599.0, Axis.vertical),
      (600.0, Axis.horizontal),
      (979.0, Axis.horizontal),
      (980.0, Axis.vertical),
    ]) {
      tester.view.physicalSize = Size(entry.$1, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await _pumpLoop(
        tester,
        LearningLoopState.initial(lcsFirstScenario).copyWith(
          currentStage: LearningLoopStage.review,
          completedStages: {
            LearningLoopStage.failure,
            LearningLoopStage.context,
          },
        ),
      );

      final hasHorizontalFlex = tester
          .widgetList<Flex>(find.byType(Flex))
          .any((widget) => widget.direction == Axis.horizontal);
      expect(
        hasHorizontalFlex,
        entry.$2 == Axis.horizontal,
        reason: 'width ${entry.$1}',
      );
    }
  });

  testWidgets('empty context disables contextual generation with explanation', (
    tester,
  ) async {
    await _pumpLoop(
      tester,
      LearningLoopState.initial(lcsFirstScenario).copyWith(
        currentStage: LearningLoopStage.context,
        completedStages: {LearningLoopStage.failure},
        includedFields: <ContextFieldId>{},
      ),
    );

    expect(find.textContaining('승인된 맥락이 없어'), findsOneWidget);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, '맥락 리뷰 생성'),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('backward context edit shows invalidation and recovery action', (
    tester,
  ) async {
    late LearningLoopState state;
    state = LearningLoopState.initial(lcsFirstScenario).copyWith(
      currentStage: LearningLoopStage.review,
      completedStages: {LearningLoopStage.failure, LearningLoopStage.context},
    );

    await _pumpLoop(
      tester,
      state,
      onStateChanged: (next) {
        state = next;
      },
    );

    await tester.tap(find.text('LCS 승인'));
    await tester.pumpAndSettle();
    await _pumpLoop(tester, state, onStateChanged: (next) => state = next);

    await tester.tap(find.widgetWithText(SwitchListTile, '현재 학습 콘텐츠'));
    await tester.pumpAndSettle();
    await _pumpLoop(tester, state, onStateChanged: (next) => state = next);

    expect(find.textContaining('선택이 바뀌어 이후 결과가 초기화'), findsWidgets);
    expect(find.text('새 결과 생성'), findsOneWidget);
  });

  testWidgets('restart confirmation resets the loop to the first stage', (
    tester,
  ) async {
    var state = LearningLoopState.initial(lcsFirstScenario).copyWith(
      currentStage: LearningLoopStage.evidence,
      completedStages: LearningLoopStage.values.toSet(),
    );

    await _pumpLoop(tester, state, onStateChanged: (next) => state = next);

    await tester.ensureVisible(find.text('재시작').last);
    await tester.tap(find.text('재시작').last);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, '재시작'));
    await tester.pumpAndSettle();
    await _pumpLoop(tester, state, onStateChanged: (next) => state = next);

    expect(find.text('1. 실패한 실습과 일반 AI 답변'), findsOneWidget);
    expect(state.currentStage, LearningLoopStage.failure);
  });

  testWidgets('clipboard failure keeps visible summary and exposes recovery', (
    tester,
  ) async {
    var state = LearningLoopState.initial(lcsFirstScenario).copyWith(
      currentStage: LearningLoopStage.evidence,
      completedStages: LearningLoopStage.values.toSet(),
    );

    await _pumpLoop(
      tester,
      state,
      onStateChanged: (next) => state = next,
      clipboardWriter: (_) {
        throw PlatformException(code: 'denied');
      },
    );

    await tester.ensureVisible(find.text('현재 보이는 내용 복사'));
    await tester.tap(find.text('현재 보이는 내용 복사'));
    await tester.pumpAndSettle();
    await _pumpLoop(
      tester,
      state,
      onStateChanged: (next) => state = next,
      clipboardWriter: (_) {
        throw PlatformException(code: 'denied');
      },
    );

    expect(find.textContaining('복사에 실패했습니다'), findsOneWidget);
    expect(find.textContaining('DevPath 학습 루프 요약'), findsOneWidget);
  });
}

Future<void> _pumpLoop(
  WidgetTester tester,
  LearningLoopState state, {
  ValueChanged<LearningLoopState>? onStateChanged,
  ClipboardWriter? clipboardWriter,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildPrototypeTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: GuidedLearningLoop(
            state: state,
            onStateChanged: onStateChanged ?? (_) {},
            clipboardWriter: clipboardWriter,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
