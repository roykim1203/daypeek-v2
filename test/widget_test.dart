// 화면 A 월간 달력: 3상태(로딩·오류·빈) + 숨겨진 일정 수 표시(+N개) + 적응형(600dp)
// 화면 B 하루 전체 일정: push · tab · 3상태 · 가짜 저장 · AI 하루 브리핑(예시) / 화면 C 일정 상세: modal · 닫기 · 뒤로
// 네트워크를 쓰지 않도록 가짜 loader를 넣는다 → json-server 없이 `flutter test`가 돈다.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mid_project_template/api.dart';
import 'package:mid_project_template/models.dart';
import 'package:mid_project_template/screens/a_list_screen.dart';
import 'package:mid_project_template/screens/b_detail_screen.dart';
import 'package:mid_project_template/screens/c_result_sheet.dart';

Schedule _s(int id, String date, String title) => Schedule(
  id: id,
  date: date,
  start: '09:00',
  end: '10:00',
  title: title,
  calendar: '개인',
  color: '#AD1457',
);

/// 현행 앱 직접 테스트와 같은 날: 2026-10-28 일정 5개
final _schedules = [
  _s(1, '2026-10-05', '두 개 1'),
  _s(2, '2026-10-05', '두 개 2'),
  for (var i = 0; i < 7; i++) _s(10 + i, '2026-10-20', '일곱 개 ${i + 1}'),
  _s(21, '2026-10-28', '전공 수업'),
  _s(22, '2026-10-28', '스터디 모임'),
  _s(23, '2026-10-28', '점심 약속'),
  const Schedule(
    id: 24,
    date: '2026-10-28',
    start: '15:00',
    end: '16:30',
    title: '팀 프로젝트 회의',
    calendar: '팀',
    color: '#E65100',
    location: '회의실 B',
    memo: '준비: 발표 자료 최종본 검토, 역할별 진행 상황 공유, 노트북 지참',
    authorName: '팀원 A',
    authorInitial: 'A',
  ),
  _s(25, '2026-10-28', '운동'),
];

final _notes = [
  const DayNote(
    id: 1,
    date: '2026-10-28',
    author: '팀원 A',
    time: '08:40',
    text: '회의실이 바뀌었어요.',
  ),
];

/// 화면 B용 가짜 GET: 날짜로 거르기만 한다 (json-server의 ?date= 와 같은 결과)
Future<List<Schedule>> _dayLoader(String date) async =>
    _schedules.where((s) => s.date == date).toList();
Future<List<DayNote>> _notesLoader(String date) async =>
    _notes.where((n) => n.date == date).toList();

Widget _app(
  MonthSchedulesLoader load, {
  DaySchedulesLoader loadDay = _dayLoader,
  DayNotesLoader loadNotes = _notesLoader,
}) => MaterialApp(
  home: MonthCalendarScreen(load: load, loadDay: loadDay, loadNotes: loadNotes),
);

void _setSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Finder _badgeOf(String date) => find.byKey(ValueKey('hidden-badge-$date'));

/// 화면 B '일정' 목록을 그 일정이 보일 때까지 스크롤 (좁은 화면 · 큰 글씨용)
Future<void> _scrollBTo(WidgetTester tester, String title) =>
    tester.scrollUntilVisible(
      _inB(title),
      100,
      scrollable: find
          .descendant(
            of: find.byType(DayScheduleScreen),
            matching: find.byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
            ),
          )
          .first,
    );

/// 화면 B 패널 안의 글자만 찾는다 (B가 올라와도 뒤에 화면 A 달력이 그대로 보이므로)
Finder _inB(String text) => find.descendant(
  of: find.byType(DayScheduleScreen),
  matching: find.text(text),
);

Future<void> _pickTextSize(WidgetTester tester, String label) async {
  await tester.tap(find.byIcon(Icons.format_size));
  await tester.pumpAndSettle();
  await tester.tap(
    find.ancestor(
      of: find.text('글자 $label'),
      matching: find.byType(CheckedPopupMenuItem<CalendarTextSize>),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('3상태: 로딩 → 오류 → 다시 시도 → 성공', (tester) async {
    _setSize(tester, const Size(400, 800));

    final first = Completer<List<Schedule>>();
    var calls = 0;
    await tester.pumpWidget(
      _app(() => ++calls == 1 ? first.future : Future.value(_schedules)),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('달력을 불러오는 중…'), findsOneWidget);

    first.completeError(Exception('테스트 오류'));
    await tester.pumpAndSettle();
    expect(find.text('달력을 불러오지 못했습니다.'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    expect(find.text('2026년 10월'), findsOneWidget);
    expect(calls, 2);
  });

  testWidgets('3상태: 빈 상태', (tester) async {
    await tester.pumpWidget(_app(() async => const []));
    await tester.pumpAndSettle();
    expect(find.text('이번 달 일정이 없습니다.'), findsOneWidget);
  });

  group('숨겨진 일정 수 표시 (좁은 화면 400dp, 10월 28일 일정 5개)', () {
    testWidgets('보통: 2개 보임 → +3개', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();

      final day28 = find.byKey(const ValueKey('day-2026-10-28'));
      expect(
        find.descendant(of: day28, matching: find.byType(SchedulePill)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(of: _badgeOf('2026-10-28'), matching: find.text('+3개')),
        findsOneWidget,
      );
    });

    testWidgets('작게: 3개 보임 → +2개', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      await _pickTextSize(tester, '작게');

      final day28 = find.byKey(const ValueKey('day-2026-10-28'));
      expect(
        find.descendant(of: day28, matching: find.byType(SchedulePill)),
        findsNWidgets(3),
      );
      expect(
        find.descendant(of: _badgeOf('2026-10-28'), matching: find.text('+2개')),
        findsOneWidget,
      );
    });

    testWidgets('크게: 2개 보임 → +3개', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      await _pickTextSize(tester, '크게');

      final day28 = find.byKey(const ValueKey('day-2026-10-28'));
      expect(
        find.descendant(of: day28, matching: find.byType(SchedulePill)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(of: _badgeOf('2026-10-28'), matching: find.text('+3개')),
        findsOneWidget,
      );
    });

    testWidgets('일정이 모두 보이면 배지 없음 (10월 5일 2개)', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();

      final day5 = find.byKey(const ValueKey('day-2026-10-05'));
      expect(
        find.descendant(of: day5, matching: find.byType(SchedulePill)),
        findsNWidgets(2),
      );
      expect(_badgeOf('2026-10-05'), findsNothing);
    });

    testWidgets('일정 0개 날은 막대·배지 없음, 7개 날은 2개 + +5개', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();

      final day1 = find.byKey(const ValueKey('day-2026-10-01'));
      expect(
        find.descendant(of: day1, matching: find.byType(SchedulePill)),
        findsNothing,
      );
      expect(_badgeOf('2026-10-01'), findsNothing);

      final day20 = find.byKey(const ValueKey('day-2026-10-20'));
      expect(
        find.descendant(of: day20, matching: find.byType(SchedulePill)),
        findsNWidgets(2),
      );
      expect(
        find.descendant(of: _badgeOf('2026-10-20'), matching: find.text('+5개')),
        findsOneWidget,
      );
    });

    testWidgets('오늘(10/29) 표시 · B에서 돌아오면 누른 날짜(10/28)가 선택 표시', (tester) async {
      _setSize(tester, const Size(400, 800));
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp(r'^10월 29일 .*오늘')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('선택됨')), findsNothing);

      await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('하루 일정 닫기')); // B 패널 ✕
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel(RegExp(r'^10월 28일 .*선택됨')), findsOneWidget);
      handle.dispose();
    });
  });

  testWidgets('적응형: 600dp 이상이면 칸이 커져 28일 5개가 모두 보이고, 20일 7개는 배지', (
    tester,
  ) async {
    _setSize(tester, const Size(1024, 900));
    await tester.pumpWidget(_app(() async => _schedules));
    await tester.pumpAndSettle();

    final day28 = find.byKey(const ValueKey('day-2026-10-28'));
    expect(
      find.descendant(of: day28, matching: find.byType(SchedulePill)),
      findsNWidgets(5),
    );
    expect(_badgeOf('2026-10-28'), findsNothing);
    expect(_badgeOf('2026-10-20'), findsOneWidget);
  });

  group('화면 B 하루 전체 일정', () {
    testWidgets('날짜 칸 → push → 10월 28일 5개 시간순 · 하루 메모 탭', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
      await tester.pumpAndSettle();
      expect(find.text('10월 28일 (수)'), findsOneWidget);
      expect(
        find.byType(DaySchedulePanel),
        findsOneWidget,
      ); // push (아래에서 올라오는 패널)
      // 화면 C와 같은 배치: 왼쪽 날짜 제목 · 같은 줄 오른쪽 끝 ✕
      final close = find.byTooltip('하루 일정 닫기');
      expect(close, findsOneWidget);
      expect(find.byType(CloseButton), findsNothing);
      final titleRect = tester.getRect(_inB('10월 28일 (수)'));
      final closeRect = tester.getRect(close);
      expect(closeRect.left, greaterThan(titleRect.right));
      expect((closeRect.center.dy - titleRect.center.dy).abs(), lessThan(2));
      // 오른쪽 여백: 패널 가장자리 ~ ✕ 아이콘 중심 약 40 · 터치 영역 44×44 이상
      final panelRight = tester.getRect(find.byType(DaySchedulePanel)).right;
      final iconCenter = tester
          .getCenter(
            find.descendant(of: close, matching: find.byIcon(Icons.close)),
          )
          .dx;
      expect(panelRight - iconCenter, closeTo(40, 2));
      final tapSize = tester.getSize(
        find.byKey(const ValueKey('day-panel-close')),
      );
      expect(tapSize.width, greaterThanOrEqualTo(44));
      expect(tapSize.height, greaterThanOrEqualTo(44));
      expect(find.text('일정 5개 · 시간순'), findsOneWidget);
      expect(find.byType(ScheduleTile), findsNWidgets(5));

      // 빠짐없이 · 받은 순서(시간순) 그대로 위에서 아래로
      final titles = ['전공 수업', '스터디 모임', '점심 약속', '팀 프로젝트 회의', '운동'];
      final ys = [for (final t in titles) tester.getTopLeft(_inB(t)).dy];
      for (var i = 1; i < ys.length; i++) {
        expect(ys[i], greaterThan(ys[i - 1]));
      }

      await tester.tap(find.text('하루 메모'));
      await tester.pumpAndSettle();
      expect(find.text('회의실이 바뀌었어요.'), findsOneWidget);
      expect(find.text('팀원 A · 08:40'), findsOneWidget);
    });

    testWidgets('B 패널: 뒤쪽 A는 어둡게 · 손잡이 아래로 끌기 · 뒤로 가기 · 바깥 누르기로 닫힘', (
      tester,
    ) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      Future<void> open() async {
        await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
        await tester.pumpAndSettle();
        expect(find.byType(DaySchedulePanel), findsOneWidget);
      }

      await open();
      expect(find.text('2026년 10월'), findsOneWidget); // 뒤에 A가 그대로 보임
      expect(
        find.byWidgetPredicate(
          (w) => w is ModalBarrier && w.color == Colors.black54,
        ),
        findsOneWidget,
      ); // 반투명하게 어두운 뒤쪽

      // 조금 끌면 제자리로, 충분히 끌면 닫힘
      await tester.drag(
        find.byKey(const ValueKey('day-panel-handle')),
        const Offset(0, 40),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DaySchedulePanel), findsOneWidget);
      await tester.drag(
        find.byKey(const ValueKey('day-panel-handle')),
        const Offset(0, 300),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DaySchedulePanel), findsNothing);

      await open();
      await tester.binding.handlePopRoute(); // 시스템 뒤로 가기
      await tester.pumpAndSettle();
      expect(find.byType(DaySchedulePanel), findsNothing);

      await open();
      await tester.tapAt(const Offset(200, 20)); // 패널 위쪽 어두운 부분
      await tester.pumpAndSettle();
      expect(find.byType(DaySchedulePanel), findsNothing);
    });

    testWidgets('일정 오른쪽 등록자 이니셜 배지 (화살표와 함께)', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
      await tester.pumpAndSettle();

      final tile = find.widgetWithText(ScheduleTile, '팀 프로젝트 회의');
      final badge = find.descendant(
        of: tile,
        matching: find.byType(AuthorBadge),
      );
      expect(badge, findsOneWidget);
      expect(
        find.descendant(of: badge, matching: find.text('A')),
        findsOneWidget,
      );
      final arrow = find.descendant(
        of: tile,
        matching: find.byIcon(Icons.chevron_right),
      );
      // 배지가 화살표 왼쪽에 겹치지 않게 놓임
      expect(
        tester.getRect(badge).right,
        lessThanOrEqualTo(tester.getRect(arrow).left),
      );
    });

    testWidgets('AI 하루 브리핑(예시): 접혀 있다가 펼치면 개수 · 오전/오후/저녁 흐름 · 예시 고지', (
      tester,
    ) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
      await tester.pumpAndSettle();

      final card = find.byType(DayBriefingCard);
      expect(card, findsOneWidget);
      Finder inCard(String t) =>
          find.descendant(of: card, matching: find.text(t));
      expect(inCard('AI 하루 브리핑 (예시)'), findsOneWidget);
      expect(inCard('19:00 운동'), findsNothing); // 처음에는 접힘

      await tester.tap(inCard('AI 하루 브리핑 (예시)'));
      await tester.pumpAndSettle();
      expect(inCard('일정 5개 · 오전 2개, 오후 2개, 저녁 1개로 이어지는 하루'), findsOneWidget);
      expect(inCard('09:00 전공 수업 → 11:00 스터디 모임'), findsOneWidget);
      expect(inCard('13:00 점심 약속 → 15:00 팀 프로젝트 회의(회의실 B)'), findsOneWidget);
      expect(inCard('19:00 운동'), findsOneWidget);
      expect(inCard('※ 실제 AI 호출이 아닌, 미리 작성된 시연용 브리핑입니다.'), findsOneWidget);

      await tester.tap(inCard('AI 하루 브리핑 (예시)'));
      await tester.pumpAndSettle();
      expect(inCard('19:00 운동'), findsNothing); // 다시 접힘
      expect(find.byType(ScheduleTile), findsNWidgets(5)); // 전체 목록은 그대로
    });

    test('미리 작성된 브리핑은 db.json 일정과 개수 · 시간이 맞음', () {
      // 실제 db.json(가상 데이터)을 읽어 날짜별 일정과 브리핑 문장을 대조한다 (네트워크 없음)
      final db =
          jsonDecode(File('mock_server/db.json').readAsStringSync())
              as Map<String, dynamic>;
      final schedules = (db['schedules'] as List)
          .map(Schedule.fromJson)
          .nonNulls;
      for (final MapEntry(key: date, value: b) in demoBriefings.entries) {
        final day = schedules.where((s) => s.date == date).toList();
        expect(b.headline, startsWith('일정 ${day.length}개'), reason: date);
        final text = '${b.morning} ${b.afternoon} ${b.evening}';
        for (final s in day) {
          expect(
            text,
            contains('${s.start} ${s.title}'),
            reason: '$date ${s.title}',
          );
        }
      }
    });

    testWidgets('+N개 배지를 눌러도 같은 날짜의 B로', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();

      await tester.tap(_badgeOf('2026-10-28'));
      await tester.pumpAndSettle();
      expect(find.text('10월 28일 (수)'), findsOneWidget);
      expect(find.byType(ScheduleTile), findsNWidgets(5));
    });

    testWidgets('+N개 배지 접근성 레이블', (tester) async {
      _setSize(tester, const Size(400, 800));
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('10월 28일 숨겨진 일정 3개 더 보기'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('일정 오류 → 다시 시도 · 일정 없는 날 빈 상태 · 메모 빈 상태', (tester) async {
      _setSize(tester, const Size(400, 800));
      var calls = 0;
      await tester.pumpWidget(
        _app(
          () async => _schedules,
          loadDay: (date) async {
            if (++calls == 1) throw Exception('테스트 오류');
            return _dayLoader(date);
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('day-2026-10-01')));
      await tester.pumpAndSettle();
      expect(find.text('일정을 불러오지 못했습니다.'), findsOneWidget);

      await tester.tap(find.text('다시 시도'));
      await tester.pumpAndSettle();
      expect(find.text('이 날은 일정이 없습니다.'), findsOneWidget);

      await tester.tap(find.text('하루 메모'));
      await tester.pumpAndSettle();
      expect(find.text('이 날 남긴 메모가 없습니다.'), findsOneWidget);
    });

    testWidgets('좁은 화면 320dp · 시스템 글자 1.3배에서도 넘침 없음', (tester) async {
      _setSize(tester, const Size(320, 640));
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
      await tester.pumpAndSettle();
      expect(find.byType(DayBriefingCard), findsOneWidget);
      expect(tester.takeException(), isNull); // RenderFlex overflow 등 없음

      // 브리핑을 펼쳐도 넘치지 않고, 목록은 스크롤로 마지막 일정까지 닿는다
      await tester.tap(find.text('AI 하루 브리핑 (예시)'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await _scrollBTo(tester, '운동');
      expect(_inB('운동'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('일정 추가는 SnackBar로만 응답 (저장 없음)', (tester) async {
      _setSize(tester, const Size(400, 800));
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('일정 추가 (예시)'));
      await tester.pump();
      expect(find.text('예시 화면입니다 — 실제로 저장하지 않습니다.'), findsOneWidget);
    });
  });

  group('화면 C 일정 상세', () {
    Future<void> openDay28(WidgetTester tester) async {
      await tester.pumpWidget(_app(() async => _schedules));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('day-2026-10-28')));
      await tester.pumpAndSettle();
    }

    testWidgets('팀 프로젝트 회의 → modal: 날짜·시간·캘린더·등록자·장소·일정 메모 (AI 영역 없음)', (
      tester,
    ) async {
      _setSize(tester, const Size(400, 800));
      await openDay28(tester);

      await tester.tap(_inB('팀 프로젝트 회의'));
      await tester.pumpAndSettle();
      final sheet = find.byType(ScheduleDetailSheet);
      expect(sheet, findsOneWidget); // modal
      Finder inSheet(String t) =>
          find.descendant(of: sheet, matching: find.text(t));
      expect(inSheet('팀 프로젝트 회의'), findsOneWidget);
      expect(inSheet('10월 28일 (수)'), findsOneWidget);
      expect(inSheet('15:00 – 16:30'), findsOneWidget);
      expect(inSheet('팀 캘린더'), findsOneWidget);
      expect(inSheet('등록: 팀원 A'), findsOneWidget);
      expect(inSheet('회의실 B'), findsOneWidget);
      expect(inSheet('일정 메모 · 이 일정에만'), findsOneWidget);
      expect(inSheet('준비: 발표 자료 최종본 검토, 역할별 진행 상황 공유, 노트북 지참'), findsOneWidget);

      // 일정 하나를 다시 요약하던 AI 영역은 C에서 제거됨 (B-9 하루 브리핑으로 옮김)
      expect(
        find.descendant(of: sheet, matching: find.textContaining('AI')),
        findsNothing,
      );
    });

    testWidgets('✕ 버튼 · 뒤로 가기 · Esc로 닫히고 B에 그대로 남음 (아래 닫기 버튼 없음)', (
      tester,
    ) async {
      _setSize(tester, const Size(400, 800));
      await openDay28(tester);

      await tester.tap(_inB('팀 프로젝트 회의'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextButton, '닫기'), findsNothing); // 중복 닫기 제거
      await tester.tap(find.byTooltip('닫기'));
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleDetailSheet), findsNothing);
      expect(find.text('10월 28일 (수)'), findsOneWidget); // B에 머묾

      await tester.tap(_inB('운동'));
      await tester.pumpAndSettle();
      expect(find.text('이 일정에 남긴 메모가 없습니다.'), findsOneWidget);
      await tester.binding.handlePopRoute(); // 시스템 뒤로 가기
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleDetailSheet), findsNothing);
      expect(find.byType(ScheduleTile), findsNWidgets(5));

      await tester.tap(_inB('전공 수업'));
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleDetailSheet), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape); // Esc
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleDetailSheet), findsNothing);
      expect(find.byType(ScheduleTile), findsNWidgets(5));
    });

    testWidgets('하루 메모 탭은 일정 메모와 구분 안내', (tester) async {
      _setSize(tester, const Size(400, 800));
      await openDay28(tester);
      await tester.tap(find.text('하루 메모'));
      await tester.pumpAndSettle();
      expect(
        find.text('이 날짜 전체에 남긴 메모입니다. 일정별 메모는 일정을 누르면 보입니다.'),
        findsOneWidget,
      );
    });

    testWidgets('좁은 화면 320dp · 시스템 글자 1.3배에서도 넘침 없음', (tester) async {
      _setSize(tester, const Size(320, 640));
      tester.platformDispatcher.textScaleFactorTestValue = 1.3;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await openDay28(tester);

      await _scrollBTo(tester, '팀 프로젝트 회의');
      await tester.tap(_inB('팀 프로젝트 회의'));
      await tester.pumpAndSettle();
      expect(find.byType(ScheduleDetailSheet), findsOneWidget);
      expect(tester.takeException(), isNull);

      // 맨 아래 일정 메모까지 스크롤해서 보인다
      await tester.scrollUntilVisible(
        find.text('준비: 발표 자료 최종본 검토, 역할별 진행 상황 공유, 노트북 지참'),
        100,
        scrollable: find.descendant(
          of: find.byType(ScheduleDetailSheet),
          matching: find.byType(Scrollable),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  test('표시 계산: 다 들어가면 전부, 아니면 배지 자리를 빼고 계산', () {
    expect(
      visibleScheduleCount(
        total: 2,
        space: 60,
        pillHeight: 20,
        badgeHeight: 18,
      ),
      2,
    );
    expect(
      visibleScheduleCount(
        total: 5,
        space: 72,
        pillHeight: 20,
        badgeHeight: 18,
      ),
      2,
    );
    expect(
      visibleScheduleCount(
        total: 5,
        space: 80,
        pillHeight: 18,
        badgeHeight: 16,
      ),
      3,
    );
    expect(
      visibleScheduleCount(
        total: 3,
        space: 10,
        pillHeight: 20,
        badgeHeight: 18,
      ),
      0,
    );
  });
}
