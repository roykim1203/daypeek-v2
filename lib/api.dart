// 데이터 가져오기 — GET만 쓴다 (중간고사 안내 5장: POST/PUT/DELETE·저장은 감점)
// 화면 코드는 이 파일의 fetchMonthSchedules() / fetchDaySchedules() / fetchDayNotes()만 부른다. (관심사 분리)
//
// 서버 주소 (코드 수정 없이 실행할 때 바꾼다):
//   기본값  Android 에뮬레이터 → http://10.0.2.2:3000   그 외(Chrome·macOS·iOS 시뮬레이터) → http://localhost:3000
//   실기기  flutter run --dart-define=API_BASE=http://192.168.0.10:3000   (같은 Wi-Fi의 PC IP)
//   배포    flutter build web --dart-define=API_BASE=https://<프로젝트>.vercel.app/api   (가산점)
//
// 발표·데모용 상태 스위치 (로딩·오류·빈 상태를 눈으로 보여 주기):
//   --dart-define=DEMO_STATE=loading → 3초 늦게 응답 (로딩 상태)
//   --dart-define=DEMO_STATE=error   → 항상 실패 (오류 상태 + 다시 시도)
//   --dart-define=DEMO_STATE=empty   → 빈 목록 (빈 상태)
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

const _apiBaseOverride = String.fromEnvironment('API_BASE');

/// json-server 주소. API_BASE를 넘기면 그 값, 아니면 실행 대상에 맞는 기본값.
String get apiBase {
  if (_apiBaseOverride.isNotEmpty) return _apiBaseOverride;
  // Android 에뮬레이터 안의 localhost는 에뮬레이터 자신 → PC는 10.0.2.2
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}

/// loading(=slow) · error · empty — 그 외 값이면 평소처럼 서버에서 가져온다.
const demoState = String.fromEnvironment('DEMO_STATE');

/// 화면에 그대로 보여 줄 수 있는 오류 문장
class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// GET {apiBase}/{path} → JSON 배열
Future<List<Object?>> _getList(String path) async {
  switch (demoState) {
    case 'loading' || 'slow':
      await Future<void>.delayed(const Duration(seconds: 3));
    case 'error':
      throw const ApiException('DEMO_STATE=error 로 일부러 낸 오류입니다.');
    case 'empty':
      return const [];
  }
  final url = '$apiBase/$path';
  final http.Response res;
  try {
    res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
  } on Exception catch (e) {
    debugPrint('[GET 실패] $url — $e');
    throw ApiException('서버에 연결하지 못했습니다.\n$apiBase\nmock_server가 켜져 있는지 확인하세요.');
  }
  if (res.statusCode != 200) {
    throw ApiException('서버 응답 오류 (HTTP ${res.statusCode})\n$url');
  }
  // 한글이 깨지지 않도록 bytes를 UTF-8로 직접 디코딩
  final decoded = jsonDecode(utf8.decode(res.bodyBytes));
  if (decoded is! List) {
    throw ApiException('$url 의 응답이 배열이 아닙니다. db.json을 확인하세요.');
  }
  return decoded;
}

// TODO: db.json의 최상위 키 이름을 바꾸면 아래 경로('schedules', 'notes')도 같이 바꾼다.

/// 데모에서 보여 주는 달 (DayPeek 프로토타입은 2026년 10월만)
const shownMonth = '2026-10';

/// A 월간 달력: GET /schedules?date_like=2026-10&_sort=date,start
/// (json-server의 필터·정렬 쿼리 — 여전히 GET. 앱은 정렬하지 않고 받은 순서대로 보여 준다.)
Future<List<Schedule>> fetchMonthSchedules() async {
  final list = await _getList(
    'schedules?date_like=$shownMonth&_sort=date,start',
  );
  return list.map(Schedule.fromJson).nonNulls.toList();
}

/// B 하루 전체 일정 '일정' 탭: GET /schedules?date=2026-10-28&_sort=start
Future<List<Schedule>> fetchDaySchedules(String date) async {
  final list = await _getList('schedules?date=$date&_sort=start');
  return list.map(Schedule.fromJson).nonNulls.toList();
}

/// B 하루 전체 일정 '하루 메모' 탭: GET /notes?date=2026-10-28&_sort=time
Future<List<DayNote>> fetchDayNotes(String date) async {
  final list = await _getList('notes?date=$date&_sort=time');
  return list.map(DayNote.fromJson).nonNulls.toList();
}

/// 화면이 데이터를 받는 함수 모양 — 테스트에서는 가짜 함수를 넣는다.
typedef MonthSchedulesLoader = Future<List<Schedule>> Function();
typedef DaySchedulesLoader = Future<List<Schedule>> Function(String date);
typedef DayNotesLoader = Future<List<DayNote>> Function(String date);
