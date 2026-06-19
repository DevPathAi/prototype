import 'models.dart';

const lcsFirstScenario = LearningLoopScenario(
  id: 'lcs-first-backend-task',
  roleLabel: '부트캠프 수료 후 백엔드 취업 준비 중',
  failedTask: '사용자 조회 API에서 존재하지 않는 id를 요청하면 404 Problem 응답을 반환한다.',
  failedCode: '''
@GetMapping("/users/{id}")
UserResponse find(@PathVariable Long id) {
  User user = repo.findById(id).orElse(null);
  return mapper.toResponse(user);
}''',
  testOutput:
      'MockMvc expected status 404 but was 500. mapper.toResponse에서 null 입력 예외 발생.',
  genericReview:
      'null 체크를 추가하고 예외 처리를 해보세요. 컨트롤러에서 입력값 검증과 오류 응답을 분리하면 안정성이 좋아집니다.',
  contextFields: [
    LearningContextField(
      id: ContextFieldId.currentContent,
      value: 'Spring MVC 예외 처리와 ControllerAdvice 단원',
      source: '현재 학습 콘텐츠',
      freshness: '이번 실습 실행',
      defaultIncluded: true,
      sensitive: false,
    ),
    LearningContextField(
      id: ContextFieldId.currentPath,
      value: 'REST Controller 1주차: 상태코드, DTO, MockMvc 테스트',
      source: '학습 경로',
      freshness: '현재 경로 기준',
      defaultIncluded: true,
      sensitive: false,
    ),
    LearningContextField(
      id: ContextFieldId.activeTags,
      value: 'Spring MVC, 오류 모델, 테스트 경계',
      source: '진단 결과',
      freshness: '진단 완료 시점',
      defaultIncluded: true,
      sensitive: false,
    ),
    LearningContextField(
      id: ContextFieldId.recentErrors,
      value: '존재하지 않는 사용자 조회 테스트에서 404 대신 500이 반환됨',
      source: '실습 실행 결과',
      freshness: '이번 실습 실행',
      defaultIncluded: false,
      sensitive: true,
    ),
  ],
  contextualFindings: [
    ContextualFinding(
      requiredFields: {ContextFieldId.currentContent},
      title: '이번 단원의 핵심은 null 처리보다 HTTP 오류 계약입니다',
      body:
          '현재 단원이 ControllerAdvice이므로 단순 null 체크가 아니라 NotFoundException을 404 Problem 응답으로 매핑하는 연습이 우선입니다.',
    ),
    ContextualFinding(
      requiredFields: {ContextFieldId.currentPath},
      title: '다음 경로를 바로 JPA로 넘기면 같은 실수가 반복됩니다',
      body: '현재 1주차 목표가 상태코드와 DTO 분리이므로 저장/조회 로직보다 API 경계 테스트를 먼저 고정해야 합니다.',
    ),
    ContextualFinding(
      requiredFields: {ContextFieldId.activeTags},
      title: '약점 태그가 테스트 경계를 가리킵니다',
      body:
          'Spring MVC와 테스트 경계가 함께 약하므로 MockMvc 실패 메시지를 읽고 expected/actual 상태코드를 연결하는 보강이 필요합니다.',
    ),
    ContextualFinding(
      requiredFields: {ContextFieldId.recentErrors},
      title: '최근 오류는 500의 원인을 구체화합니다',
      body:
          '민감한 원문 로그 대신 sanitizing된 결과만 사용해 mapper null 입력이 500으로 이어졌다는 원인을 확인합니다.',
    ),
  ],
  pathBefore: '다음 과제: JPA 트랜잭션 기초로 이동',
  pathAfter:
      '보정 과제: NotFoundException, ControllerAdvice, MockMvc 404 검증을 한 번 더 수행',
  pathReason: '승인된 LCS가 아직 REST 오류 계약과 테스트 경계가 흔들린다는 증거를 제공했기 때문입니다.',
  evidence: EmploymentEvidence(
    verifiedOutcome: '실패 원인과 기대 상태코드가 분리되어 재실행 기준이 명확해짐',
    beforeCorrection: 'null 반환으로 mapper 예외와 500 응답이 섞임',
    afterCorrection: '도메인 예외를 404 Problem 응답으로 매핑하고 MockMvc가 계약을 검증',
    competencyTags: ['REST 오류 모델', 'Spring MVC 예외 처리', 'MockMvc 계약 테스트'],
    nextTask: '동일 패턴을 게시글 조회 API에 적용하고 400/404/409 응답을 비교한다.',
  ),
);

class ScenarioCatalogResult {
  const ScenarioCatalogResult._({this.scenario, this.error});

  const ScenarioCatalogResult.valid(LearningLoopScenario scenario)
    : this._(scenario: scenario);

  const ScenarioCatalogResult.invalid(String error) : this._(error: error);

  final LearningLoopScenario? scenario;
  final String? error;

  bool get isValid => scenario != null;
}

ScenarioCatalogResult validateScenarioCatalog([
  LearningLoopScenario scenario = lcsFirstScenario,
]) {
  final requiredFields = ContextFieldId.values.toSet();
  final actualFields = scenario.contextFields.map((field) => field.id).toSet();
  if (!actualFields.containsAll(requiredFields) ||
      actualFields.length != requiredFields.length) {
    return const ScenarioCatalogResult.invalid('LCS 필드 계약이 일치하지 않습니다.');
  }

  final values = <String>[
    scenario.roleLabel,
    scenario.failedTask,
    scenario.failedCode,
    scenario.testOutput,
    scenario.genericReview,
    scenario.pathBefore,
    scenario.pathAfter,
    scenario.pathReason,
    scenario.evidence.verifiedOutcome,
    scenario.evidence.beforeCorrection,
    scenario.evidence.afterCorrection,
    scenario.evidence.nextTask,
    for (final field in scenario.contextFields) field.value,
    for (final finding in scenario.contextualFindings) finding.body,
  ];

  for (final value in values) {
    if (_containsSensitiveFixture(value)) {
      return const ScenarioCatalogResult.invalid('민감한 fixture 값이 감지되었습니다.');
    }
  }

  if (scenario.contextualFindings.isEmpty ||
      scenario.pathBefore == scenario.pathAfter ||
      scenario.evidence.competencyTags.isEmpty) {
    return const ScenarioCatalogResult.invalid('파생 결과를 만들 source fact가 부족합니다.');
  }

  return ScenarioCatalogResult.valid(scenario);
}

bool isSensitiveFixtureValue(String value) => _containsSensitiveFixture(value);

bool _containsSensitiveFixture(String value) {
  final patterns = [
    RegExp(r'[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}'),
    RegExp(
      r'(api[_-]?key|secret|token)\s*[:=]\s*[A-Za-z0-9_-]{8,}',
      caseSensitive: false,
    ),
    RegExp(r'\b(bearer|sk-)\s*[A-Za-z0-9_-]{8,}', caseSensitive: false),
    RegExp(r'[A-Za-z]:\\[^ ]+'),
    RegExp(r'/Users/[^ ]+|/home/[^ ]+'),
    RegExp(r'주민등록|전화번호|휴대폰|실명'),
  ];
  return patterns.any((pattern) => pattern.hasMatch(value));
}
