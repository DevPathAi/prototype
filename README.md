# DevPath AI — Flutter 프로토타입

**DevPath AI** 공개 프로토타입 쇼케이스입니다. 프로젝트 소개, 실제 서비스 일부를 흉내 내는 데모, 아키텍처 구조, 기술 스택 설명을 하나의 Flutter Web 페이지로 제공합니다.

## 목적

이 레포는 심사위원, 멘토, 초기 사용자, 협업자가 DevPath AI의 핵심 경험을 빠르게 이해하도록 돕는 공개 페이지입니다.

- **프로젝트 소개**: DevPath AI가 해결하려는 문제와 두 번의 Aha Moment를 설명합니다.
- **데모**: 진단 카드 선택 → 추천 학습경로 → AI 코드리뷰 예시 흐름을 정적 데이터와 로컬 상태로 체험합니다.
- **아키텍처 구조**: Flutter 클라이언트, 게이트웨이, 도메인 서비스, 데이터/이벤트/AI 계층을 시각적으로 보여줍니다.
- **기술 스택**: 기술 종류, 채택 이유, 개념, DevPath에서의 사용 방법을 정리합니다.

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| UI | Flutter Web, Material 3 |
| 상태 | StatefulWidget 기반 로컬 상태 |
| 배포 | GitHub Actions, GitHub Pages |
| 검증 | flutter analyze, flutter test, flutter build web |

이번 프로토타입은 실제 백엔드 API를 호출하지 않습니다. 공개 페이지에서 안정적으로 보여줄 수 있도록 모든 데이터는 정적 샘플로 구성합니다.

## 로컬 실행

```bash
flutter pub get
flutter run -d chrome
```

## 검증

```bash
flutter analyze
flutter test
flutter build web --release --base-href /prototype/
```

## 배포

`main` 브랜치에 push하면 `.github/workflows/pages.yml`이 실행됩니다.

배포 대상:

```text
https://devpathai.github.io/prototype/
```

GitHub 저장소 Settings에서 Pages source가 **GitHub Actions**로 설정되어 있어야 합니다.

## 개발 규칙

- 사용자에게 보이는 문구와 문서는 한국어로 작성합니다.
- 코드 식별자, 명령어, API path, 기술명은 원문을 유지합니다.
- 실제 API 연동, 인증, 서버 상태 저장은 이 프로토타입 범위 밖입니다.
