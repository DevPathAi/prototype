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

  testWidgets('데모에서 진단 카드를 선택하면 학습경로와 코드리뷰가 바뀐다', (tester) async {
    await tester.pumpWidget(const DevPathPrototypeApp());

    await tester.tap(find.text('데모'));
    await tester.pumpAndSettle();

    expect(find.text('지수 추천 학습경로'), findsOneWidget);
    await tester.tap(find.text('민준'));
    await tester.pumpAndSettle();

    expect(find.text('민준 추천 학습경로'), findsOneWidget);
    expect(find.text('중복 소비에 대한 방어가 없습니다'), findsOneWidget);
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

    expect(find.text('기술 선택 이유와 DevPath에서의 사용 방법'), findsOneWidget);
  });
}
