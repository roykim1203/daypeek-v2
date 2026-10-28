// DayPeek — TimeTree v2 개선 프로토타입 · GAI3008 중간고사 (UI만 구현)
//
// ┌──────── 디자인 가이드 대응표: 앱 뼈대 ──────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명        │ 비즈니스 명칭(한글)      │ 원칙(P번호)       │
// │ S-1  │ MaterialApp           │ 앱 이름 'DayPeek'        │ —                 │
// │ S-2  │ ThemeData(seedColor)  │ 브랜드 색 · 흰 바탕      │ P04 일관성        │
// └────────────────────────────────────────────────────────────────────────────┘
// 화면 흐름(docs/디자인가이드.md 1장과 같게):
//   A 월간 달력 ──쌓기(push)──▶ B 하루 전체 일정 [옆으로(tab): 일정 | 하루 메모] ──덮기(modal)──▶ C 일정 상세·AI 요약(예시)
// 기획 문서에 없는 화면은 만들지 않는다(감점). 화면을 늘리면 이 주석·가이드도 같이 고친다.
import 'package:flutter/material.dart';

import 'screens/a_list_screen.dart';

void main() => runApp(const DayPeekApp());

/// DayPeek 브랜드 색 — 초록 계열 청록 (TimeTree의 색을 그대로 쓰지 않는 독자 색)
const dayPeekSeed = Color(0xFF2A9D8F);

class DayPeekApp extends StatelessWidget {
  const DayPeekApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayPeek', // S-1 — 브라우저 탭 이름
      debugShowCheckedModeBanner: false,
      // S-2 P04 — 화면 A·B·C 공통: 흰 바탕 + 같은 브랜드 색 (연보라 기본 바탕 제거)
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: dayPeekSeed,
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
      ),
      home: const MonthCalendarScreen(),
    );
  }
}
