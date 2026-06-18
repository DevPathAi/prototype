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
  DemoProfile _selected = demoProfiles.first;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          eyebrow: '데모',
          title: '진단 선택만으로 학습경로와 코드리뷰 미리보기가 바뀝니다',
          body: '실제 백엔드 API 연동 전, 사용자에게 보일 핵심 경험을 정적 데이터와 로컬 상태로 검증합니다.',
        ),
        const SizedBox(height: 18),
        _ResponsiveGrid(
          minItemWidth: 260,
          children: [
            for (final profile in demoProfiles)
              _SelectableDemoCard(
                profile: profile,
                selected: profile == _selected,
                onTap: () => setState(() => _selected = profile),
              ),
          ],
        ),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minItemWidth: 360,
          children: [
            _LearningPathPreview(profile: _selected),
            _CodeReviewPreview(profile: _selected),
          ],
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
          title: '독립 배포 서비스와 중앙 스키마를 결합한 현실적인 MSA',
          body:
              '서비스는 도메인별로 나누되, 1인 개발 속도를 위해 PostgreSQL/Flyway 스키마는 shared에서 중앙 관리합니다.',
        ),
        const SizedBox(height: 20),
        const _ArchitectureMap(),
        const SizedBox(height: 24),
        _ResponsiveGrid(
          minItemWidth: 300,
          children: const [
            _InfoCard(
              icon: Icons.login_outlined,
              title: '게이트웨이 + 플랫폼',
              body: 'OAuth, JWT, 사용자 프로필, 온보딩 상태 전이를 담당합니다.',
            ),
            _InfoCard(
              icon: Icons.school_outlined,
              title: '학습 서비스',
              body: '진단, 학습경로, 콘텐츠 매칭, 진행 상태를 소유합니다.',
            ),
            _InfoCard(
              icon: Icons.smart_toy_outlined,
              title: 'AI 서비스',
              body: 'Ollama/LLM 호출을 한 곳으로 모아 생성과 임베딩 계약을 안정화합니다.',
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
          title: '기술 선택 이유와 DevPath에서의 사용 방법',
          body: '각 기술은 데모를 위한 장식이 아니라 학습경로 생성, 실습, 리뷰, 배포 흐름에 직접 연결됩니다.',
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

class _LearningPathPreview extends StatelessWidget {
  const _LearningPathPreview({required this.profile});

  final DemoProfile profile;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: '${profile.name} 추천 학습경로',
      icon: Icons.route_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final week in profile.weeks)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: const Color(0xFF1F6F68),
                    foregroundColor: Colors.white,
                    child: Text('${week.$1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(week.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(week.$3, style: const TextStyle(color: Color(0xFF4D5C57), height: 1.35)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CodeReviewPreview extends StatelessWidget {
  const _CodeReviewPreview({required this.profile});

  final DemoProfile profile;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'AI 코드리뷰 예시',
      icon: Icons.rate_review_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2523),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(profile.code, style: const TextStyle(color: Color(0xFFE7F4EE), fontFamily: 'monospace')),
          ),
          const SizedBox(height: 14),
          Text(profile.reviewTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(profile.reviewBody, style: const TextStyle(height: 1.45, color: Color(0xFF4D5C57))),
        ],
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
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Icon(Icons.keyboard_arrow_down, color: Color(0xFF697772)),
              ),
          ],
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
    required this.weeks,
    required this.code,
    required this.reviewTitle,
    required this.reviewBody,
  });

  final String name;
  final String level;
  final String summary;
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

class TechItem {
  const TechItem({
    required this.name,
    required this.kind,
    required this.reason,
    required this.concept,
    required this.usage,
    required this.icon,
    required this.color,
  });

  final String name;
  final String kind;
  final String reason;
  final String concept;
  final String usage;
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
    icon: Icons.web_asset_outlined,
    color: Color(0xFF2D6CDF),
  ),
  TechItem(
    name: 'Spring Boot 4',
    kind: '백엔드',
    reason: 'Java 21 기반의 안정적인 API, 보안, 테스트 생태계를 활용합니다.',
    concept: 'Controller, Service, Repository 계층으로 HTTP와 도메인 로직을 분리합니다.',
    usage: 'gateway, platform, learning, ai, sandbox 서비스를 구현합니다.',
    icon: Icons.dns_outlined,
    color: Color(0xFF1F6F68),
  ),
  TechItem(
    name: 'PostgreSQL + pgvector',
    kind: '데이터/검색',
    reason: '관계형 데이터와 임베딩 검색을 한 DB 흐름에서 다룰 수 있습니다.',
    concept: 'VECTOR 컬럼과 HNSW 인덱스로 유사 콘텐츠를 빠르게 찾습니다.',
    usage: '학습 콘텐츠 매칭과 경로 생성 후보 검색에 사용합니다.',
    icon: Icons.storage_outlined,
    color: Color(0xFFB7791F),
  ),
  TechItem(
    name: 'Kafka + Outbox',
    kind: '이벤트',
    reason: 'DB 변경과 부작용 이벤트를 안전하게 연결합니다.',
    concept: '트랜잭션 안에 outbox row를 남기고 relay가 Kafka로 발행합니다.',
    usage: '가입, 진단 완료, 학습경로 생성 이후 상태 전이에 사용합니다.',
    icon: Icons.sync_alt_outlined,
    color: Color(0xFF9D3A3A),
  ),
  TechItem(
    name: 'Ollama',
    kind: '로컬 AI',
    reason: '외부 API 키 없이 생성/임베딩 계약을 빠르게 검증합니다.',
    concept: '로컬 HTTP API로 `/api/chat`, `/api/embed`를 제공합니다.',
    usage: 'ai-svc가 학습경로 JSON 생성과 임베딩 요청을 중계합니다.',
    icon: Icons.smart_toy_outlined,
    color: Color(0xFF6F5AA8),
  ),
  TechItem(
    name: 'GitHub Actions + Pages',
    kind: '배포',
    reason: '정적 Flutter Web 산출물을 별도 서버 없이 공개할 수 있습니다.',
    concept: 'main push 시 build/web artifact를 Pages에 배포합니다.',
    usage: '`/prototype/` base href로 공개 프로토타입을 배포합니다.',
    icon: Icons.rocket_launch_outlined,
    color: Color(0xFF3D7C47),
  ),
];
