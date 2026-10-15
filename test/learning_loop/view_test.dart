import 'package:devpath_prototype/learning_loop/fixtures.dart';
import 'package:devpath_prototype/learning_loop/models.dart';
import 'package:devpath_prototype/learning_loop/selectors.dart';
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

  // 복사 성공 경로는 지금까지 전체 흐름 위젯 테스트가 실제 플랫폼 채널로 복사하면서
  // 덮었을 뿐 명시적으로 검증한 적이 없었다. Flutter 3.47.7 에서 그 우연이 깨져
  // CopySucceeded 생성자(reducer.dart:40)가 실행되지 않았고 Pages 커버리지 관문이
  // 99.50% 로 떨어졌다(2026-10-15). writer 를 주입해 성공 경로를 직접 검증한다.
  testWidgets('clipboard success copies exactly the visible summary', (
    tester,
  ) async {
    var state = LearningLoopState.initial(lcsFirstScenario).copyWith(
      currentStage: LearningLoopStage.evidence,
      completedStages: LearningLoopStage.values.toSet(),
    );
    final written = <String>[];
    Future<void> writer(String payload) async => written.add(payload);

    await _pumpLoop(
      tester,
      state,
      onStateChanged: (next) => state = next,
      clipboardWriter: writer,
    );

    await tester.ensureVisible(find.text('현재 보이는 내용 복사'));
    await tester.tap(find.text('현재 보이는 내용 복사'));
    await tester.pumpAndSettle();
    await _pumpLoop(
      tester,
      state,
      onStateChanged: (next) => state = next,
      clipboardWriter: writer,
    );

    expect(written, [clipboardPayload(state)]);
    expect(state.copyStatus, CopyStatus.succeeded);
    expect(find.text('현재 보이는 멘토 요약을 복사했습니다.'), findsOneWidget);
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
