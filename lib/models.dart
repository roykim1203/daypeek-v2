// 데이터 모양 — db.json의 한 항목을 화면이 쓰기 좋은 객체로 바꾼다.
// 형식이 틀린 항목은 null을 돌려준다 → 목록에서 빠질 뿐 앱이 멈추지 않는다 (Dart 3 패턴 매칭).
//
// 필드 이름은 db.json의 키와 같아야 한다.
//   Schedule = 일정 (화면 A · B · C), DayNote = 하루 메모 (화면 B).

/// 일정 — db.json "schedules"의 한 항목
class Schedule {
  const Schedule({
    required this.id,
    required this.date,
    required this.start,
    required this.end,
    required this.title,
    required this.calendar,
    required this.color,
    this.location = '',
    this.memo = '',
    this.authorName = '',
    this.authorInitial = '',
  });

  final int id;

  /// 'YYYY-MM-DD'
  final String date;

  /// 'HH:mm'
  final String start;
  final String end;
  final String title;

  /// 캘린더 이름 (예: 학교 · 개인)
  final String calendar;

  /// 캘린더 색 '#RRGGBB'
  final String color;
  final String location;
  final String memo;

  /// 일정 등록자 — 가상 이름 · 이니셜 (로그인 · 사용자 조회 없음)
  final String authorName;
  final String authorInitial;

  static Schedule? fromJson(Object? json) {
    return switch (json) {
      {
        'id': int id,
        'date': String date,
        'start': String start,
        'end': String end,
        'title': String title,
        'calendar': String calendar,
        'color': String color,
      } =>
        Schedule(
          id: id,
          date: date,
          start: start,
          end: end,
          title: title,
          calendar: calendar,
          color: color,
          // 있어도 되고 없어도 되는 필드
          location: switch (json['location']) {
            String s => s,
            _ => '',
          },
          memo: switch (json['memo']) {
            String s => s,
            _ => '',
          },
          authorName: switch (json['authorName']) {
            String s => s,
            _ => '',
          },
          authorInitial: switch (json['authorInitial']) {
            String s => s,
            _ => '',
          },
        ),
      _ => null,
    };
  }
}

/// 하루 메모 — db.json "notes"의 한 항목 (작성자는 가명)
class DayNote {
  const DayNote({
    required this.id,
    required this.date,
    required this.author,
    required this.time,
    required this.text,
  });

  final int id;

  /// 'YYYY-MM-DD'
  final String date;
  final String author;

  /// 'HH:mm'
  final String time;
  final String text;

  static DayNote? fromJson(Object? json) {
    return switch (json) {
      {
        'id': int id,
        'date': String date,
        'author': String author,
        'time': String time,
        'text': String text,
      } =>
        DayNote(id: id, date: date, author: author, time: time, text: text),
      _ => null,
    };
  }
}
