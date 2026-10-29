// 화면 B: 하루 전체 일정 — A 월간 달력에서 날짜 칸(또는 +N개 배지)을 누르면 들어온다
//
// ┌──────── 디자인 가이드 대응표: B 하루 전체 일정 ──────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                          │ 비즈니스 명칭(한글)  │ 원칙(P번호)    │
// │ B-0  │ PageRouteBuilder + SlideTransition      │ 하루 일정 패널       │ P03 통제·자유  │
// │      │  + 손잡이 + 둥근 위 모서리 + 어두운 뒤쪽 │                      │                │
// │ B-1  │ AppBar + 오른쪽 IconButton(✕)           │ 하루 제목줄          │ P03 통제·자유  │
// │ B-2  │ TabBar + TabBarView                     │ 일정·하루 메모 탭    │ P06 재인       │
// │ B-3  │ Text(titleSmall)                        │ 하루 일정 개수 요약  │ P01 가시성     │
// │ B-4  │ ListView + ScheduleTile                 │ 하루 일정 목록       │ P02 실세계     │
// │ B-5  │ ListView + ListTile                     │ 하루 메모 목록       │ P06 재인       │
// │ B-6  │ FloatingActionButton → SnackBar         │ 일정 추가(예시)      │ STATE 표시만   │
// │ B-7  │ LoadingView · ErrorView · EmptyView     │ 불러오기 상태        │ P01 · P09      │
// │ B-8  │ CircleAvatar(이니셜)                    │ 일정 등록자 배지     │ P06 재인       │
// │ B-9  │ Material + InkWell(펼치기) + Text       │ AI 하루 브리핑(예시) │ P01 · P10      │
// └────────────────────────────────────────────────────────────────────────────────────┘
// 전환: A → B 쌓기(Navigator.push — 아래에서 올라오는 패널 경로) · B 안에서 옆으로(tab)
//       · B → C 덮기(modal: 일정 한 줄을 누름). B 닫기: ✕ · 뒤로 가기 · 손잡이 아래로 끌기 · 어두운 바깥 누르기.
// 적응형: 넓은 창(≥600dp)에서는 목록을 가운데 최대 720dp로 — 한 줄이 너무 길어지지 않게.
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'a_list_screen.dart' show parseScheduleColor, wideBreakpoint;
import 'c_result_sheet.dart';

const _maxListWidth = 720.0;
const _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

/// '2026-10-28' → '10월 28일 (수)'
String dayTitle(String date) {
  final d = DateTime.parse(date);
  return '${d.month}월 ${d.day}일 (${_weekdayNames[d.weekday - 1]})';
}

class DayScheduleScreen extends StatelessWidget {
  const DayScheduleScreen({
    super.key,
    required this.date,
    this.loadSchedules = fetchDaySchedules,
    this.loadNotes = fetchDayNotes,
  });

  /// 'YYYY-MM-DD'
  final String date;
  final DaySchedulesLoader loadSchedules;
  final DayNotesLoader loadNotes;

  @override
  Widget build(BuildContext context) {
    // 옆으로(tab): DefaultTabController가 탭 선택을 화면 안에서만 처리한다 (허용)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          // B-1 P03 — 화면 C와 같은 배치: 왼쪽 날짜 제목, 오른쪽 끝 ✕
          automaticallyImplyLeading: false,
          centerTitle: false,
          title: Text(dayTitle(date)),
          actions: [
            Padding(
              // 오른쪽 끝에서 16 띄움 → 패널 가장자리 ~ ✕ 중심 40 (터치 영역 48×48 그대로)
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                key: const ValueKey('day-panel-close'),
                tooltip: '하루 일정 닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ),
            ), // B-1 P03 — B 패널만 닫힘
          ],
          bottom: const TabBar(
            // B-2 P06
            tabs: [
              Tab(text: '일정'),
              Tab(text: '하루 메모'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ScheduleTab(date: date, load: loadSchedules),
            _NotesTab(date: date, load: loadNotes),
          ],
        ),
        // STATE: 일정 추가 → B-4 하루 일정 목록, A-4 · A-5 — 실제로 저장하지 않는다(감점). SnackBar로만 응답.
        floatingActionButton: FloatingActionButton.extended(
          // B-6 — 이름에 '(예시)' + 옅은 보조 색: 실제 저장 버튼으로 오해하지 않게
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          elevation: 1,
          onPressed: () => ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('예시 화면입니다 — 실제로 저장하지 않습니다.')),
            ),
          icon: const Icon(Icons.add),
          label: const Text('일정 추가 (예시)'),
        ),
      ),
    );
  }

  /// B-0 쌓기(Navigator.push)용 경로 — 화면 A 위로 아래에서 올라오는 패널.
  /// 뒤쪽 A는 반투명하게 어둡게 남고(opaque: false + barrierColor), 바깥을 누르면 닫힌다.
  static Route<void> panelRoute({
    required String date,
    DaySchedulesLoader loadSchedules = fetchDaySchedules,
    DayNotesLoader loadNotes = fetchDayNotes,
  }) {
    return PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black54,
      barrierDismissible: true,
      barrierLabel: '하루 일정 패널 닫기',
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (context, animation, secondaryAnimation) => DaySchedulePanel(
        child: DayScheduleScreen(
          date: date,
          loadSchedules: loadSchedules,
          loadNotes: loadNotes,
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                ),
            child: child,
          ),
    );
  }
}

/// 패널 위쪽 여백 비율 — 뒤의 화면 A가 조금 보이게
const _panelHeightFactor = 0.92;

/// 넓은 창에서 패널이 너무 퍼지지 않게
const _maxPanelWidth = 840.0;

/// 손잡이를 이만큼 아래로 끌거나 빠르게 내리면 닫힌다
const _dismissDragDistance = 120.0;
const _dismissDragVelocity = 700.0;

/// B-0 하루 일정 패널 — 둥근 위 모서리 + 드래그 손잡이 + 아래로 끌어 닫기.
/// 안의 화면(B 하루 전체 일정)은 그대로 쓴다.
class DaySchedulePanel extends StatefulWidget {
  const DaySchedulePanel({super.key, required this.child});

  final Widget child;

  @override
  State<DaySchedulePanel> createState() => _DaySchedulePanelState();
}

class _DaySchedulePanelState extends State<DaySchedulePanel> {
  // STATE: 패널 끈 거리 → B-0 패널 위치 (기준을 넘으면 닫힘, 화면 안 setState만, 저장 안 함)
  double _dragOffset = 0;

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() {
      _dragOffset = (_dragOffset + d.delta.dy).clamp(0.0, double.infinity);
    });
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dragOffset > _dismissDragDistance ||
        d.velocity.pixelsPerSecond.dy > _dismissDragVelocity) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxPanelWidth),
        child: FractionallySizedBox(
          heightFactor: _panelHeightFactor,
          child: Transform.translate(
            offset: Offset(0, _dragOffset),
            child: Material(
              color: scheme.surface,
              clipBehavior: Clip.antiAlias,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Column(
                children: [
                  Semantics(
                    label: '아래로 끌어 하루 일정 패널 닫기',
                    child: GestureDetector(
                      key: const ValueKey('day-panel-handle'),
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: _onDragUpdate,
                      onVerticalDragEnd: _onDragEnd,
                      child: SizedBox(
                        height: 20,
                        width: double.infinity,
                        child: Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.4,
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ), // B-0 P03 손잡이
                  Expanded(
                    // 패널은 화면 맨 위가 아니므로 상태 표시줄 여백을 뺀다
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      // 패널 전용 SnackBar 자리 — 뒤에 보이는 화면 A에 같은 알림이 겹쳐 뜨지 않게
                      child: ScaffoldMessenger(child: widget.child),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 넓은 창에서 목록 폭 제한 (좁은 창은 그대로)
class _ReadableWidth extends StatelessWidget {
  const _ReadableWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < wideBreakpoint) return child;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxListWidth),
            child: child,
          ),
        );
      },
    );
  }
}

/// '일정' 탭 — GET /schedules?date=…
class _ScheduleTab extends StatefulWidget {
  const _ScheduleTab({required this.date, required this.load});

  final String date;
  final DaySchedulesLoader load;

  @override
  State<_ScheduleTab> createState() => _ScheduleTabState();
}

class _ScheduleTabState extends State<_ScheduleTab> {
  late Future<List<Schedule>> _future = widget.load(widget.date);

  void _retry() {
    setState(() {
      _future = widget.load(widget.date);
    });
  }

  // 덮기(modal): 일정 한 줄 → C 일정 상세·AI 요약(예시)
  void _open(Schedule schedule) => ScheduleDetailSheet.show(context, schedule);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Schedule>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(label: '일정을 불러오는 중…'); // B-7 P01
        }
        if (snap.hasError) {
          return ErrorView(
            title: '일정을 불러오지 못했습니다.',
            message: '${snap.error}',
            onRetry: _retry,
          ); // B-7 P09
        }
        final schedules = snap.data ?? const <Schedule>[];
        if (schedules.isEmpty) {
          return const EmptyView(message: '이 날은 일정이 없습니다.'); // B-7 P01
        }
        return _ReadableWidth(
          child: ListView.separated(
            // B-4 P02 — 서버가 시작 시간순(_sort=start)으로 준 그대로, 빠짐없이
            padding: const EdgeInsets.only(
              top: 4,
              bottom: 96,
            ), // 아래 여백: 일정 추가 버튼에 가리지 않게
            itemCount: schedules.length + 1,
            separatorBuilder: (_, i) => i == 0
                ? const SizedBox.shrink()
                : const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, i) {
              if (i == 0) {
                final briefing = demoBriefings[widget.date];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (briefing != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: DayBriefingCard(briefing: briefing),
                      ), // B-9 P01 · P10
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        '일정 ${schedules.length}개 · 시간순',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ), // B-3 P01
                  ],
                );
              }
              final s = schedules[i - 1];
              return ScheduleTile(s, onTap: () => _open(s));
            },
          ),
        );
      },
    );
  }
}

/// B-4 일정 한 줄: 시간 · 캘린더 색 띠 · 제목 · 캘린더 이름 · 장소
class ScheduleTile extends StatelessWidget {
  const ScheduleTile(this.schedule, {super.key, this.onTap});

  final Schedule schedule;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = theme.colorScheme.onSurfaceVariant;
    final color =
        parseScheduleColor(schedule.color) ?? theme.colorScheme.primary;
    // 시간 칸 너비는 글자 크기에 맞춰 늘린다 → 큰 글씨에서도 '10:15'가 줄바꿈되지 않음
    final timeWidth = MediaQuery.textScalerOf(context).scale(52);

    return MergeSemantics(
      child: Semantics(
        button: true,
        label: '${schedule.start}부터 ${schedule.end}까지',
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: timeWidth,
                    child: ExcludeSemantics(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(schedule.start, style: text.titleSmall),
                          Text(
                            schedule.end,
                            style: text.bodySmall?.copyWith(color: muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ), // B-4 캘린더 구분 색
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(schedule.title, style: text.titleMedium),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 12,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.circle, size: 10, color: color),
                                const SizedBox(width: 4),
                                Text(
                                  schedule.calendar,
                                  style: text.bodyMedium?.copyWith(
                                    color: muted,
                                  ),
                                ),
                              ],
                            ),
                            if (schedule.location.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    size: 16,
                                    color: muted,
                                  ),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      schedule.location,
                                      style: text.bodyMedium?.copyWith(
                                        color: muted,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (schedule.authorInitial.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Center(
                      child: AuthorBadge(
                        initial: schedule.authorInitial,
                        name: schedule.authorName,
                      ),
                    ), // B-8 P06
                  ],
                  const SizedBox(width: 4),
                  Center(child: Icon(Icons.chevron_right, color: muted)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// B-9 AI 하루 브리핑(예시) 한 날치 — 전체 개수 · 오전(~12시) · 오후(12~18시) · 저녁(18시~) 흐름
typedef DayBriefing = ({
  String headline,
  String morning,
  String afternoon,
  String evening,
});

/// 미리 작성된 시연용 브리핑 (하드코딩 상수). 실제 AI 호출 · 실시간 생성 · 계산 없음.
/// 문장은 mock_server/db.json의 같은 날짜 일정과 맞춰 손으로 썼다 — 일정을 바꾸면 여기도 같이 고친다.
const demoBriefings = <String, DayBriefing>{
  '2026-10-02': (
    headline: '일정 1개 · 저녁에만 일정이 있는 여유로운 하루',
    morning: '일정 없음',
    afternoon: '일정 없음',
    evening: '18:00 동아리 정기 모임',
  ),
  '2026-10-07': (
    headline: '일정 2개 · 오전 수업 뒤 오후가 비고 저녁에 모임',
    morning: '10:00 영어 회화',
    afternoon: '일정 없음',
    evening: '19:00 독서 모임',
  ),
  '2026-10-13': (
    headline: '일정 3개 · 오전 · 오후 · 저녁에 하나씩',
    morning: '09:00 전공 수업',
    afternoon: '14:00 도서관 과제',
    evening: '19:00 가족 저녁 식사',
  ),
  '2026-10-20': (
    headline: '일정 7개 · 오후에 3개가 몰린 이달 가장 바쁜 날',
    morning: '09:00 전공 수업 → 10:30 조교 면담',
    afternoon: '12:00 점심 약속 → 13:30 스터디 모임 → 15:30 팀 프로젝트 회의',
    evening: '18:00 아르바이트 → 21:00 복습',
  ),
  '2026-10-28': (
    headline: '일정 5개 · 오전 2개, 오후 2개, 저녁 1개로 이어지는 하루',
    morning: '09:00 전공 수업 → 11:00 스터디 모임',
    afternoon: '13:00 점심 약속 → 15:00 팀 프로젝트 회의(회의실 B)',
    evening: '19:00 운동',
  ),
  '2026-10-29': (
    headline: '일정 1개 · 오후 중간 발표에 집중하는 하루',
    morning: '일정 없음',
    afternoon: '13:00 중간 발표',
    evening: '일정 없음',
  ),
};

/// B-9 AI 하루 브리핑(예시) — 접혀 있다가 누르면 하루 흐름을 펼친다.
class DayBriefingCard extends StatefulWidget {
  const DayBriefingCard({super.key, required this.briefing});

  final DayBriefing briefing;

  @override
  State<DayBriefingCard> createState() => _DayBriefingCardState();
}

class _DayBriefingCardState extends State<DayBriefingCard> {
  // STATE: 브리핑 펼침 여부 → B-9 (화면 안 setState만, 저장 안 함)
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;
    final muted = scheme.onSurfaceVariant;
    final b = widget.briefing;
    // '오전' 칸 너비는 글자 크기에 맞춰 늘린다 → 큰 글씨에서도 줄바꿈 없음
    final labelWidth = MediaQuery.textScalerOf(context).scale(36);

    Widget segment(String label, String value) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: text.labelLarge?.copyWith(color: scheme.primary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: text.bodyMedium?.copyWith(
                color: value == '일정 없음' ? muted : null,
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() {
              _open = !_open;
            }),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_outlined, size: 20, color: muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('AI 하루 브리핑 (예시)', style: text.titleSmall),
                  ),
                  Icon(_open ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.headline, style: text.bodyLarge),
                  segment('오전', b.morning),
                  segment('오후', b.afternoon),
                  segment('저녁', b.evening),
                  const SizedBox(height: 10),
                  Text(
                    '※ 실제 AI 호출이 아닌, 미리 작성된 시연용 브리핑입니다.',
                    style: text.bodySmall?.copyWith(color: muted),
                  ), // B-9 P10
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// B-8 일정 등록자 배지 — 작은 원 안에 가상 이니셜 (실제 사용자 정보 아님)
class AuthorBadge extends StatelessWidget {
  const AuthorBadge({super.key, required this.initial, required this.name});

  final String initial;
  final String name;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // 원 크기는 글자 크기에 맞춰 커진다 → 큰 글씨에서도 이니셜이 원 밖으로 넘치지 않음
    final size = MediaQuery.textScalerOf(context).scale(26);
    return Semantics(
      label: '등록한 사람 $name',
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: scheme.secondaryContainer,
          shape: BoxShape.circle,
        ),
        child: Text(
          initial,
          maxLines: 1,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: scheme.onSecondaryContainer,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// '하루 메모' 탭 — GET /notes?date=…
class _NotesTab extends StatefulWidget {
  const _NotesTab({required this.date, required this.load});

  final String date;
  final DayNotesLoader load;

  @override
  State<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends State<_NotesTab> {
  late Future<List<DayNote>> _future = widget.load(widget.date);

  void _retry() {
    setState(() {
      _future = widget.load(widget.date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DayNote>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const LoadingView(label: '메모를 불러오는 중…'); // B-7 P01
        }
        if (snap.hasError) {
          return ErrorView(
            title: '메모를 불러오지 못했습니다.',
            message: '${snap.error}',
            onRetry: _retry,
          ); // B-7 P09
        }
        final notes = snap.data ?? const <DayNote>[];
        if (notes.isEmpty) {
          return const EmptyView(message: '이 날 남긴 메모가 없습니다.'); // B-7 P01
        }
        return _ReadableWidth(
          child: ListView.separated(
            // B-5 P06
            padding: const EdgeInsets.only(top: 8, bottom: 96),
            itemCount: notes.length + 1,
            separatorBuilder: (_, i) => i == 0
                ? const SizedBox.shrink()
                : const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, i) {
              if (i == 0) {
                // 하루 메모(날짜 전체) ≠ 일정 메모(일정 하나, 화면 C)
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                  child: Text(
                    '이 날짜 전체에 남긴 메모입니다. 일정별 메모는 일정을 누르면 보입니다.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }
              final note = notes[i - 1];
              return ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.sticky_note_2_outlined),
                ),
                title: Text(note.text),
                subtitle: Text('${note.author} · ${note.time}'),
              );
            },
          ),
        );
      },
    );
  }
}
