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

  testWidgets('데모 기능을 페이지별 시뮬레이터로 조작할 수 있다', (tester) async {
    await tester.pumpWidget(const DevPathPrototypeApp());

    await tester.tap(find.text('데모'));
    await tester.pumpAndSettle();

    expect(find.text('진단 페이지'), findsWidgets);
    expect(find.text('진단 문항 응답'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('민준'), 180);
    await tester.tap(find.text('민준'));
    await tester.pumpAndSettle();

    expect(find.text('MSA 이벤트 흐름 실무 전환'), findsWidgets);

    await tester.ensureVisible(find.text('학습경로 페이지'));
    await tester.tap(find.text('학습경로 페이지'));
    await tester.pumpAndSettle();
    expect(find.text('학습 실행 보드'), findsOneWidget);

    await tester.ensureVisible(find.text('샌드박스 페이지'));
    await tester.tap(find.text('샌드박스 페이지'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('테스트 실행 및 AI 리뷰'));
    await tester.tap(find.text('테스트 실행 및 AI 리뷰'));
    await tester.pumpAndSettle();

    expect(find.text('심각도'), findsOneWidget);
    expect(find.textContaining('NotFoundException'), findsOneWidget);

    await tester.ensureVisible(find.text('AI 검색 페이지'));
    await tester.tap(find.text('AI 검색 페이지'));
    await tester.pumpAndSettle();
    expect(find.text('검색 조건'), findsOneWidget);
    expect(find.text('추천 근거'), findsOneWidget);
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
