# DevPath AI — Prototype

**DevPath AI**(한국 백엔드 개발자 커리어 맞춤 AI 학습 플랫폼)의 프로토타입 구현 레포지토리입니다.

## 🎯 목적

[documents](https://github.com/DevPathAi/documents) 레포의 설계 문서와 [storyboard](https://github.com/DevPathAi/storyboard)의 화면 설계를 기반으로 핵심 플로우를 검증합니다.

핵심 검증 대상 — **두 번의 Aha Moment**:
1. **1st Aha**: GitHub 활동 + 진단 결과 기반 AI 개인화 학습 경로 생성 (가입 후 5~8분)
2. **2nd Aha**: Sandbox 실습 후 실무급 AI 코드 리뷰 수신 (첫 세션 30~60분 내)

## 🔑 기술 스택 (계획)

| 영역 | 기술 |
|------|------|
| Backend | Spring Boot 4 (폴백 3.4.x), Java 21, Spring Security 7 (OAuth2) |
| Data | PostgreSQL 17, Redis 7.x, pgvector, Elasticsearch |
| AI | Claude API (Sonnet 4.6 / Haiku 4.5), text-embedding-3-small |
| Sandbox | Docker + gVisor (runsc) |
| Web | React 18 + TypeScript, Zustand, TanStack Query, Monaco Editor |
| Mobile | Flutter 3.x + Riverpod |

## 📐 개발 규칙

- Git 규칙: [documents/09_Git_규칙_정의서](https://github.com/DevPathAi/documents/blob/main/09_Git_규칙_정의서.md) (Conventional Commits)
- 코드 리뷰: [documents/12_코드_리뷰_규칙](https://github.com/DevPathAi/documents/blob/main/12_코드_리뷰_규칙.md)
- 환경 설정: [documents/10_환경_설정_템플릿](https://github.com/DevPathAi/documents/blob/main/10_환경_설정_템플릿.md)

## 📂 구조

웹 프로토타입(Vite + React + TypeScript)이 레포 루트에 위치합니다.

```
prototype/
├── src/            # React 소스 (화면 플로우 프로토타입)
├── public/         # 정적 리소스
├── index.html      # 엔트리
├── vite.config.ts
└── backend/        # Spring Boot 코어 검증용 (필요 시 추가 예정)
```

## 🚀 실행

```bash
npm install
npm run dev      # 개발 서버 (http://localhost:5173)
npm run build    # 프로덕션 빌드 검증
```
