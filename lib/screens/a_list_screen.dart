// 화면 A: 월간 달력 (GET /schedules?date_like=2026-10) — DayPeek 첫 화면
//
// ┌──────── 디자인 가이드 대응표: A 월간 달력 ──────────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                          │ 비즈니스 명칭(한글)  │ 원칙(P번호)   │
// │ A-1  │ AppBar + IconButton(이전/다음 달)       │ 달력 제목줄          │ P04 일관성    │
// │ A-2  │ Row × 7 Text (WeekdayHeader)            │ 요일 머리줄          │ P04 일관성    │
// │ A-3  │ Column × Row + DayCell · OutsideDayCell │ 날짜 칸 격자         │ P08 미니멀    │
// │ A-4  │ SchedulePill (Container + Text)         │ 일정 제목 미리보기   │ P06 재인      │
// │ A-5  │ HiddenCountBadge (FittedBox + Text)     │ 숨겨진 일정 수 표시  │ P01 가시성    │
// │ A-6  │ LoadingView                             │ 불러오는 중 표시     │ P01 가시성    │
// │ A-7  │ ErrorView + FilledButton                │ 오류 안내·다시 시도  │ P09 오류 복구 │
// │ A-8  │ EmptyView                               │ 빈 달력 안내         │ P01 가시성    │
// │ A-9  │ PopupMenuButton (작게·보통·크게)        │ 글자 크기 미리보기   │ P07 유연성    │
// │ A-10 │ DateMark (원 · 칸 배경)                 │ 오늘·선택한 날짜 표시│ P01 가시성    │
// └────────────────────────────────────────────────────────────────────────────────────┘
// 전환: A → B 는 쌓기(Navigator.push) — 날짜 칸 또는 A-5 +N개 배지를 누르면 같은 날짜의 B가 아래에서 올라온다.
// 적응형: LayoutBuilder 600dp 분기 1곳 — 칸 높이 = 남은 높이 ÷ 줄 수
//   좁음: 항상 6주(앞뒤 달 날짜는 흐리게) — 휴대폰 달력처럼 화면을 채우고 달마다 격자 위치가 같다.
//   넓음: 그달의 주만(10월 = 5주) · 최대 너비 1000dp — 칸이 커져 더 많은 일정 제목이 보인다.
// ⚠ 보이는 일정 수는 칸 높이 · 글자 크기로만 정하는 "표시 계산"이다. 정렬·우선순위 같은 비즈니스 로직 없음.
import 'package:flutter/material.dart';

import '../api.dart';
import '../models.dart';
import '../widgets.dart';
import 'b_detail_screen.dart';

/// 이 너비 이상이면 넓은 화면 배치 (Material 3 window size class: medium ≥ 600dp)
const wideBreakpoint = 600.0;

/// 좁은 화면은 항상 6주 격자
const _narrowWeeks = 6;

/// 창이 아주 낮을 때 칸이 이보다 작아지지 않게 (그때는 달력이 스크롤된다)
const _minNarrowCellHeight = 88.0;
const _minWideCellHeight = 120.0;

/// 넓은 화면에서 달력이 너무 퍼지지 않게
const _maxCalendarWidth = 1000.0;

/// 프로토타입 기준 '오늘' = 발표일. 실제 시계를 쓰지 않아 데모 화면이 날짜에 따라 바뀌지 않는다.
const demoToday = '2026-10-29';

const _weekdays = ['일', '월', '화', '수', '목', '금', '토'];

// 날짜 칸 안 치수 (표시 계산과 실제 그리기에 같은 값을 쓴다)
const _cellPadding = 2.0;
const _cellBorder = 1.0; // 칸 위쪽 주간 구분선 — Container 안쪽 높이를 그만큼 줄인다

const _dateFontSize = 13.0;
const _dateMarkMin = 22.0; // 날짜 숫자 원(오늘·선택) 최소 지름
const _headerGap = 3.0;
const _pillFontSize = 12.5;
const _pillPadV = 3.0;
const _pillGap = 3.0;

/// 글자 크기 미리보기 (A-9) — 현행 앱 설정과 같은 3단계. 저장하지 않는다.
enum CalendarTextSize {
  small('작게', 0.85),
  normal('보통', 1.0),
  large('크게', 1.15);

  const CalendarTextSize(this.label, this.factor);
  final String label;
  final double factor;
}

/// 칸에 들어가는 일정 수 (표시 계산만).
/// 모두 들어가면 전부, 아니면 배지 줄 높이를 먼저 빼고 남은 높이에 들어가는 만큼.
int visibleScheduleCount({
  required int total,
  required double space,
  required double pillHeight,
  required double badgeHeight,
}) {
  if (total * pillHeight <= space) return total;
  final n = ((space - badgeHeight) / pillHeight).floor();
  return n.clamp(0, total);
}

class MonthCalendarScreen extends StatefulWidget {
  const MonthCalendarScreen({
    super.key,
    this.load = fetchMonthSchedules,
    this.loadDay = fetchDaySchedules,
    this.loadNotes = fetchDayNotes,
  });

  /// 데이터를 가져오는 함수 — 앱은 기본값(GET), 테스트는 가짜 함수를 넣는다.
  final MonthSchedulesLoader load;

  /// 화면 B에 넘겨줄 함수
  final DaySchedulesLoader loadDay;
  final DayNotesLoader loadNotes;

  @override
  State<MonthCalendarScreen> createState() => _MonthCalendarScreenState();
}

class _MonthCalendarScreenState extends State<MonthCalendarScreen> {
  late Future<List<Schedule>> _future = widget.load();

  // STATE: 글자 크기 설정 → A-4 보이는 일정 수, A-5 +N개 배지 (화면 안 setState만, 저장 안 함)
  CalendarTextSize _textSize = CalendarTextSize.normal;

  // STATE: 마지막으로 누른 날짜 → A-10 선택한 날짜 표시 (화면 안 setState만, 저장 안 함)
  String? _selectedDate;

  // 다시 시도 = Future만 새로 만드는 setState (화면 안 표시 변화 — 허용)
  void _retry() {
    setState(() {
      _future = widget.load();
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // STATE: 보고 있는 월 → A-1 제목, A-3 날짜 칸 격자 — 프로토타입은 10월만 (표시만)
  void _otherMonth() => _showSnack('예시 화면입니다 — 2026년 10월만 보여 줍니다.');

  // 쌓기(push): 날짜 칸 · +N개 배지 → B 하루 전체 일정
  void _openDay(String date) {
    setState(() {
      _selectedDate = date;
    });
    Navigator.of(context).push(
      // B-0 아래에서 올라오는 하루 일정 패널 (뒤의 A는 어둡게 남음)
      DayScheduleScreen.panelRoute(
        date: date,
        loadSchedules: widget.loadDay,
        loadNotes: widget.loadNotes,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final month = DateTime.parse('$shownMonth-01');
    return Scaffold(
      appBar: AppBar(
        // A-1 P04 — 달력 앱에 익숙한 배치: 왼쪽 굵은 월 표시, 오른쪽 이동·설정
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          '${month.year}년 ${month.month}월',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: '이전 달',
            onPressed: _otherMonth,
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: '다음 달',
            onPressed: _otherMonth,
            icon: const Icon(Icons.chevron_right),
          ),
          PopupMenuButton<CalendarTextSize>(
            // A-9 P07
            tooltip: '글자 크기',
            icon: const Icon(Icons.format_size),
            onSelected: (size) => setState(() {
              _textSize = size;
            }),
            itemBuilder: (context) => [
              for (final size in CalendarTextSize.values)
                CheckedPopupMenuItem(
                  value: size,
                  checked: size == _textSize,
                  child: Text('글자 ${size.label}'),
                ),
            ],
          ),
        ],
      ),
      body: FutureBuilder<List<Schedule>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LoadingView(label: '달력을 불러오는 중…'); // A-6 P01
          }
          if (snap.hasError) {
            return ErrorView(
              title: '달력을 불러오지 못했습니다.',
              message: '${snap.error}',
              onRetry: _retry,
            ); // A-7 P09
          }
          final schedules = snap.data ?? const <Schedule>[];
          if (schedules.isEmpty) {
            return const EmptyView(message: '이번 달 일정이 없습니다.'); // A-8 P01
          }
          // 날짜별로 나눠 담기만 한다 (서버가 준 순서 그대로)
          final byDate = <String, List<Schedule>>{};
          for (final s in schedules) {
            (byDate[s.date] ??= []).add(s);
          }
          final base = MediaQuery.textScalerOf(context).scale(1);
          return MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(base * _textSize.factor)),
            child: _MonthGrid(
              month: month,
              byDate: byDate,
              selectedDate: _selectedDate,
              onTapDay: _openDay,
            ),
          );
        },
      ),
    );
  }
}

/// A-3 날짜 칸 격자 (+ A-2 요일 머리줄)
class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.byDate,
    required this.selectedDate,
    required this.onTapDay,
  });

  final DateTime month;
  final Map<String, List<Schedule>> byDate;
  final String? selectedDate;
  final void Function(String date) onTapDay;

  @override
  Widget build(BuildContext context) {
    final leading = month.weekday % 7; // 일요일 시작
    final days = DateTime(month.year, month.month + 1, 0).day;
    final monthWeeks = ((leading + days) / 7).ceil();
    return LayoutBuilder(
      // 적응형: 기기 종류가 아니라 "이 영역의 너비"로 나눈다
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= wideBreakpoint;
        final weeks = wide ? monthWeeks : _narrowWeeks;
        final minCell = wide ? _minWideCellHeight : _minNarrowCellHeight;
        return Center(
          child: SizedBox(
            width: constraints.maxWidth.clamp(0.0, _maxCalendarWidth),
            child: Column(
              children: [
                const WeekdayHeader(), // A-2
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, area) {
                      // 칸 높이 = 남은 높이 ÷ 줄 수 → 아래쪽 빈 공간 없음
                      final cellHeight = (area.maxHeight / weeks).clamp(
                        minCell,
                        double.infinity,
                      );
                      // A-3 P08 — 날짜 칸 격자: 날짜 숫자 · 일정 막대 · 숨김 배지 외 장식 없음
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          for (var w = 0; w < weeks; w++)
                            Row(
                              children: [
                                for (var d = 0; d < 7; d++)
                                  Expanded(
                                    child: SizedBox(
                                      height: cellHeight,
                                      child: _cellAt(w * 7 + d - leading, d),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// offset 0 = 그달 1일. 음수·말일 이후는 앞뒤 달 날짜(흐리게, 누를 수 없음)
  Widget _cellAt(int offset, int weekday) {
    final d = DateTime(month.year, month.month, offset + 1);
    if (d.month != month.month) {
      return OutsideDayCell(day: d.day, weekday: weekday);
    }
    final date = '$shownMonth-${d.day.toString().padLeft(2, '0')}';
    final schedules = byDate[date] ?? const <Schedule>[];
    return DayCell(
      key: ValueKey('day-$date'),
      date: date,
      day: d.day,
      weekday: weekday,
      schedules: schedules,
      isToday: date == demoToday,
      isSelected: date == selectedDate,
      onTap: () => onTapDay(date),
    );
  }
}

/// A-2 요일 머리줄 — 일요일 빨강 · 토요일 파랑, 아래 구분선
class WeekdayHeader extends StatelessWidget {
  const WeekdayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Text(
                _weekdays[i],
                textAlign: TextAlign.center,
                style: style?.copyWith(
                  color: _weekdayColor(i) ?? theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ), // A-2 P04
        ],
      ),
    );
  }
}

Color? _weekdayColor(int weekday) => switch (weekday) {
  0 => const Color(0xFFD32F2F), // 일요일 빨강 (흰 배경 대비 4.98:1)
  6 => const Color(0xFF1565C0), // 토요일 파랑 (흰 배경 대비 5.75:1)
  _ => null,
};

/// 날짜 숫자 글자 모양 — DayCell · OutsideDayCell 공용
TextStyle _dateStyle(ThemeData theme) => theme.textTheme.labelLarge!.copyWith(
  fontSize: _dateFontSize,
  height: 1.2,
  fontWeight: FontWeight.w600,
);

/// 날짜 숫자 원 지름 — 글자가 커지면 원도 커진다
double _dateMarkSize(TextStyle style, TextScaler scaler) {
  final line = _lineHeight(style, scaler);
  return line + 6 > _dateMarkMin ? line + 6 : _dateMarkMin;
}

/// A-3 앞뒤 달 날짜 — 6주 격자를 채우는 흐린 숫자. 일정 · 탭 없음.
class OutsideDayCell extends StatelessWidget {
  const OutsideDayCell({super.key, required this.day, required this.weekday});

  final int day;
  final int weekday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _dateStyle(theme);
    final base = _weekdayColor(weekday) ?? theme.colorScheme.onSurface;
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(_cellPadding),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant,
              width: _cellBorder,
            ),
          ),
        ),
        alignment: Alignment.topCenter,
        child: SizedBox(
          height: _dateMarkSize(style, MediaQuery.textScalerOf(context)),
          child: Center(
            child: Text(
              '$day',
              style: style.copyWith(
                color: base.withValues(alpha: 0.35),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 글자 한 줄 높이 — 실제 그릴 때와 같은 글자 크기(textScaler)로 잰다.
double _lineHeight(TextStyle style, TextScaler scaler) {
  final painter = TextPainter(
    text: TextSpan(text: '가', style: style),
    textScaler: scaler,
    textDirection: TextDirection.ltr,
    maxLines: 1,
  )..layout();
  final height = painter.height;
  painter.dispose();
  return height;
}

/// 날짜 칸 하나: 날짜 숫자 · 일정 제목 미리보기(A-4) · 숨겨진 일정 수 표시(A-5)
class DayCell extends StatelessWidget {
  const DayCell({
    super.key,
    required this.date,
    required this.day,
    required this.weekday,
    required this.schedules,
    this.isToday = false,
    this.isSelected = false,
    this.onTap,
  });

  final String date;
  final int day;
  final int weekday;
  final List<Schedule> schedules;

  /// A-10 오늘(진한 원) · 선택한 날짜(테두리 원 + 옅은 칸 배경)
  final bool isToday;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final scaler = MediaQuery.textScalerOf(context);
    // 글꼴 줄 높이(height)를 고정해 계산과 그리기가 같은 높이가 되게 한다
    final dateStyle = _dateStyle(
      theme,
    ).copyWith(color: _weekdayColor(weekday) ?? scheme.onSurface);
    final pillStyle = theme.textTheme.labelMedium!.copyWith(
      fontSize: _pillFontSize,
      height: 1.25,
      letterSpacing: 0,
      fontWeight: FontWeight.w500,
    );
    final badgeStyle = pillStyle.copyWith(
      fontWeight: FontWeight.w700,
      color: scheme.primary,
    );
    final headerHeight = _dateMarkSize(dateStyle, scaler);
    final pillLine = _lineHeight(pillStyle, scaler);
    final badgeLine = _lineHeight(badgeStyle, scaler);
    final total = schedules.length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final inner = constraints.maxHeight - _cellPadding * 2 - _cellBorder;
        final visible = visibleScheduleCount(
          total: total,
          space: inner - headerHeight - _headerGap,
          pillHeight: pillLine + _pillPadV * 2 + _pillGap,
          badgeHeight: badgeLine + _pillPadV * 2,
        );
        final hidden = total - visible;
        final label = StringBuffer('10월 $day일 ${_weekdays[weekday]}요일, ')
          ..write(isToday ? '오늘, ' : '')
          ..write(isSelected ? '선택됨, ' : '')
          ..write(total == 0 ? '일정 없음' : '일정 $total개')
          ..write(hidden > 0 ? ', $hidden개 숨겨짐' : '')
          ..write(', 눌러서 하루 전체 일정 보기');

        // 날짜 칸 = 버튼 하나(라벨로 요약). 안의 글자는 읽지 않고, +N개 배지만 따로 읽힌다.
        return Semantics(
          container: true,
          label: label.toString(),
          button: true,
          child: Material(
            // A-10 선택한 날짜: 옅은 칸 배경 (물결 효과가 배경 위에 보이도록 Material 사용)
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.07)
                : Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(_cellPadding),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: scheme.outlineVariant,
                      width: _cellBorder,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ExcludeSemantics(
                      child: SizedBox(
                        height: headerHeight,
                        child: Center(
                          child: DateMark(
                            day: day,
                            size: headerHeight,
                            style: dateStyle,
                            isToday: isToday,
                            isSelected: isSelected,
                          ), // A-10 P01
                        ),
                      ),
                    ),
                    const SizedBox(height: _headerGap),
                    for (final s in schedules.take(visible))
                      Padding(
                        padding: const EdgeInsets.only(bottom: _pillGap),
                        child: ExcludeSemantics(
                          child: SchedulePill(
                            schedule: s,
                            height: pillLine + _pillPadV * 2,
                            style: pillStyle,
                          ),
                        ),
                      ), // A-4 P06
                    if (hidden > 0)
                      HiddenCountBadge(
                        key: ValueKey('hidden-badge-$date'),
                        hidden: hidden,
                        height: badgeLine + _pillPadV * 2,
                        style: badgeStyle,
                        semanticsLabel: '10월 $day일 숨겨진 일정 $hidden개 더 보기',
                        onTap: onTap,
                      ), // A-5 P01
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A-10 날짜 숫자 — 오늘: 진한 원 + 흰 글자 · 선택: 테두리 원 · 그 외: 숫자만
class DateMark extends StatelessWidget {
  const DateMark({
    super.key,
    required this.day,
    required this.size,
    required this.style,
    this.isToday = false,
    this.isSelected = false,
  });

  final int day;
  final double size;
  final TextStyle style;
  final bool isToday;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: isToday
          ? BoxDecoration(color: scheme.primary, shape: BoxShape.circle)
          : isSelected
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: scheme.primary, width: 1.5),
            )
          : null,
      child: Text(
        '$day',
        maxLines: 1,
        softWrap: false,
        style: isToday
            ? style.copyWith(
                color: scheme.onPrimary,
                fontWeight: FontWeight.w700,
              )
            : style,
      ),
    );
  }
}

/// 캘린더 색 위 글자 색 — 흰색 · 진회색 중 대비가 큰 쪽 (WCAG 대비 비율)
Color _onScheduleColor(Color background) {
  const dark = Color(0xFF1B1B1F);
  final bg = background.computeLuminance();
  final whiteContrast = 1.05 / (bg + 0.05);
  final darkContrast = (bg + 0.05) / (dark.computeLuminance() + 0.05);
  return whiteContrast >= darkContrast ? Colors.white : dark;
}

/// A-4 일정 제목 미리보기 — 캘린더 색으로 채운 막대 + 제목 1줄 말줄임
class SchedulePill extends StatelessWidget {
  const SchedulePill({
    super.key,
    required this.schedule,
    required this.height,
    required this.style,
  });

  final Schedule schedule;
  final double height;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final color =
        parseScheduleColor(schedule.color) ??
        Theme.of(context).colorScheme.primary;
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: _pillPadV),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        schedule.title,
        style: style.copyWith(color: _onScheduleColor(color)),
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// A-5 숨겨진 일정 수 표시 — '+N개 ›'. 자리를 먼저 확보하므로 칸 밖으로 밀리지 않는다.
/// 누를 수 있다는 표시: 칸 너비 전체 테두리 버튼 + 오른쪽 화살표 + 누를 때 물결(InkWell). 누르면 같은 날짜의 B로.
/// 채운 일정 막대(A-4)와 달리 흰 바탕 + 테두리라서 일정으로 오해하지 않는다.
class HiddenCountBadge extends StatelessWidget {
  const HiddenCountBadge({
    super.key,
    required this.hidden,
    required this.height,
    required this.style,
    required this.semanticsLabel,
    this.onTap,
  });

  final int hidden;
  final double height;
  final TextStyle style;

  /// 화면 읽기 프로그램용 (예: '10월 28일 숨겨진 일정 3개 더 보기')
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) {
        // 아주 좁은 칸에서는 '개'를 생략
        final text = constraints.maxWidth < 32 ? '+$hidden' : '+$hidden개';
        final radius = BorderRadius.circular(4);
        return SizedBox(
          width: double.infinity, // 칸 너비 전체 = 누르기 쉬운 영역
          child: Semantics(
            button: true,
            label: semanticsLabel,
            excludeSemantics: true,
            child: Material(
              color: scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: radius,
                side: BorderSide(color: scheme.primary),
              ),
              clipBehavior:
                  Clip.antiAlias, // 물결 효과만 모서리에 맞춘다 (글자는 FittedBox로 줄여 잘리지 않음)
              child: InkWell(
                onTap: onTap,
                child: Container(
                  height: height,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: _pillPadV,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(text, style: style, maxLines: 1),
                        Icon(
                          Icons.chevron_right,
                          size: style.fontSize,
                          color: style.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// '#RRGGBB' → Color (형식이 틀리면 null → 기본 색) — 화면 A · B 공용
Color? parseScheduleColor(String hex) {
  final value = int.tryParse(hex.replaceFirst('#', ''), radix: 16);
  if (value == null || hex.length != 7) return null;
  return Color(0xFF000000 | value);
}
