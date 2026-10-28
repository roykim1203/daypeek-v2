// 화면 C: 일정 상세 — 덮기(modal). B 하루 전체 일정에서 일정 한 줄을 누르면 열린다.
//
// ┌──────── 디자인 가이드 대응표: C 일정 상세 ───────────────────────────────────────────┐
// │ 번호 │ Flutter 위젯명                          │ 비즈니스 명칭(한글)  │ 원칙(P번호)    │
// │ C-1  │ showModalBottomSheet + 손잡이 + ✕ 버튼  │ 일정 상세 시트       │ P03 통제·자유  │
// │ C-2  │ Text(titleLarge) + 캘린더 색 점·이름    │ 일정 제목·캘린더     │ P06 재인       │
// │ C-3  │ ListTile × 3 (날짜·시간 / 장소 / 메모)  │ 일정 정보            │ P02 실세계     │
// │ C-4  │ Row(Icon + Text)                        │ 일정 등록자          │ P06 재인       │
// └────────────────────────────────────────────────────────────────────────────────────┘
//
// AI 예시는 일정 하나를 다시 요약하던 C에서 빼고, 하루 전체 흐름을 보여 주는 B-9 'AI 하루 브리핑(예시)'로 옮겼다.
// 일정별 메모(Schedule.memo)는 이 일정에만 속한다 — 날짜 전체의 '하루 메모'(B-5)와 다르다.
import 'package:flutter/material.dart';

import '../models.dart';
import 'a_list_screen.dart' show parseScheduleColor;
import 'b_detail_screen.dart' show dayTitle;

/// 넓은 창에서 시트가 너무 퍼지지 않게
const _maxSheetWidth = 640.0;

class ScheduleDetailSheet extends StatelessWidget {
  const ScheduleDetailSheet({super.key, required this.schedule});

  final Schedule schedule;

  /// 덮기(modal): 지금 화면 위에 띄우고, ✕ · 뒤로 가기 · Esc · 바깥 누르기 · 아래로 끌기로 닫는다.
  static Future<void> show(BuildContext context, Schedule schedule) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true, // C-1
      isScrollControlled: true, // 큰 글씨에서도 내용이 잘리지 않게 높이를 내용에 맞춘다
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: _maxSheetWidth),
      builder: (_) => ScheduleDetailSheet(schedule: schedule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = theme.textTheme;
    final muted = theme.colorScheme.onSurfaceVariant;
    final color =
        parseScheduleColor(schedule.color) ?? theme.colorScheme.primary;

    return SingleChildScrollView(
      // 화면보다 길어지면 시트 안에서 스크롤 (글자가 잘리거나 겹치지 않음)
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(schedule.title, style: text.titleLarge),
              ), // C-2 P06
              IconButton(
                tooltip: '닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
              ), // C-1 P03
            ],
          ),
          Row(
            children: [
              Icon(Icons.circle, size: 12, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${schedule.calendar} 캘린더',
                  style: text.bodyMedium?.copyWith(color: muted),
                ),
              ),
            ],
          ), // C-2
          if (schedule.authorName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16, color: muted),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '등록: ${schedule.authorName}',
                    style: text.bodyMedium?.copyWith(color: muted),
                  ),
                ),
              ],
            ), // C-4 P06
          ],
          const SizedBox(height: 8),
          // C-3 P02 — 언제 → 어디서 → 무엇을 준비 (종이 다이어리 순서)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: Text(dayTitle(schedule.date)),
            subtitle: Text('${schedule.start} – ${schedule.end}'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.place_outlined),
            title: const Text('장소'),
            subtitle: Text(
              schedule.location.isEmpty ? '장소 정보 없음' : schedule.location,
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_note),
            title: const Text('일정 메모 · 이 일정에만'),
            subtitle: Text(
              schedule.memo.isEmpty ? '이 일정에 남긴 메모가 없습니다.' : schedule.memo,
            ),
          ),
        ],
      ),
    );
  }
}
