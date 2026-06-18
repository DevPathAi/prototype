import 'package:flutter/material.dart';

void main() {
  runApp(const DevPathPrototypeApp());
}

class DevPathPrototypeApp extends StatelessWidget {
  const DevPathPrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DevPath AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F6F68),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F3),
        fontFamily: 'Roboto',
      ),
      home: const PrototypeHomePage(),
    );
  }
}

enum PrototypeSection {
  overview('프로젝트 소개', Icons.auto_awesome_outlined),
  demo('데모', Icons.play_circle_outline),
  architecture('아키텍처', Icons.account_tree_outlined),
  technology('기술 스택', Icons.memory_outlined);

  const PrototypeSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum DemoPage {
  diagnosis('진단 페이지', Icons.fact_check_outlined),
  path('학습경로 페이지', Icons.route_outlined),
  sandbox('샌드박스 페이지', Icons.terminal_outlined),
  search('AI 검색 페이지', Icons.travel_explore_outlined);

  const DemoPage(this.label, this.icon);
  final String label;
  final IconData icon;
}

class PrototypeHomePage extends StatefulWidget {
  const PrototypeHomePage({super.key});

  @override
  State<PrototypeHomePage> createState() => _PrototypeHomePageState();
}

class _PrototypeHomePageState extends State<PrototypeHomePage> {
  PrototypeSection _section = PrototypeSection.overview;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        return Scaffold(
          body: wide ? _DesktopShell(section: _section, onChanged: _setSection) : _MobileShell(section: _section),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _section.index,
                  onDestinationSelected: (index) => _setSection(PrototypeSection.values[index]),
                  destinations: [
                    for (final section in PrototypeSection.values)
                      NavigationDestination(icon: Icon(section.icon), label: section.label),
                  ],
                ),
        );
      },
    );
  }

  void _setSection(PrototypeSection section) {
    setState(() => _section = section);
  }
}

class _DesktopShell extends StatelessWidget {
  const _DesktopShell({required this.section, required this.onChanged});

  final PrototypeSection section;
  final ValueChanged<PrototypeSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: section.index,
          onDestinationSelected: (index) => onChanged(PrototypeSection.values[index]),
          labelType: NavigationRailLabelType.all,
          minWidth: 112,
          backgroundColor: const Color(0xFFE8EEE8),
          leading: const Padding(
            padding: EdgeInsets.only(top: 24, bottom: 20),
            child: _LogoMark(),
          ),
          destinations: [
            for (final item in PrototypeSection.values)
              NavigationRailDestination(icon: Icon(item.icon), label: Text(item.label)),
          ],
        ),
        Expanded(child: _SectionViewport(section: section)),
      ],
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.section});

  final PrototypeSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
          color: const Color(0xFFE8EEE8),
          child: const Row(
            children: [
              _LogoMark(compact: true),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'DevPath AI 프로토타입',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _SectionViewport(section: section)),
      ],
    );
  }
}

class _SectionViewport extends StatelessWidget {
  const _SectionViewport({required this.section});

  final PrototypeSection section;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (section) {
      PrototypeSection.overview => const OverviewSection(),
      PrototypeSection.demo => const DemoSection(),
      PrototypeSection.architecture => const ArchitectureSection(),
      PrototypeSection.technology => const TechnologySection(),
    };
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: child,
          ),
        ),
      ),
    );
  }
}

class OverviewSection extends StatelessWidget {
  const OverviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _HeroBand(),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minItemWidth: 250,
          children: const [
            _MetricTile(label: '1st Aha', value: '진단 → 12주 경로', color: Color(0xFF1F6F68)),
            _MetricTile(label: '2nd Aha', value: '실습 → AI 코드리뷰', color: Color(0xFFB7791F)),
            _MetricTile(label: '현재 초점', value: 'MD1 실연동', color: Color(0xFF9D3A3A)),
          ],
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          eyebrow: '대상 사용자',
          title: '혼자 성장해야 하는 한국 백엔드 개발자를 위한 학습 운영체계',
          body:
              'DevPath AI는 진단, 개인화 경로, 실습 샌드박스, AI 리뷰를 한 흐름으로 묶어 학습자가 다음 행동을 바로 선택하도록 돕습니다.',
        ),
        const SizedBox(height: 16),
        _ResponsiveGrid(
          minItemWidth: 300,
          children: const [
            _InfoCard(
              icon: Icons.psychology_alt_outlined,
              title: '진단 기반 출발점',
              body: 'Bloom 수준과 개념별 강약점을 측정해 불필요한 입문 반복을 줄입니다.',
            ),
            _InfoCard(
              icon: Icons.route_outlined,
              title: '개인화 학습경로',
              body: '진단 결과와 목표 트랙을 바탕으로 주차별 목표, 과제, 기대 역량을 제안합니다.',
            ),
            _InfoCard(
              icon: Icons.terminal_outlined,
              title: '실습과 리뷰',
              body: '코드를 실행하고 AI 리뷰를 받아 실무형 피드백 루프를 만듭니다.',
            ),
          ],
        ),
      ],
    );
  }
}

class DemoSection extends StatefulWidget {
  const DemoSection({super.key});

  @override
  State<DemoSection> createState() => _DemoSectionState();
}

class _DemoSectionState extends State<DemoSection> {
  DemoPage _page = DemoPage.diagnosis;
  DemoProfile _selected = demoProfiles.first;
  String _goal = '백엔드 취업';
  double _weeklyHours = 8;
  final Set<String> _weakAreas = {'Spring MVC', '테스트'};
  String _codeScenario = 'null 응답';
  String _searchQuery = '트랜잭션';
  bool _includeVector = true;
  bool _reviewRequested = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          eyebrow: '데모',
          title: '기능별 독립 페이지로 체험하는 DevPath AI 서비스 화면',
          body:
              '각 데모는 실제 서비스 화면에 가까운 페이지 단위로 구성했습니다. 진단, 학습경로 생성, 샌드박스 코드리뷰, AI 검색을 각각 독립된 시뮬레이터로 조작할 수 있습니다.',
        ),
        const SizedBox(height: 18),
        _DemoPageNavigation(selected: _page, onChanged: (page) => setState(() => _page = page)),
        const SizedBox(height: 18),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: KeyedSubtree(
            key: ValueKey(_page),
            child: switch (_page) {
              DemoPage.diagnosis => _ServiceDemoPage(
                  title: '진단 페이지',
                  subtitle: '온보딩 답변과 역량 점수를 바탕으로 현재 출발점을 판정합니다.',
                  icon: Icons.fact_check_outlined,
                  status: '시뮬레이션 실행 중',
                  child: _DiagnosisSimulator(
                    selected: _selected,
                    onProfileChanged: (profile) => setState(() {
                      _selected = profile;
                      _reviewRequested = false;
                    }),
                  ),
                ),
              DemoPage.path => _ServiceDemoPage(
                  title: '학습경로 페이지',
                  subtitle: '목표, 주간 학습 시간, 약점 영역을 바꿔 추천 경로를 생성합니다.',
                  icon: Icons.route_outlined,
                  status: '경로 생성 준비',
                  child: _PathGeneratorSimulator(
                    profile: _selected,
                    goal: _goal,
                    weeklyHours: _weeklyHours,
                    weakAreas: _weakAreas,
                    onGoalChanged: (goal) => setState(() => _goal = goal),
                    onHoursChanged: (hours) => setState(() => _weeklyHours = hours),
                    onAreaToggled: (area) => setState(() {
                      if (_weakAreas.contains(area)) {
                        _weakAreas.remove(area);
                      } else {
                        _weakAreas.add(area);
                      }
                    }),
                  ),
                ),
              DemoPage.sandbox => _ServiceDemoPage(
                  title: '샌드박스 페이지',
                  subtitle: '실습 코드 샘플을 실행 대상으로 선택하고 AI 코드리뷰 결과를 확인합니다.',
                  icon: Icons.terminal_outlined,
                  status: _reviewRequested ? 'AI 리뷰 완료' : '리뷰 대기',
                  child: _SandboxReviewSimulator(
                    scenario: _codeScenario,
                    reviewRequested: _reviewRequested,
                    onScenarioChanged: (scenario) => setState(() {
                      _codeScenario = scenario;
                      _reviewRequested = false;
                    }),
                    onReviewRequested: () => setState(() => _reviewRequested = true),
                  ),
                ),
              DemoPage.search => _ServiceDemoPage(
                  title: 'AI 검색 페이지',
                  subtitle: '키워드 검색과 pgvector 유사도 후보를 섞어 추천 품질 변화를 비교합니다.',
                  icon: Icons.travel_explore_outlined,
                  status: _includeVector ? 'Hybrid 검색' : 'Keyword 검색',
                  child: _AiSearchSimulator(
                    query: _searchQuery,
                    includeVector: _includeVector,
                    onQueryChanged: (query) => setState(() => _searchQuery = query),
                    onVectorChanged: (value) => setState(() => _includeVector = value),
                  ),
                ),
            },
          ),
        ),
      ],
    );
  }
}

class ArchitectureSection extends StatelessWidget {
  const ArchitectureSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          eyebrow: '아키텍처',
          title: '폴리레포 서비스와 중앙 스키마를 결합한 DevPath AI 아키텍처',
          body:
              '구성 자체는 문서의 방향과 맞습니다. 다만 순수 MSA라기보다 독립 배포 서비스와 단일 PostgreSQL/Flyway 스키마를 함께 쓰는 distributed modular monolith에 가깝습니다. 클라이언트는 gateway만 호출하고, gateway가 도메인 서비스로 라우팅하며, 서비스는 자기 데이터 도메인과 이벤트 계약을 소유합니다.',
        ),
        const SizedBox(height: 20),
        const _ArchitectureValidationSummary(),
        const SizedBox(height: 24),
        const _ArchitectureMap(),
        const SizedBox(height: 24),
        const _CommunicationMatrix(),
        const SizedBox(height: 24),
        const _DataDomainOwnership(),
        const SizedBox(height: 24),
        const _ArchitectureFlow(),
        const SizedBox(height: 24),
        const _ServiceResponsibilityGrid(),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minItemWidth: 300,
          children: const [
            _ArchitectureContract(
              title: 'API 계약',
              icon: Icons.http_outlined,
              lines: [
                'bare path API: /ai/embed, /ai/path/generate',
                'Gateway가 인증/라우팅을 담당하고 서비스는 도메인 계약에 집중',
                'DTO와 오류 응답은 테스트에서 고정',
              ],
            ),
            _ArchitectureContract(
              title: '데이터 경계',
              icon: Icons.table_chart_outlined,
              lines: [
                'shared가 Flyway 스키마와 공통 Docker 구성을 관리',
                '각 서비스는 자기 도메인 테이블만 읽고 씀',
                'pgvector는 콘텐츠 추천 후보 검색에 사용',
              ],
            ),
            _ArchitectureContract(
              title: '운영/배포',
              icon: Icons.cloud_sync_outlined,
              lines: [
                'GitHub Actions가 서비스별 build/test를 수행',
                'GitOps는 환경별 manifest와 secret 경계를 분리',
                '프로토타입은 GitHub Pages에 정적 배포',
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class TechnologySection extends StatelessWidget {
  const TechnologySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          eyebrow: '기술 스택',
          title: '제품 기능, 개발 속도, 운영 안정성을 기준으로 고른 기술 조합',
          body:
              '각 기술은 화면 장식이 아니라 진단 저장, 경로 생성, 샌드박스 실행, AI 리뷰, 검색 추천, 배포 자동화에 직접 연결됩니다. 아래 카드에는 기술 종류, 채택 이유, 핵심 개념, DevPath에서의 사용 방식, 운영 포인트를 함께 정리했습니다.',
        ),
        const SizedBox(height: 18),
        _ResponsiveGrid(
          minItemWidth: 320,
          children: techItems.map((item) => _TechCard(item: item)).toList(),
        ),
      ],
    );
  }
}

class _HeroBand extends StatelessWidget {
  const _HeroBand();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEE8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD0D9D2)),
      ),
      child: Wrap(
        spacing: 28,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('DevPath AI', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, height: 1.1)),
                SizedBox(height: 12),
                Text(
                  '진단부터 학습경로, 샌드박스 실습, AI 코드리뷰까지 연결하는 백엔드 개발자 성장 플랫폼입니다.',
                  style: TextStyle(fontSize: 18, height: 1.55, color: Color(0xFF35443F)),
                ),
              ],
            ),
          ),
          const _FlowPreview(),
        ],
      ),
    );
  }
}

class _FlowPreview extends StatelessWidget {
  const _FlowPreview();

  @override
  Widget build(BuildContext context) {
    const items = [
      ('진단', Icons.fact_check_outlined, Color(0xFF1F6F68)),
      ('경로', Icons.route_outlined, Color(0xFF2D6CDF)),
      ('실습', Icons.terminal_outlined, Color(0xFFB7791F)),
      ('리뷰', Icons.rate_review_outlined, Color(0xFF9D3A3A)),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final item in items)
          Container(
            width: 96,
            height: 92,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: item.$3.withValues(alpha: 0.24)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.$2, color: item.$3),
                const SizedBox(height: 8),
                Text(item.$1, style: const TextStyle(fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.eyebrow, required this.title, required this.body});

  final String eyebrow;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(eyebrow, style: const TextStyle(color: Color(0xFF1F6F68), fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.22)),
        const SizedBox(height: 10),
        Text(body, style: const TextStyle(fontSize: 16, height: 1.55, color: Color(0xFF4D5C57))),
      ],
    );
  }
}

class _ResponsiveGrid extends StatelessWidget {
  const _ResponsiveGrid({required this.children, required this.minItemWidth});

  final List<Widget> children;
  final double minItemWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = (constraints.maxWidth / minItemWidth).floor().clamp(1, 3);
        final itemWidth = (constraints.maxWidth - (columns - 1) * 14) / columns;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final child in children)
              SizedBox(
                width: itemWidth,
                child: child,
              ),
          ],
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFD9DED8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF1F6F68)),
            const SizedBox(height: 14),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(body, style: const TextStyle(height: 1.45, color: Color(0xFF4D5C57))),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _DemoPageNavigation extends StatelessWidget {
  const _DemoPageNavigation({required this.selected, required this.onChanged});

  final DemoPage selected;
  final ValueChanged<DemoPage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final page in DemoPage.values)
            ChoiceChip(
              avatar: Icon(page.icon, size: 18),
              label: Text(page.label),
              selected: page == selected,
              onSelected: (_) => onChanged(page),
            ),
        ],
      ),
    );
  }
}

class _ServiceDemoPage extends StatelessWidget {
  const _ServiceDemoPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.child,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String status;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFE8EEE8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F6F68),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(height: 1.35, color: Color(0xFF4D5C57))),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Chip(
                  label: Text(status),
                  side: const BorderSide(color: Color(0xFF1F6F68)),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _StatusPill(label: 'API', value: 'Mock'),
                _StatusPill(label: '저장', value: '로컬 상태'),
                _StatusPill(label: '모드', value: '시뮬레이터'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Text('$label: $value', style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}

class _DiagnosisSimulator extends StatelessWidget {
  const _DiagnosisSimulator({required this.selected, required this.onProfileChanged});

  final DemoProfile selected;
  final ValueChanged<DemoProfile> onProfileChanged;

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minItemWidth: 300,
      children: [
        _Panel(
          title: '학습자 선택',
          icon: Icons.people_alt_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('실제 서비스의 진단 시작 화면처럼 학습자 상태를 선택해 결과 변화를 확인합니다.',
                  style: TextStyle(height: 1.45, color: Color(0xFF4D5C57))),
              const SizedBox(height: 14),
              for (final profile in demoProfiles)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SelectableDemoCard(
                    profile: profile,
                    selected: profile == selected,
                    onTap: () => onProfileChanged(profile),
                  ),
                ),
            ],
          ),
        ),
        _OnboardingAnswers(profile: selected),
        _SkillRadar(profile: selected),
        _DiagnosisResult(profile: selected),
      ],
    );
  }
}

class _OnboardingAnswers extends StatelessWidget {
  const _OnboardingAnswers({required this.profile});

  final DemoProfile profile;

  @override
  Widget build(BuildContext context) {
    final answers = [
      ('목표', profile.track),
      ('최근 경험', profile.level),
      ('가장 막히는 지점', profile.priority),
      ('선호 피드백', '짧은 실습 → 즉시 리뷰 → 다음 과제 추천'),
    ];
    return _Panel(
      title: '진단 문항 응답',
      icon: Icons.assignment_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final answer in answers)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8F3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFD9DED8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(answer.$1, style: const TextStyle(color: Color(0xFF1F6F68), fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(answer.$2, style: const TextStyle(height: 1.35)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SkillRadar extends StatelessWidget {
  const _SkillRadar({required this.profile});

  final DemoProfile profile;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: '진단 점수',
      icon: Icons.analytics_outlined,
      child: Column(
        children: [
          for (final skill in profile.skills)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(skill.$1, style: const TextStyle(fontWeight: FontWeight.w800))),
                      Text('${(skill.$2 * 100).round()}점'),
                    ],
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: skill.$2,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(8),
                    color: skill.$2 >= 0.7
                        ? const Color(0xFF1F6F68)
                        : skill.$2 >= 0.45
                            ? const Color(0xFFB7791F)
                            : const Color(0xFF9D3A3A),
                    backgroundColor: const Color(0xFFE8EEE8),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DiagnosisResult extends StatelessWidget {
  const _DiagnosisResult({required this.profile});

  final DemoProfile profile;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: '자동 판정',
      icon: Icons.psychology_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultLine(label: '권장 트랙', value: profile.track),
          _ResultLine(label: '우선 보강', value: profile.priority),
          _ResultLine(label: 'Aha 포인트', value: profile.aha),
          const SizedBox(height: 12),
          Text(profile.summary, style: const TextStyle(height: 1.45, color: Color(0xFF4D5C57))),
        ],
      ),
    );
  }
}

class _PathGeneratorSimulator extends StatelessWidget {
  const _PathGeneratorSimulator({
    required this.profile,
    required this.goal,
    required this.weeklyHours,
    required this.weakAreas,
    required this.onGoalChanged,
    required this.onHoursChanged,
    required this.onAreaToggled,
  });

  final DemoProfile profile;
  final String goal;
  final double weeklyHours;
  final Set<String> weakAreas;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<double> onHoursChanged;
  final ValueChanged<String> onAreaToggled;

  @override
  Widget build(BuildContext context) {
    final totalWeeks = weeklyHours >= 10 ? 8 : weeklyHours >= 6 ? 10 : 12;
    final intensity = weeklyHours >= 10 ? '집중형' : weeklyHours >= 6 ? '균형형' : '완주형';
    return _ResponsiveGrid(
      minItemWidth: 340,
      children: [
        _Panel(
          title: '입력값',
          icon: Icons.tune_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('목표 트랙', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in const ['백엔드 취업', '실무 전환', 'AI 검색 고도화'])
                    ChoiceChip(
                      label: Text(item),
                      selected: goal == item,
                      onSelected: (_) => onGoalChanged(item),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('주간 학습 시간: ${weeklyHours.round()}시간', style: const TextStyle(fontWeight: FontWeight.w800)),
              Slider(value: weeklyHours, min: 3, max: 14, divisions: 11, onChanged: onHoursChanged),
              const SizedBox(height: 10),
              const Text('집중 보강 영역', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final area in const ['Spring MVC', 'JPA', '테스트', 'Kafka', 'pgvector'])
                    FilterChip(
                      label: Text(area),
                      selected: weakAreas.contains(area),
                      onSelected: (_) => onAreaToggled(area),
                    ),
                ],
              ),
            ],
          ),
        ),
        _Panel(
          title: '생성 결과',
          icon: Icons.map_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultLine(label: '경로 타입', value: '$goal · $intensity · $totalWeeks주'),
              _ResultLine(label: '학습자 기준', value: '${profile.name} · ${profile.level}'),
              _ResultLine(label: '핵심 보강', value: weakAreas.isEmpty ? profile.priority : weakAreas.join(', ')),
              const SizedBox(height: 12),
              for (final week in _generatedWeeks(profile, goal, totalWeeks, weakAreas))
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PathStep(week: week.$1, title: week.$2, body: week.$3),
                ),
            ],
          ),
        ),
        _PathExecutionBoard(profile: profile, goal: goal, totalWeeks: totalWeeks),
      ],
    );
  }
}

class _PathExecutionBoard extends StatelessWidget {
  const _PathExecutionBoard({required this.profile, required this.goal, required this.totalWeeks});

  final DemoProfile profile;
  final String goal;
  final int totalWeeks;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: '학습 실행 보드',
      icon: Icons.dashboard_customize_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ResultLine(label: '현재 주차', value: '1 / $totalWeeks주'),
          _ResultLine(label: '이번 목표', value: '$goal 첫 과제 제출'),
          _ResultLine(label: '연동 기능', value: '샌드박스 실행, AI 리뷰, 다음 과제 자동 추천'),
          const SizedBox(height: 12),
          for (final task in [
            ('개념 카드 3개 확인', true),
            ('API 과제 요구사항 읽기', true),
            ('샌드박스 코드 제출', false),
            ('AI 리뷰 반영 후 재제출', false),
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    task.$2 ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: task.$2 ? const Color(0xFF1F6F68) : const Color(0xFF697772),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(task.$1)),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '${profile.name}에게는 완료 여부보다 막힌 지점의 종류를 다음 진단 데이터로 남기는 흐름이 중요합니다.',
            style: const TextStyle(height: 1.45, color: Color(0xFF4D5C57)),
          ),
        ],
      ),
    );
  }
}

class _SandboxReviewSimulator extends StatelessWidget {
  const _SandboxReviewSimulator({
    required this.scenario,
    required this.reviewRequested,
    required this.onScenarioChanged,
    required this.onReviewRequested,
  });

  final String scenario;
  final bool reviewRequested;
  final ValueChanged<String> onScenarioChanged;
  final VoidCallback onReviewRequested;

  @override
  Widget build(BuildContext context) {
    final sample = codeSamples[scenario]!;
    return _ResponsiveGrid(
      minItemWidth: 340,
      children: [
        _Panel(
          title: '실습 선택',
          icon: Icons.folder_open_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('실제 서비스의 샌드박스 목록처럼 리뷰할 과제를 선택합니다.',
                  style: TextStyle(height: 1.45, color: Color(0xFF4D5C57))),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in codeSamples.keys)
                    ChoiceChip(
                      label: Text(name),
                      selected: scenario == name,
                      onSelected: (_) => onScenarioChanged(name),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              _CodeBlock(text: sample.code),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: onReviewRequested,
                icon: const Icon(Icons.play_arrow_outlined),
                label: const Text('테스트 실행 및 AI 리뷰'),
              ),
            ],
          ),
        ),
        _Panel(
          title: '실행 콘솔',
          icon: Icons.bug_report_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ConsoleLine(status: 'PASS', text: '컴파일 및 기본 테스트 실행'),
              _ConsoleLine(status: scenario == 'null 응답' ? 'FAIL' : 'WARN', text: sample.severity),
              _ConsoleLine(status: 'INFO', text: '리뷰 대상 diff와 실행 로그를 AI 리뷰 입력으로 전달'),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: reviewRequested
                    ? Column(
                        key: ValueKey(scenario),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ResultLine(label: '심각도', value: sample.severity),
                          _ResultLine(label: '리뷰 요약', value: sample.review),
                          _ResultLine(label: '수정 제안', value: sample.fix),
                        ],
                      )
                    : const Text('테스트 실행 및 AI 리뷰 버튼을 누르면 실행 로그와 리뷰 결과가 이 영역에 표시됩니다.',
                        style: TextStyle(height: 1.45, color: Color(0xFF4D5C57))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConsoleLine extends StatelessWidget {
  const _ConsoleLine({required this.status, required this.text});

  final String status;
  final String text;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'PASS' => const Color(0xFF1F6F68),
      'FAIL' => const Color(0xFF9D3A3A),
      'WARN' => const Color(0xFFB7791F),
      _ => const Color(0xFF2D6CDF),
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2523),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('[$status] $text', style: TextStyle(color: color, fontFamily: 'monospace', height: 1.35)),
    );
  }
}

class _AiSearchSimulator extends StatelessWidget {
  const _AiSearchSimulator({
    required this.query,
    required this.includeVector,
    required this.onQueryChanged,
    required this.onVectorChanged,
  });

  final String query;
  final bool includeVector;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<bool> onVectorChanged;

  @override
  Widget build(BuildContext context) {
    final results = searchResults[query]!;
    return _ResponsiveGrid(
      minItemWidth: 340,
      children: [
        _Panel(
          title: '검색 조건',
          icon: Icons.manage_search_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8F3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFD9DED8)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF1F6F68)),
                    const SizedBox(width: 10),
                    Expanded(child: Text('검색어: $query', style: const TextStyle(fontWeight: FontWeight.w800))),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in searchResults.keys)
                    ChoiceChip(
                      label: Text(item),
                      selected: query == item,
                      onSelected: (_) => onQueryChanged(item),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Switch(value: includeVector, onChanged: onVectorChanged),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('pgvector 유사도 후보 포함', style: TextStyle(fontWeight: FontWeight.w800)),
                        SizedBox(height: 4),
                        Text(
                          '키워드 검색 결과와 임베딩 검색 결과를 함께 섞어 추천합니다.',
                          style: TextStyle(height: 1.35, color: Color(0xFF4D5C57)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ResultLine(label: '검색 방식', value: includeVector ? 'BM25 + vector hybrid ranking' : 'keyword ranking only'),
              _ResultLine(label: '후보 소스', value: '학습 콘텐츠, 실습 과제, 코드리뷰 패턴'),
            ],
          ),
        ),
        _Panel(
          title: '추천 결과',
          icon: Icons.recommend_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final result in results)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SearchResultTile(result: result, includeVector: includeVector),
                ),
            ],
          ),
        ),
        _Panel(
          title: '추천 근거',
          icon: Icons.insights_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ResultLine(label: '상위 결과', value: results.first.title),
              _ResultLine(label: '근거', value: results.first.reason),
              _ResultLine(label: '다음 행동', value: '선택한 콘텐츠를 현재 학습경로의 보강 과제로 추가'),
              const SizedBox(height: 10),
              Text(
                includeVector
                    ? '유사도 후보를 포함하면 단어가 직접 일치하지 않아도 같은 학습 의도를 가진 콘텐츠가 올라옵니다.'
                    : '키워드 검색만 사용하면 정확히 일치하는 제목과 태그가 우선되지만, 맥락이 비슷한 자료는 밀릴 수 있습니다.',
                style: const TextStyle(height: 1.45, color: Color(0xFF4D5C57)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            child: Text(label, style: const TextStyle(color: Color(0xFF1F6F68), fontWeight: FontWeight.w800)),
          ),
          Expanded(child: Text(value, style: const TextStyle(height: 1.35))),
        ],
      ),
    );
  }
}

class _PathStep extends StatelessWidget {
  const _PathStep({required this.week, required this.title, required this.body});

  final int week;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: const Color(0xFF1F6F68),
          foregroundColor: Colors.white,
          child: Text('$week', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(body, style: const TextStyle(color: Color(0xFF4D5C57), height: 1.35)),
            ],
          ),
        ),
      ],
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2523),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Color(0xFFE7F4EE), fontFamily: 'monospace', height: 1.45)),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result, required this.includeVector});

  final SearchResult result;
  final bool includeVector;

  @override
  Widget build(BuildContext context) {
    final score = includeVector ? result.hybridScore : result.keywordScore;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(result.title, style: const TextStyle(fontWeight: FontWeight.w900))),
              Text('${(score * 100).round()}점', style: const TextStyle(color: Color(0xFF1F6F68))),
            ],
          ),
          const SizedBox(height: 6),
          Text(result.reason, style: const TextStyle(height: 1.35, color: Color(0xFF4D5C57))),
        ],
      ),
    );
  }
}

class _SelectableDemoCard extends StatelessWidget {
  const _SelectableDemoCard({required this.profile, required this.selected, required this.onTap});

  final DemoProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFE1F3EE) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? const Color(0xFF1F6F68) : const Color(0xFFD9DED8), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(profile.level, style: const TextStyle(color: Color(0xFF1F6F68), fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Text(profile.summary, style: const TextStyle(height: 1.4)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF1F6F68)),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ArchitectureMap extends StatelessWidget {
  const _ArchitectureMap();

  @override
  Widget build(BuildContext context) {
    final rows = [
      ('클라이언트', ['Flutter Web', '관리자', '모바일'], const Color(0xFF2D6CDF)),
      ('게이트웨이', ['Spring Cloud Gateway', 'JWT', 'OAuth'], const Color(0xFF1F6F68)),
      ('도메인 서비스', ['platform', 'learning', 'ai', 'sandbox', 'community'], const Color(0xFFB7791F)),
      ('데이터/이벤트', ['PostgreSQL', 'pgvector', 'Redis', 'Kafka', 'Ollama'], const Color(0xFF9D3A3A)),
    ];
    const connectors = [
      'HTTPS 요청 · JWT 전달',
      'Path 기반 라우팅 · 인증 컨텍스트 전파',
      '도메인 DB 접근 · Outbox/Kafka 이벤트 · AI 호출',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _ArchitectureRow(title: rows[i].$1, chips: rows[i].$2, color: rows[i].$3),
            if (i < rows.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: _ArchitectureConnector(label: connectors[i]),
              ),
          ],
        ],
      ),
    );
  }
}

class _ArchitectureConnector extends StatelessWidget {
  const _ArchitectureConnector({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 120),
        Expanded(
          child: Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFD0D9D2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Chip(
                  label: Text(label),
                  avatar: const Icon(Icons.arrow_downward, size: 16),
                  side: const BorderSide(color: Color(0xFFD0D9D2)),
                  backgroundColor: const Color(0xFFF7F8F3),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFD0D9D2))),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArchitectureValidationSummary extends StatelessWidget {
  const _ArchitectureValidationSummary();

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minItemWidth: 320,
      children: const [
        _ArchitectureContract(
          title: '구성 검증 결과',
          icon: Icons.verified_outlined,
          lines: [
            '클라이언트 → Gateway → 도메인 서비스 → 데이터/이벤트 계층 구조는 프로젝트 문서와 일치',
            '서비스 레포는 분리되어 있지만 DB 스키마는 devpath-shared/Flyway가 중앙 관리',
            'Sandbox는 보안상 별도 서비스와 격리 실행 환경으로 두는 구성이 타당',
          ],
        ),
        _ArchitectureContract(
          title: '보정한 표현',
          icon: Icons.tune_outlined,
          lines: [
            '순수 MSA가 아니라 distributed modular monolith 성격으로 표기',
            '현재 구현 라우트와 목표 라우트를 구분',
            'ai-svc는 현재 Build B 기준 Ollama 게이트웨이이며, 상위 AI provider는 교체 가능한 후방 계약',
          ],
        ),
        _ArchitectureContract(
          title: '경계 원칙',
          icon: Icons.fence_outlined,
          lines: [
            '클라이언트는 도메인 서비스를 직접 호출하지 않고 Gateway만 호출',
            '서비스는 자기 도메인 테이블과 API DTO를 소유',
            '교차 서비스 부작용은 직접 DB 수정이 아니라 Outbox/Kafka 이벤트로 전달',
          ],
        ),
      ],
    );
  }
}

class _CommunicationMatrix extends StatelessWidget {
  const _CommunicationMatrix();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: '클라이언트·게이트웨이·도메인 서비스 통신',
      icon: Icons.compare_arrows_outlined,
      child: Column(
        children: const [
          _CommunicationRow(
            from: 'Flutter Web/Mobile',
            to: 'devpath-gateway',
            protocol: 'HTTPS + JSON',
            contract: 'access token은 Authorization header, refresh는 httpOnly cookie 기준. 클라이언트는 내부 서비스 주소를 모릅니다.',
          ),
          _CommunicationRow(
            from: 'devpath-gateway',
            to: 'platform-svc',
            protocol: 'Route by path',
            contract: '현재 구현: /oauth2/**, /login/**, /auth/**, /users/** → platform. OAuth/JWT 발급, 사용자/프로필 조회 담당.',
          ),
          _CommunicationRow(
            from: 'devpath-gateway',
            to: 'learning-svc',
            protocol: 'Route by path',
            contract: '현재 구현: /onboarding/assessments/** → learning. 진단, 온보딩 평가, 학습경로 생성 진입점.',
          ),
          _CommunicationRow(
            from: 'learning-svc',
            to: 'ai-svc',
            protocol: 'Internal HTTP',
            contract: '학습경로 생성과 임베딩 요청을 /ai/path/generate, /ai/embed 계약으로 위임. ai-svc는 Ollama/LLM 세부사항을 숨깁니다.',
          ),
          _CommunicationRow(
            from: 'learning-svc / frontend',
            to: 'sandbox-svc',
            protocol: 'Gateway route + service API',
            contract: '학습 과제의 runnable code block을 실행 요청으로 보내고, sandbox는 실행 로그와 테스트 결과를 저장합니다.',
          ),
          _CommunicationRow(
            from: 'sandbox-svc',
            to: 'ai-svc',
            protocol: 'Event or worker call',
            contract: 'SandboxRunSubmittedEvent 이후 AI Review Worker가 코드, 테스트 실패, stdout/stderr를 리뷰 입력으로 전달합니다.',
          ),
          _CommunicationRow(
            from: '도메인 서비스',
            to: 'Kafka',
            protocol: 'Transactional Outbox',
            contract: '비즈니스 데이터와 outbox_events를 같은 PostgreSQL 트랜잭션에 저장한 뒤 relay가 Kafka로 발행합니다.',
          ),
        ],
      ),
    );
  }
}

class _CommunicationRow extends StatelessWidget {
  const _CommunicationRow({
    required this.from,
    required this.to,
    required this.protocol,
    required this.contract,
  });

  final String from;
  final String to;
  final String protocol;
  final String contract;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _FlowChip(text: from, color: const Color(0xFF2D6CDF)),
              const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF697772)),
              _FlowChip(text: to, color: const Color(0xFF1F6F68)),
              _FlowChip(text: protocol, color: const Color(0xFFB7791F)),
            ],
          ),
          const SizedBox(height: 8),
          Text(contract, style: const TextStyle(height: 1.4, color: Color(0xFF4D5C57))),
        ],
      ),
    );
  }
}

class _FlowChip extends StatelessWidget {
  const _FlowChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800)),
    );
  }
}

class _DataDomainOwnership extends StatelessWidget {
  const _DataDomainOwnership();

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: '데이터 도메인과 소유 서비스',
      icon: Icons.schema_outlined,
      child: _ResponsiveGrid(
        minItemWidth: 280,
        children: const [
          _DataDomainCard(
            domain: 'Platform',
            owner: 'platform-svc',
            tables: 'users, user_profiles, user_oauth_identities, github_profiles',
            communication: 'Gateway 라우트로 사용자/인증 요청 처리. 온보딩 상태는 learning 이벤트를 소비해 갱신.',
          ),
          _DataDomainCard(
            domain: 'Learning',
            owner: 'learning-svc',
            tables: 'assessments, learning_paths, path_milestones, path_weekly_tasks, contents, content_embeddings',
            communication: '진단/경로 API를 제공하고 ai-svc에 생성/임베딩 요청. 완료 이벤트를 Outbox로 발행.',
          ),
          _DataDomainCard(
            domain: 'AI',
            owner: 'ai-svc',
            tables: 'ai_code_reviews, ai_mentor_sessions, ai_cost_logs',
            communication: '현재 Build B는 무상태 Ollama Gateway. 리뷰/멘토/비용 로그는 후속 빌드에서 저장 도메인으로 확장.',
          ),
          _DataDomainCard(
            domain: 'Sandbox',
            owner: 'sandbox-svc',
            tables: 'sandbox_sessions, sandbox_test_results, sandbox_quotas, sandbox_abuse_logs',
            communication: '실습 코드를 격리 실행하고 결과를 저장. 리뷰 필요 시 SandboxRunSubmittedEvent를 발행.',
          ),
          _DataDomainCard(
            domain: 'Community',
            owner: 'community-svc',
            tables: 'community_posts, answers, votes, reputation, badges, learning_context_snapshots',
            communication: '질문/답변/평판을 소유. 학습 맥락은 이벤트 또는 worker로 learning 데이터의 스냅샷만 참조.',
          ),
          _DataDomainCard(
            domain: 'Operations/Event',
            owner: 'devpath-shared + 각 서비스',
            tables: 'outbox_events, audit_logs, progress_events',
            communication: '스키마는 shared가 관리하고, 이벤트 row는 생산 서비스가 같은 트랜잭션에서 기록.',
          ),
        ],
      ),
    );
  }
}

class _DataDomainCard extends StatelessWidget {
  const _DataDomainCard({
    required this.domain,
    required this.owner,
    required this.tables,
    required this.communication,
  });

  final String domain;
  final String owner;
  final String tables;
  final String communication;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(domain, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          _ResultLine(label: '소유', value: owner),
          _ResultLine(label: '테이블', value: tables),
          _ResultLine(label: '통신', value: communication),
        ],
      ),
    );
  }
}

class _ArchitectureFlow extends StatelessWidget {
  const _ArchitectureFlow();

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('1', '진단 제출', 'Flutter Web이 답변과 목표 트랙을 gateway로 전송합니다.'),
      ('2', '도메인 처리', 'learning-svc가 진단 점수, 약점, 경로 생성 요청을 정규화합니다.'),
      ('3', 'AI 보조 생성', 'ai-svc가 Ollama chat/embed 계약으로 후보 경로와 콘텐츠 유사도를 계산합니다.'),
      ('4', '학습 실행', 'sandbox-svc가 실습 실행과 코드리뷰 입력을 만들고 결과를 learning-svc에 돌려줍니다.'),
      ('5', '상태 전파', 'Kafka/Outbox가 진단 완료, 경로 생성, 리뷰 완료 이벤트를 안전하게 전달합니다.'),
    ];
    return _Panel(
      title: '주요 사용자 흐름',
      icon: Icons.alt_route_outlined,
      child: Column(
        children: [
          for (final step in steps)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PathStep(week: int.parse(step.$1), title: step.$2, body: step.$3),
            ),
        ],
      ),
    );
  }
}

class _ServiceResponsibilityGrid extends StatelessWidget {
  const _ServiceResponsibilityGrid();

  @override
  Widget build(BuildContext context) {
    return _ResponsiveGrid(
      minItemWidth: 280,
      children: const [
        _ServiceCard(name: 'devpath-gateway', role: '인증, CORS, 라우팅, API 진입점', data: '토큰 검증, 요청 상관관계 ID'),
        _ServiceCard(name: 'platform-svc', role: '회원, 프로필, 온보딩 상태', data: 'users, profiles, onboarding_state'),
        _ServiceCard(name: 'learning-svc', role: '진단, 학습경로, 콘텐츠 매칭', data: 'diagnoses, learning_paths, progress'),
        _ServiceCard(name: 'ai-svc', role: 'Ollama 게이트웨이, 임베딩, 구조화 생성', data: '상태 없음, 외부 AI 호출 계약만 소유'),
        _ServiceCard(name: 'sandbox-svc', role: '코드 실행, 테스트 결과, 리뷰 입력 생성', data: 'submissions, run_logs, review_targets'),
        _ServiceCard(name: 'community-svc', role: '질문, 회고, 학습 공유', data: 'posts, comments, reactions'),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.name, required this.role, required this.data});

  final String name;
  final String role;
  final String data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD9DED8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(role, style: const TextStyle(height: 1.4)),
          const SizedBox(height: 10),
          Text('소유 데이터: $data', style: const TextStyle(height: 1.35, color: Color(0xFF4D5C57))),
        ],
      ),
    );
  }
}

class _ArchitectureContract extends StatelessWidget {
  const _ArchitectureContract({required this.title, required this.icon, required this.lines});

  final String title;
  final IconData icon;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: title,
      icon: icon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18, color: Color(0xFF1F6F68)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(line, style: const TextStyle(height: 1.35))),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ArchitectureRow extends StatelessWidget {
  const _ArchitectureRow({required this.title, required this.chips, required this.color});

  final String title;
  final List<String> chips;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w900)),
        ),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final chip in chips)
                Chip(
                  label: Text(chip),
                  side: BorderSide(color: color.withValues(alpha: 0.22)),
                  backgroundColor: color.withValues(alpha: 0.08),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TechCard extends StatelessWidget {
  const _TechCard({required this.item});

  final TechItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: item.color.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(item.icon, color: item.color),
                const SizedBox(width: 10),
                Expanded(child: Text(item.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
              ],
            ),
            const SizedBox(height: 10),
            Text('종류: ${item.kind}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('채택 이유: ${item.reason}', style: const TextStyle(height: 1.35)),
            const SizedBox(height: 8),
            Text('개념: ${item.concept}', style: const TextStyle(height: 1.35)),
            const SizedBox(height: 8),
            Text('사용 방법: ${item.usage}', style: const TextStyle(height: 1.35, color: Color(0xFF4D5C57))),
            const SizedBox(height: 8),
            Text('운영 포인트: ${item.operation}', style: const TextStyle(height: 1.35, color: Color(0xFF4D5C57))),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  const _LogoMark({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 40.0 : 52.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1F6F68),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.bolt, color: Colors.white),
    );
  }
}

class DemoProfile {
  const DemoProfile({
    required this.name,
    required this.level,
    required this.summary,
    required this.track,
    required this.priority,
    required this.aha,
    required this.skills,
    required this.weeks,
    required this.code,
    required this.reviewTitle,
    required this.reviewBody,
  });

  final String name;
  final String level;
  final String summary;
  final String track;
  final String priority;
  final String aha;
  final List<(String, double)> skills;
  final List<(int, String, String)> weeks;
  final String code;
  final String reviewTitle;
  final String reviewBody;
}

const demoProfiles = [
  DemoProfile(
    name: '지수',
    level: 'JUNIOR · Spring MVC 약점',
    summary: 'Java 기본기는 있으나 Controller, 예외 처리, 테스트 경계가 약합니다.',
    track: 'Spring Boot API 기본기 강화',
    priority: 'REST 오류 모델, DTO 분리, MockMvc 테스트',
    aha: 'null 반환을 상태코드와 문제 응답으로 바꾸는 순간',
    skills: [
      ('Java 문법', 0.72),
      ('Spring MVC', 0.38),
      ('JPA', 0.44),
      ('테스트', 0.31),
      ('분산 설계', 0.18),
    ],
    weeks: [
      (1, 'REST Controller와 상태코드', '요청/응답 DTO와 400/404/409를 명확히 분리합니다.'),
      (2, 'JPA 트랜잭션 기초', '조회와 변경 use case를 나누고 짧은 트랜잭션을 연습합니다.'),
      (3, '통합 테스트 루프', 'MockMvc와 Testcontainers 사고방식을 익힙니다.'),
    ],
    code: 'if (user == null) return null;\nreturn userRepository.save(user);',
    reviewTitle: 'null 대신 명시적 오류 응답이 필요합니다',
    reviewBody: 'API 경계에서는 null 반환보다 404 또는 409를 선택하고, 저장 로직은 입력 검증 이후에 실행하세요.',
  ),
  DemoProfile(
    name: '민준',
    level: 'MID · 이벤트/분산 흐름 약점',
    summary: 'CRUD는 익숙하지만 Outbox, Kafka, 멱등 소비자 설계 경험이 부족합니다.',
    track: 'MSA 이벤트 흐름 실무 전환',
    priority: 'Outbox, Kafka Consumer, 멱등 처리',
    aha: '이벤트는 한 번만 오지 않는다는 전제로 설계를 바꾸는 순간',
    skills: [
      ('Java 문법', 0.84),
      ('Spring MVC', 0.77),
      ('JPA', 0.69),
      ('테스트', 0.58),
      ('분산 설계', 0.36),
    ],
    weeks: [
      (1, 'Transactional Outbox', '상태 변경과 이벤트 기록을 같은 트랜잭션에 묶습니다.'),
      (2, 'Kafka Consumer 멱등성', '중복 메시지를 전제로 조건부 update와 unique key를 설계합니다.'),
      (3, '장애 복구 시나리오', '재시도, poison payload, DLQ 기준을 문서화합니다.'),
    ],
    code: 'consumer.onMessage(event);\nnotificationRepository.save(entity);',
    reviewTitle: '중복 소비에 대한 방어가 없습니다',
    reviewBody: '이벤트 소비자는 같은 메시지가 두 번 와도 결과가 같아야 합니다. dedup key나 조건부 update를 추가하세요.',
  ),
  DemoProfile(
    name: '서연',
    level: 'SENIOR · AI/검색 고도화 관심',
    summary: '서비스 설계는 강하지만 pgvector, LLM gateway, 검색 품질 튜닝을 강화하고 싶습니다.',
    track: 'AI 기반 학습 추천/검색 고도화',
    priority: '임베딩 검색, LLM 계약, 품질 평가',
    aha: 'LLM 출력은 프롬프트가 아니라 계약과 검증으로 운영한다는 순간',
    skills: [
      ('Java 문법', 0.91),
      ('Spring MVC', 0.86),
      ('JPA', 0.82),
      ('테스트', 0.74),
      ('분산 설계', 0.67),
    ],
    weeks: [
      (1, '임베딩과 HNSW', '콘텐츠 chunk와 768차원 벡터 검색 흐름을 설계합니다.'),
      (2, 'LLM 게이트웨이 계약', 'stream:false, 구조화 출력, 오류 매핑을 고정합니다.'),
      (3, '검색 품질 평가', 'BM25와 vector 후보를 비교하고 fallback 기준을 만듭니다.'),
    ],
    code: 'final response = await llm.generate(prompt);\nreturn jsonDecode(response);',
    reviewTitle: 'LLM 응답 계약 검증이 부족합니다',
    reviewBody: '구조화 출력은 schema 검증, 재시도, 사용자 노출 오류를 분리해야 운영에서 흔들리지 않습니다.',
  ),
];

List<(int, String, String)> _generatedWeeks(
  DemoProfile profile,
  String goal,
  int totalWeeks,
  Set<String> weakAreas,
) {
  final area = weakAreas.isEmpty ? profile.priority : weakAreas.first;
  final reviewWeek = totalWeeks <= 8 ? 6 : 8;
  return [
    (1, '$area 기준 진단 리포트 정리', '${profile.name}의 약점 점수를 기준으로 불필요한 복습을 줄이고 시작점을 고정합니다.'),
    (2, '$goal 핵심 API 과제', '요구사항, 테스트, 구현, 리뷰를 한 번의 짧은 루프로 묶습니다.'),
    (reviewWeek, '샌드박스 실습과 AI 리뷰', '실행 결과, 실패 로그, 코드리뷰를 합쳐 다음 보강 항목을 자동 추출합니다.'),
    (totalWeeks, '포트폴리오형 최종 점검', '경로 완료 기준을 체크리스트로 확인하고 다음 트랙 후보를 추천합니다.'),
  ];
}

class CodeSample {
  const CodeSample({required this.code, required this.severity, required this.review, required this.fix});

  final String code;
  final String severity;
  final String review;
  final String fix;
}

const codeSamples = {
  'null 응답': CodeSample(
    code: '@GetMapping("/users/{id}")\nUserResponse find(@PathVariable Long id) {\n  User user = repo.findById(id).orElse(null);\n  return mapper.toResponse(user);\n}',
    severity: '높음 · 404/500 경계 불명확',
    review: '존재하지 않는 사용자를 null로 흘려보내면 mapper에서 NPE가 발생하거나 모호한 200 응답이 될 수 있습니다.',
    fix: 'orElseThrow로 NotFoundException을 던지고 ControllerAdvice에서 404 Problem 응답으로 매핑하세요.',
  ),
  '중복 이벤트': CodeSample(
    code: '@KafkaListener(topics = "path.generated")\nvoid consume(PathEvent event) {\n  notificationRepository.save(toEntity(event));\n}',
    severity: '중간 · 멱등성 누락',
    review: 'Kafka consumer는 같은 메시지를 다시 받을 수 있으므로 단순 insert는 중복 알림을 만들 수 있습니다.',
    fix: 'eventId unique key를 저장하고 이미 처리된 이벤트는 skip하도록 조건부 저장을 추가하세요.',
  ),
  'LLM JSON': CodeSample(
    code: 'String body = ollama.chat(prompt);\nLearningPath path = objectMapper.readValue(body, LearningPath.class);\nreturn path;',
    severity: '높음 · 구조화 출력 검증 부족',
    review: 'LLM 응답은 JSON처럼 보여도 누락 필드, 문자열 내부 JSON, 설명 문장이 섞일 수 있습니다.',
    fix: 'format schema, 2단계 parse, 필수 필드 검증, 502 오류 매핑을 게이트웨이 계층에 고정하세요.',
  ),
};

class SearchResult {
  const SearchResult({
    required this.title,
    required this.reason,
    required this.keywordScore,
    required this.hybridScore,
  });

  final String title;
  final String reason;
  final double keywordScore;
  final double hybridScore;
}

const searchResults = {
  '트랜잭션': [
    SearchResult(title: 'JPA 트랜잭션 경계 실습', reason: '키워드가 직접 일치하고 서비스 계층 경계 설명이 포함됩니다.', keywordScore: 0.89, hybridScore: 0.91),
    SearchResult(title: 'Outbox 패턴과 원자성', reason: '임베딩 검색에서 “DB 변경과 이벤트 발행” 문맥이 가깝게 잡힙니다.', keywordScore: 0.62, hybridScore: 0.86),
    SearchResult(title: '읽기 전용 트랜잭션 튜닝', reason: '성능 관점의 보충 자료로 후순위 추천됩니다.', keywordScore: 0.71, hybridScore: 0.74),
  ],
  'Kafka': [
    SearchResult(title: '멱등 Consumer 설계', reason: '중복 수신, dedup key, 재시도 전략을 함께 다룹니다.', keywordScore: 0.86, hybridScore: 0.9),
    SearchResult(title: 'DLQ 운영 기준', reason: '장애 복구 시나리오와 poison payload 처리 기준이 연결됩니다.', keywordScore: 0.72, hybridScore: 0.84),
    SearchResult(title: 'Transactional Outbox', reason: '이벤트 발행 신뢰성을 확보하는 선행 개념입니다.', keywordScore: 0.54, hybridScore: 0.8),
  ],
  'LLM': [
    SearchResult(title: 'Ollama 구조화 출력 계약', reason: 'stream:false, format schema, 오류 매핑을 직접 설명합니다.', keywordScore: 0.91, hybridScore: 0.93),
    SearchResult(title: '임베딩 기반 콘텐츠 추천', reason: 'LLM 생성 전 후보 검색 품질을 높이는 흐름입니다.', keywordScore: 0.48, hybridScore: 0.81),
    SearchResult(title: 'AI 응답 검증 테스트', reason: 'malformed JSON과 timeout을 MockWebServer로 검증합니다.', keywordScore: 0.66, hybridScore: 0.79),
  ],
};

class TechItem {
  const TechItem({
    required this.name,
    required this.kind,
    required this.reason,
    required this.concept,
    required this.usage,
    required this.operation,
    required this.icon,
    required this.color,
  });

  final String name;
  final String kind;
  final String reason;
  final String concept;
  final String usage;
  final String operation;
  final IconData icon;
  final Color color;
}

const techItems = [
  TechItem(
    name: 'Flutter Web',
    kind: '프론트엔드',
    reason: '웹, 관리자, 모바일 경험을 같은 UI 철학으로 맞추기 쉽습니다.',
    concept: '위젯 트리와 선언형 상태로 화면을 구성합니다.',
    usage: '프로토타입 쇼케이스와 실제 web/mobile 앱의 UX 검증에 사용합니다.',
    operation: 'GitHub Pages 배포 시 `--base-href /prototype/`를 고정하고, 반응형 폭에서 텍스트 잘림을 테스트합니다.',
    icon: Icons.web_asset_outlined,
    color: Color(0xFF2D6CDF),
  ),
  TechItem(
    name: 'Spring Boot 4',
    kind: '백엔드',
    reason: 'Java 21 기반의 안정적인 API, 보안, 테스트 생태계를 활용합니다.',
    concept: 'Controller, Service, Repository 계층으로 HTTP와 도메인 로직을 분리합니다.',
    usage: 'gateway, platform, learning, ai, sandbox 서비스를 구현합니다.',
    operation: '서비스별 CI에서 context load, 계약 테스트, 오류 매핑 테스트를 분리해 회귀를 잡습니다.',
    icon: Icons.dns_outlined,
    color: Color(0xFF1F6F68),
  ),
  TechItem(
    name: 'Spring Cloud Gateway',
    kind: 'API Gateway',
    reason: '프론트엔드가 여러 서비스를 직접 알지 않도록 진입점을 하나로 모읍니다.',
    concept: '라우팅, 인증 필터, CORS, 요청 로깅을 앞단에서 처리합니다.',
    usage: 'Flutter 요청을 platform/learning/ai/sandbox 서비스로 라우팅하고 JWT 검증을 담당합니다.',
    operation: '서비스 장애가 전체 장애로 번지지 않도록 timeout, retry, correlation id를 관리합니다.',
    icon: Icons.account_tree_outlined,
    color: Color(0xFF3D7C47),
  ),
  TechItem(
    name: 'PostgreSQL + pgvector',
    kind: '데이터/검색',
    reason: '관계형 데이터와 임베딩 검색을 한 DB 흐름에서 다룰 수 있습니다.',
    concept: 'VECTOR 컬럼과 HNSW 인덱스로 유사 콘텐츠를 빠르게 찾습니다.',
    usage: '학습 콘텐츠 매칭과 경로 생성 후보 검색에 사용합니다.',
    operation: '임베딩 차원은 768로 검증하고, 스키마 변경은 shared Flyway migration으로 추적합니다.',
    icon: Icons.storage_outlined,
    color: Color(0xFFB7791F),
  ),
  TechItem(
    name: 'Redis',
    kind: '캐시/짧은 상태',
    reason: '반복 조회가 많은 세션성 데이터와 랭킹/진행률 표시를 빠르게 처리합니다.',
    concept: '만료 시간을 가진 key-value 저장소로 DB 부하와 응답 지연을 줄입니다.',
    usage: '온보딩 진행 상태, 추천 후보 캐시, rate limit 보조 저장소로 사용합니다.',
    operation: '캐시 정합성보다 원본 DB를 우선하고 TTL, key prefix, 장애 fallback을 명확히 둡니다.',
    icon: Icons.speed_outlined,
    color: Color(0xFF9D3A3A),
  ),
  TechItem(
    name: 'Kafka + Outbox',
    kind: '이벤트',
    reason: 'DB 변경과 부작용 이벤트를 안전하게 연결합니다.',
    concept: '트랜잭션 안에 outbox row를 남기고 relay가 Kafka로 발행합니다.',
    usage: '가입, 진단 완료, 학습경로 생성 이후 상태 전이에 사용합니다.',
    operation: 'consumer는 중복 수신을 전제로 event id dedup, DLQ, 재처리 절차를 가져야 합니다.',
    icon: Icons.sync_alt_outlined,
    color: Color(0xFF9D3A3A),
  ),
  TechItem(
    name: 'Ollama',
    kind: '로컬 AI',
    reason: '외부 API 키 없이 생성/임베딩 계약을 빠르게 검증합니다.',
    concept: '로컬 HTTP API로 `/api/chat`, `/api/embed`를 제공합니다.',
    usage: 'ai-svc가 학습경로 JSON 생성과 임베딩 요청을 중계합니다.',
    operation: '`qwen2.5:7b`, `nomic-embed-text`, `stream:false`, schema format, timeout 매핑을 테스트로 고정합니다.',
    icon: Icons.smart_toy_outlined,
    color: Color(0xFF6F5AA8),
  ),
  TechItem(
    name: 'MockWebServer',
    kind: '계약 테스트',
    reason: 'CI에서 실제 Ollama를 호출하지 않고도 HTTP body와 오류 매핑을 검증합니다.',
    concept: '테스트 안에서 가짜 HTTP 서버를 띄워 요청/응답 계약을 검사합니다.',
    usage: '`/api/chat`의 `stream:false`, `format` 포함 여부와 `/api/embed` 입력 배열, 768차원을 확인합니다.',
    operation: 'timeout, malformed JSON, upstream 5xx를 반드시 실패 케이스로 유지합니다.',
    icon: Icons.rule_folder_outlined,
    color: Color(0xFF2D6CDF),
  ),
  TechItem(
    name: 'Docker Compose',
    kind: '로컬 실행 환경',
    reason: 'PostgreSQL, Redis, Kafka, Ollama 같은 의존성을 로컬에서 같은 방식으로 띄웁니다.',
    concept: '여러 컨테이너와 네트워크, 볼륨을 하나의 compose 파일로 관리합니다.',
    usage: 'devpath-shared가 개발자 로컬 실행 기준을 제공하고 각 서비스는 env로 접속합니다.',
    operation: 'CI에서는 Ollama 실호출을 금지하고, 로컬 실행 지원과 테스트 계약을 분리합니다.',
    icon: Icons.inventory_2_outlined,
    color: Color(0xFF1F6F68),
  ),
  TechItem(
    name: 'GitHub Actions + Pages',
    kind: '배포',
    reason: '정적 Flutter Web 산출물을 별도 서버 없이 공개할 수 있습니다.',
    concept: 'main push 시 build/web artifact를 Pages에 배포합니다.',
    usage: '`/prototype/` base href로 공개 프로토타입을 배포합니다.',
    operation: 'Pages source는 GitHub Actions로 설정하고, artifact 업로드와 deploy-pages 권한을 확인합니다.',
    icon: Icons.rocket_launch_outlined,
    color: Color(0xFF3D7C47),
  ),
  TechItem(
    name: 'GitOps',
    kind: '운영 배포 전략',
    reason: '서비스가 늘어날수록 배포 상태를 코드로 추적해야 환경 차이를 줄일 수 있습니다.',
    concept: 'manifest 변경을 PR로 관리하고 클러스터가 선언된 상태를 따라가게 합니다.',
    usage: 'devpath-gitops가 gateway와 각 domain service의 배포 manifest를 보관합니다.',
    operation: 'secret, image tag, 환경별 values를 분리하고 rollback 기준을 문서화합니다.',
    icon: Icons.hub_outlined,
    color: Color(0xFFB7791F),
  ),
];
