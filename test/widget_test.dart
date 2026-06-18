import 'package:devpath_prototype/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('프로젝트 소개, 데모, 아키텍처, 기술 스택 영역을 탐색할 수 있다', (tester) async {
    await tester.pumpWidget(const DevPathPrototypeApp());

    expect(find.text('DevPath AI'), findsWidgets);
    expect(find.text('프로젝트 소개'), findsOneWidget);
    expect(find.text('데모'), findsOneWidget);
    expect(find.text('아키텍처'), findsOneWidget);
    expect(find.text('기술 스택'), findsOneWidget);
  });

  testWidgets('데모에서 진단, 경로, 코드리뷰 시뮬레이터를 조작할 수 있다', (tester) async {
    await tester.pumpWidget(const DevPathPrototypeApp());

    await tester.tap(find.text('데모'));
    await tester.pumpAndSettle();

    expect(find.text('1. 진단 시뮬레이터'), findsOneWidget);
    expect(find.text('2. 학습경로 생성 시뮬레이터'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('민준'), 180);
    await tester.tap(find.text('민준'));
    await tester.pumpAndSettle();

    expect(find.textContaining('민준 · MID'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('AI 리뷰 실행'), 300);
    await tester.tap(find.text('AI 리뷰 실행'));
    await tester.pumpAndSettle();

    expect(find.text('심각도'), findsOneWidget);
    expect(find.textContaining('NotFoundException'), findsOneWidget);
  });

  testWidgets('모바일 폭에서도 탭 전환이 가능하다', (tester) async {
    tester.view.physicalSize = const Size(390, 840);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const DevPathPrototypeApp());

    expect(find.byType(NavigationBar), findsOneWidget);
    await tester.tap(find.text('기술 스택'));
    await tester.pumpAndSettle();

    expect(find.text('제품 기능, 개발 속도, 운영 안정성을 기준으로 고른 기술 조합'), findsOneWidget);
  });
}
