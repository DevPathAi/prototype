# DevPath AI — Flutter 프로토타입

**DevPath AI** 공개 프로토타입 쇼케이스입니다. 프로젝트 소개, LCS 우선 3분 가이드 데모, 기존 기능 탐색, 아키텍처 구조, 기술 스택 설명을 하나의 Flutter Web 페이지로 제공합니다.

## 목적

이 레포는 심사위원, 멘토, 초기 사용자, 협업자가 DevPath AI의 핵심 경험을 빠르게 이해하도록 돕는 공개 페이지입니다.

- **프로젝트 소개**: DevPath AI가 해결하려는 문제와 두 번의 Aha Moment를 설명합니다.
- **데모**: 실습 실패, 일반 AI 한계, 학습자 승인 LCS, 맥락 기반 리뷰, 학습경로 보정, 취업 준비 증거/멘토 요약을 하나의 학습 루프로 체험합니다.
- **기능 탐색**: 진단, 학습경로 생성, 샌드박스 코드리뷰, AI 검색/추천 독립 시뮬레이터를 보조 경로로 유지합니다.
- **아키텍처 구조**: Flutter 클라이언트, 게이트웨이, 도메인 서비스, 데이터/이벤트/AI 계층, 서비스 책임, 요청 흐름, 서비스 간 통신, 데이터 도메인 소유권, 배포 경계를 시각적으로 보여줍니다.
- **기술 스택**: 기술 종류, 채택 이유, 개념, DevPath에서의 사용 방법, 운영 포인트를 정리합니다.

## 기술 스택

| 영역 | 기술 |
| --- | --- |
| UI | Flutter Web, Material 3 |
| 상태 | StatefulWidget 기반 로컬 시뮬레이터 상태 + 순수 reducer 기반 가이드 루프 상태 |
| 배포 | GitHub Actions, GitHub Pages |
| 검증 | flutter analyze, flutter test, flutter build web |

이번 프로토타입은 실제 백엔드 API를 호출하지 않습니다. 공개 페이지에서 안정적으로 보여줄 수 있도록 모든 데이터는 정적 샘플로 구성합니다.

## LCS 우선 가이드 루프

기본 데모는 `실습 실패 -> 일반 AI 한계 -> LCS 승인 컨텍스트 -> 맥락 기반 리뷰 -> 학습경로 보정 -> 취업 준비 증거/멘토 요약` 순서로 진행합니다.

- `currentContent`, `currentPath`, `activeTags`는 기본 포함됩니다.
- 정제된 `recentErrors`는 기본 제외되며 학습자가 명시적으로 켤 수 있습니다.
- 비활성 LCS 값은 리뷰, 경로 보정, 증거, 멘토 요약, 클립보드 내용에 포함되지 않습니다.
- 화면에 보이는 멘토 요약과 복사되는 내용은 동일합니다.

## 기능 탐색 시뮬레이터

- **진단 페이지**: 실제 온보딩/진단 화면처럼 학습자를 선택하고, 문항 응답, 역량 점수, 자동 판정 리포트를 확인합니다.
- **학습경로 페이지**: 목표 트랙, 주간 학습 시간, 약점 영역을 조정하고 생성된 경로와 학습 실행 보드를 확인합니다.
- **샌드박스 페이지**: 실습 코드를 선택하고 테스트 실행 및 AI 리뷰를 눌러 실행 콘솔, 심각도, 리뷰 요약, 수정 제안을 확인합니다.
- **AI 검색 페이지**: 검색 의도와 pgvector 포함 여부를 바꾸며 키워드/임베딩 혼합 추천 결과와 추천 근거를 비교합니다.

## 아키텍처 설명 범위

- **구성 검증**: 현재 구조를 순수 MSA가 아니라 폴리레포 서비스 + 중앙 PostgreSQL/Flyway 스키마를 쓰는 `분산형 모듈러 모놀리스`로 설명합니다.
- **통신 흐름**: Flutter 클라이언트는 게이트웨이만 호출하고, 게이트웨이가 platform/learning/ai/sandbox/community 서비스로 라우팅합니다.
- **도메인 간 통신**: 동기 요청은 HTTP/API 계약으로, 부작용과 상태 전파는 Transactional Outbox와 Kafka 이벤트로 설명합니다.
- **데이터 도메인**: platform, learning, AI, sandbox, community, operations/event 도메인의 소유 서비스와 주요 테이블을 구분합니다.

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
- 코드 식별자, 명령어, API 경로, 기술명은 원문을 유지합니다.
- 실제 API 연동, 인증, 서버 상태 저장은 이 프로토타입 범위 밖입니다.
