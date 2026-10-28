# DayPeek — TimeTree v2 · GAI3008 중간프로젝트 저장소 (1인 1팀)

## 앱 소개

> 앱스토어 상품 페이지처럼 채웁니다. 칸 이름과 순서는 발표 자료의 "앱 소개" 장과 같습니다 — 바꾸지 않습니다.
> **표시 규칙**: 아직 원본을 확인해 넣지 못한 칸은 `추후 원본 증거 삽입 필요`로 둡니다. 확인하지 않은 리뷰 · 별점 · 날짜는 쓰지 않습니다.

### 앱 이름
DayPeek (TimeTree v2)

### 부제
월간 달력에 숨은 일정까지 몇 개인지 바로 보이는 공유 캘린더

### 카테고리
생산성

### 대상 사용자 / 사용 상황
- 대상 사용자: 가족 · 팀 · 스터디와 공유 캘린더를 쓰며 하루에 일정이 여러 개 겹치는 사용자 (퍼소나 상세는 사업 요약 작성 후 맞춤 — 추후 작성 필요)
- 사용 상황: 휴대폰에서 월간 달력을 훑어보며 "오늘·이번 주 바쁜 날"을 확인할 때

### 스크린샷
이미지는 `docs/screenshots/`에 넣고 아래 파일 이름에 맞춥니다. 3~5칸, 왼쪽부터 v1(현행) → v2. **아직 캡처 파일이 없습니다 — 추후 삽입 필요.**

| v1 현행 | v2 화면 A | v2 화면 B | v2 화면 C | v2 넓은 화면 |
|---|---|---|---|---|
| `docs/screenshots/01_v1_current.png` (추후 삽입) | `02_v2_a.png` (추후 삽입) | `03_v2_b.png` (추후 삽입) | `04_v2_c.png` (추후 삽입) | `05_v2_wide.png` (추후 삽입) |
| 현행 TimeTree 월간 화면 — 2026-10-28(수) 일정 5개 중 일부만 보임 | 월간 달력 — 28일 칸에 `+N개` 숨김 배지 | 하루 전체 일정 패널 — 5개 시간순 · AI 하루 브리핑(예시) | 일정 상세 시트 — 시간 · 장소 · 일정 메모 · 등록자 | 넓은 창 — 칸이 커져 더 많은 일정 제목 |

### 설명
1. **무엇을 하는가**: 공유 캘린더 TimeTree의 v2 UI 프로토타입입니다. 월간 달력(A) → 하루 전체 일정(B) → 일정 상세(C) 흐름을 Flutter로 구현했고, 데이터는 로컬 json-server에서 **GET으로만** 가져옵니다.
2. **v2가 해결하는 문제**: 현행 앱은 같은 날짜에 일정이 많으면 월간 달력에 일부 제목만 보이고, 숨겨진 일정이 몇 개인지 알려 주지 않습니다. 작성자가 직접 테스트한 결과(2026-10-28, 일정 5개 등록) 글자 크기 작게 3개, 보통·크게 2개의 제목만 월간 화면에 보였고, 날짜를 눌러야 5개를 모두 확인할 수 있었습니다. 같은 불편을 제기한 실제 사용자 리뷰 원문 · 별점 · 날짜는 추후 원본 증거 삽입 필요.
3. **v2의 핵심 가치**: 날짜를 누르기 전에 "이 날 일정이 몇 개 더 있는지"를 `+N개`로 바로 알 수 있고, 누르면 그날 일정 전체를 시간순으로 빠짐없이 봅니다.

### 새로운 기능
v2에서 바뀐 것 3개 — 원칙 카드(`docs/원칙카드.md`)의 P번호와 연결합니다.

| P번호 | 바뀐 것 (화면 · 요소 번호) | 근거 (리뷰 · 원칙) |
|---|---|---|
| P01 | 화면 A · A-5 숨겨진 일정 수 표시 `+N개` — 칸 높이 · 글자 크기로 들어가는 일정 수를 정하고, 배지 자리를 먼저 확보해 잘림·겹침 없음. 누르면 B로 | 직접 테스트(2026-10-28: 5개 중 2~3개만 보이고 숨은 개수 안내 없음) · 닐슨 1 시스템 상태의 가시성 · 리뷰 원문은 추후 삽입 |
| P03 | 화면 B · B-0 하루 일정 패널 — 아래에서 올라오고 뒤의 달력이 보임. ✕ · 뒤로 · 아래로 끌기 · 바깥 누르기로 닫힘 | 닐슨 3 사용자 통제와 자유 |
| P10 | 화면 B · B-9 AI 하루 브리핑(예시) — 하루 전체 개수와 오전·오후·저녁 흐름. 미리 작성된 시연용 문장이며 실제 AI 호출 없음을 화면에 표시 | 닐슨 10 도움말과 문서 (예시임을 밝힘) · AI 활용 기회 |

### 평가 및 리뷰
| 항목 | 내용 |
|---|---|
| 현행 별점 | 추후 원본 증거 삽입 필요 |
| 리뷰 수 | 추후 원본 증거 삽입 필요 |
| 대표 리뷰 | 추후 원본 증거 삽입 필요 (원문 · ★ · 날짜, **작성자 이름 지움**) |
| 출처 | 추후 원본 증거 삽입 필요 (스토어 링크 · 확인한 날짜) |

---

## 작성자 · 제출 정보

| 칸 | 내용 |
|---|---|
| 현행 앱 | TimeTree (스토어 링크 추후 삽입) |
| v2 한 문장 | 월간 달력에서 숨겨진 일정 수를 `+N개`로 보여 주고, 하루 전체 일정을 한 번에 펼쳐 보는 TimeTree v2 |
| 작성자 | 추후 기입 (이름 또는 이니셜) · 1인 1팀 |
| 저장소 | https://github.com/roykim1203/daypeek-v2 |
| 데모 | 추후 삽입 — 데모 영상 1분(`docs/영상/demo_1min.mp4`) 또는 배포 URL (**제출물 ①에 필수**) |
| AI 사용 | 규칙 `AGENTS.md` · 기록 `docs/prompt-log.md` · 셀프 논증 기록 `docs/셀프논증.md` (두 문서는 아직 작성 전) |

> 이 저장소는 **UI만 구현**합니다(중간고사 안내문 5장). 보이기는 동작하는 것처럼, 실제 동작(저장 · 로그인 · 결제 · 실제 계산 · AI 호출)은 없습니다.
> 일정 추가는 "예시" SnackBar로만 응답하고, AI 하루 브리핑은 날짜별로 미리 작성한 문장입니다. 일정 등록자(나 · 팀원 A · 스터디원 B)와 메모 작성자는 모두 가상 데이터입니다.

---

## 0. 폴더 · 앱 이름 (완료)

- 폴더 · 저장소 이름: `daypeek-v2` (경로는 영문 · 숫자 · 하이픈만 — 한글 경로에서는 `flutter analyze`가 멈출 수 있음)
- 화면에 보이는 앱 이름: `DayPeek` — `lib/main.dart`(`MaterialApp.title`), `web/index.html` · `web/manifest.json`, Android `android:label`, iOS `CFBundleDisplayName`
- 패키지 이름 `mid_project_template`은 템플릿 권장대로 그대로 둠 (`test/`의 import와 맞춤)

## 1. 실행 방법 — 터미널 2개

준비물: Flutter(Dart SDK ^3.10), Node.js 18 이상.

**터미널 1 — 목업 서버(json-server)**

```bash
cd mock_server
npm install && npm start          # http://localhost:3000  (npm run mock 도 같음)
curl "http://localhost:3000/schedules?date=2026-10-28"  # 확인: 일정 5개 JSON 배열이 나오면 성공
```

**터미널 2 — 앱**

```bash
flutter pub get && flutter run    # 저장소 루트(pubspec.yaml 있는 곳)에서
flutter run -d chrome             # 웹으로 볼 때
```

| 실행 대상 | 앱이 부르는 주소 | 따로 할 일 |
|---|---|---|
| Chrome · macOS · Windows · iOS 시뮬레이터 | `http://localhost:3000` | 없음 |
| **Android 에뮬레이터** | **`http://10.0.2.2:3000`** | 없음 — `lib/api.dart`가 Android면 자동으로 10.0.2.2를 씀 |
| 실기기(같은 Wi-Fi) | PC IP | `flutter run --dart-define=API_BASE=http://192.168.0.10:3000` |
| Vercel 배포(가산) | 배포 주소 | `--dart-define=API_BASE=https://<프로젝트>.vercel.app/api` — `mock_server/README.md` 5장 (아직 배포 안 함) |

- 서버가 꺼져 있으면 앱은 **오류 화면 + "다시 시도"**를 보여 줍니다(서버를 켜고 다시 시도 누르면 달력이 뜸).
- 서버 설정 · `db.json` 구조 · CORS: `mock_server/README.md`.

### 데모 순서 (1분 영상용)

1. 화면 A 2026년 10월 → 28일 칸 `+N개` 배지 (Chrome 개발자 도구 기기 모드 약 400×800에서 보통 글씨 `+3개`)
2. 오른쪽 위 글자 크기 메뉴 → 작게 `+2개` · 크게 `+3개`
3. 28일 칸 또는 배지 누름 → 화면 B 패널이 아래에서 올라옴 → 일정 5개 시간순 · AI 하루 브리핑(예시) 펼치기 · '하루 메모' 탭
4. '팀 프로젝트 회의' 누름 → 화면 C 시트(회의실 B · 준비 메모 · 등록자) → ✕
5. `DEMO_STATE=error`로 오류 + 다시 시도 → 창을 넓혀 넓은 화면 배치

### 상태 화면 시연 — `DEMO_STATE` (발표 · 영상용)

```bash
flutter run --dart-define=DEMO_STATE=loading   # 3초 로딩 (slow 도 같음)
flutter run --dart-define=DEMO_STATE=error     # 오류 + 다시 시도
flutter run --dart-define=DEMO_STATE=empty     # 빈 상태
```

서버 없이도 세 상태를 바로 보여 줄 수 있습니다. `API_BASE`와 함께 써도 됩니다.

## 2. 구조

```
daypeek-v2/
├── README.md                 # 앱 소개 · 실행 방법 [필수]
├── AGENTS.md                 # AI 가드레일 (UI만) — CLAUDE.md는 이 파일을 따른다는 한 줄
├── pubspec.yaml              # 추가 패키지는 http 하나
├── lib/
│   ├── main.dart             # 앱 뼈대 · 테마(흰 바탕 · 브랜드 색) · 화면 흐름 주석
│   ├── api.dart              # GET만 · API_BASE · DEMO_STATE (/schedules · /notes)
│   ├── models.dart           # Schedule(일정) · DayNote(하루 메모) — Dart 3 패턴 fromJson
│   ├── widgets.dart          # LoadingView · ErrorView · EmptyView (+ NetImage)
│   └── screens/
│       ├── a_list_screen.dart    # 화면 A 월간 달력 — GET /schedules?date_like=2026-10, +N개 배지, 600dp 적응형
│       ├── b_detail_screen.dart  # 화면 B 하루 전체 일정 — 아래에서 올라오는 패널, 탭(일정|하루 메모), AI 하루 브리핑(예시)
│       └── c_result_sheet.dart   # 화면 C 일정 상세 — 모달 시트
├── test/widget_test.dart     # 3상태 · +N개 계산(글자 크기별) · push/tab/modal · 적응형 · 넘침 없음 위젯 테스트
├── mock_server/
│   ├── db.json               # [필수] GET 데이터 — schedules 19개(10월, 28일 5개) · notes 3개 (모두 가상)
│   ├── package.json          # json-server 0.17.4 고정
│   ├── api/server.js · vercel.json   # (가산) 읽기 전용 배포
│   └── README.md
└── docs/
    ├── 디자인가이드.md       # 화면 목록 · 원칙 표 · 요소 분석(A-1~A-10 · B-0~B-9 · C-1~C-4) · 가이드 글 · 상태관리 포인트 · 디자인 개선 기록
    ├── 원칙카드.md           # 5칸 양식 (작성 전)
    ├── prompt-log.md         # 4칸 (작성 전)
    ├── 셀프논증.md           # 셀프 논증 기록 (작성 전)
    ├── 자가평가.md           # 공개 배점 40/20/25/15 (작성 전)
    ├── 영상/                 # demo_1min.mp4 · p01.mp4 … (추후)
    └── screenshots/          # README '앱 소개' 스크린샷 (추후)
```

## 3. 화면 목록 ↔ 기획 문서 요소 번호

| 화면 | 이름 (비즈니스 명칭) | 파일 | 전환 | 요소 번호 |
|---|---|---|---|---|
| A | 월간 달력 (`MonthCalendarScreen`) | `lib/screens/a_list_screen.dart` | 첫 화면 | A-1 ~ A-10 |
| B | 하루 전체 일정 (`DayScheduleScreen` · 패널 `DaySchedulePanel`) | `lib/screens/b_detail_screen.dart` | 쌓기(`Navigator.push` + 아래에서 올라오는 `SlideTransition`) · 옆으로(`TabBar`) | B-0 ~ B-9 |
| C | 일정 상세 (`ScheduleDetailSheet`) | `lib/screens/c_result_sheet.dart` | 덮기(`showModalBottomSheet`) | C-1 ~ C-4 |

```
A 월간 달력 ──쌓기(push)──▶ B 하루 전체 일정 [옆으로(tab): 일정 | 하루 메모] ──덮기(modal)──▶ C 일정 상세
```

각 화면 파일 맨 위에 **디자인 가이드 대응표**(번호 · Flutter 위젯명 · 비즈니스 명칭 · 원칙) 주석이 있고, 코드 안에서 같은 번호(`// A-5 P01`)로 찾을 수 있습니다. `docs/디자인가이드.md`와 1:1로 맞춥니다. **가이드에 없는 화면은 만들지 않습니다**(감점).

**상태관리 포인트**는 구현하지 않고 주석으로만 표시합니다(화면 안 표시 변화는 `setState`만): `// STATE: <데이터> → <보여질 위젯>` — 모아 보기 `grep -rn "STATE:" lib`

## 4. 원칙 번호 추적 P01–P10 [권장]

P번호 = 닐슨 원칙 번호. 원칙 카드에 붙인 번호 하나를 다섯 곳에 그대로 씁니다.

| 어디 | 쓰는 법 |
|---|---|
| 디자인 가이드 | `docs/디자인가이드.md` 2장 표 · 요소 분석의 원칙 칸 |
| 코드 주석 | 그 원칙을 보여 주는 위젯 줄 끝: `); // A-5 P01` |
| 커밋 메시지 | `p01: 화면 A 숨겨진 일정 수 배지` |
| 영상 | `docs/영상/p01.mp4` (원칙별 5–10초) |
| 발표 | 원칙 카드 P01 — 시연 칸 = p01.mp4 |

찾기: `grep -rn "P01" lib/` · `git log --oneline --grep="p01"`

## 5. 기준점 Git 태그 `v1-plan` [권장]

템플릿 권장은 화면 기획 확정 직후 `v1-plan` 태그를 붙이는 것입니다. 이 저장소는 화면 구현을 마친 뒤 첫 커밋을 만들었으므로 **`v1-plan` 태그가 없습니다**. 셀프 논증의 전 · 후 비교는 `docs/디자인가이드.md`의 "디자인 개선 기록" 표(실제 코드 변경 기준)와 스크린샷으로 대신합니다.

## 6. 영상 파일 이름

- `docs/영상/demo_1min.mp4` — 전체 흐름 1분 [필수 — 제출물 ①, README "데모" 칸에 링크 · 배포 URL로 대신 가능] — 위 "데모 순서" 참고 (추후 녹화)
- `docs/영상/p01.mp4`, `p03.mp4`, `p10.mp4` … — 원칙별 5–10초 클립 [권장], 원칙 카드 번호와 같게
- 녹화 전: 개인정보 · 알림이 화면에 보이지 않는지 확인. GitHub는 100MB가 넘는 파일을 받지 않으니 큰 영상은 LMS · 드라이브 링크로 README "데모" 칸에 적습니다.

## 7. 감점 점검 (제출 전, 결과가 비어 있어야 함)

```bash
grep -rnE "http\.(post|put|patch|delete)|SharedPreferences|sqflite|hive|FirebaseAuth|ChangeNotifierProvider|Riverpod|BlocProvider" lib/ pubspec.yaml
```

- `lib/` 결과는 비어 있습니다. `pubspec.yaml`은 템플릿 주석 URL의 `Archive` 글자에 `hive`가 걸리는 오탐 한 줄만 나옵니다(패키지 아님).
- 검색은 이름만 찾으므로 화면을 직접 눌러 보며 실제로 저장 · 전송되는 곳이 없는지도 확인합니다. 자세한 점검: `docs/자가평가.md`.

## 8. 제출 전 clone 테스트 [필수 확인]

1. 새 폴더에 받기: `git clone https://github.com/roykim1203/daypeek-v2.git clone-test`
2. 터미널 1: `cd clone-test/mock_server && npm install && npm start`
3. 서버 확인: `curl "http://localhost:3000/schedules?date=2026-10-28"` (일정 5개)
4. 터미널 2: `cd clone-test && flutter pub get`
5. 실행: `flutter run -d chrome` (Android 에뮬레이터는 그냥 `flutter run`)
6. 화면 전환 · GET 달력 · 로딩/오류/빈 상태(`DEMO_STATE`) · 넓은 화면(창 크기 늘리기) 확인 → 안 되면 README를 고치고 1부터 다시

## 9. 제출물 2종 체크 (LMS, 10/29(목) 15:00 전 — 각자 제출)

- [ ] ① **데모 시연 + 코드** — GitHub 저장소 URL — **clone 테스트 통과**
  - [x] Flutter 코드 + `mock_server/db.json`
  - [ ] README — 앱 소개 8칸(스크린샷 · 리뷰 칸 원본 삽입 필요) · 실행 방법 · **데모 영상 1분 링크 또는 배포 URL**
  - [ ] `docs/` — 디자인 가이드(작성됨) · 원칙 카드 · prompt-log · **셀프 논증 기록** · 자가평가 (작성 필요)
- [ ] ② **발표자료** — `mid-project-presentation-template` 사용(PPTX 또는 PDF, 6분 발표 + 2분 질의)
  - [ ] 본문 7장 + 부록 B1 데모 · 스크린샷 · B2 원칙 카드 · B3 prompt-log · B4 자가평가 · **B5 기획 상세**(사업 요약 · 저니 · 피쉬본/5 Why · 화면별 요소 분석표 · 상태관리 포인트)

## 10. 확인된 상태 (첫 업로드 시점, Windows · Flutter SDK `C:\dev\flutter`)

```bash
flutter analyze   # No issues found!
flutter test      # 24개 통과: 3상태 · +N개(보통 +3개 · 작게 +2개 · 크게 +3개, 0·2·7개 날) · 오늘/선택 표시
                  #           · A→B 패널(닫기 4가지) · 탭 · AI 하루 브리핑(예시)과 db.json 일치 · B→C 시트(✕·뒤로·Esc)
                  #           · 320dp + 글자 1.3배 넘침 없음 · 600dp 넓은 화면
flutter build web # 성공
```

- Windows 사용자 폴더 이름에 한글이 있으면 `flutter test`가 "Connection closed before test suite loaded"로 멈출 수 있습니다. 임시 폴더를 영문 경로로 바꿔 실행하면 됩니다(PowerShell: `$env:TEMP='C:\dev\daypeek-v2\build\test_tmp'; $env:TMP=$env:TEMP; flutter test`).
- `pubspec.yaml` 의존성: `flutter`, `cupertino_icons`, `http`뿐. 플랫폼 설정: Android 디버그 빌드 평문 HTTP 허용(`android/app/src/debug/AndroidManifest.xml`), macOS 나가는 네트워크 허용(`macos/Runner/*.entitlements`).
