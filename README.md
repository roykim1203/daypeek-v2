# DayPeek — TimeTree v2 · GAI3008 중간프로젝트 저장소 (1인 1팀)

## 앱 소개

> 앱스토어 상품 페이지처럼 채웁니다. 칸 이름과 순서는 발표 자료의 "앱 소개" 장과 같습니다 — 바꾸지 않습니다.
> **표시 규칙**: 아직 원본을 확인해 넣지 못한 칸은 `[원본 증거 삽입 필요]`로 둡니다. 확인하지 않은 리뷰 · 별점 · 날짜는 쓰지 않습니다.

### 앱 이름
DayPeek (TimeTree v2)

### 부제
월간 달력에 숨은 일정까지 몇 개인지 바로 보이는 공유 캘린더

### 카테고리
생산성

### 대상 사용자 / 사용 상황
- 대상 사용자: 가족 · 팀 · 스터디와 공유 캘린더를 쓰며 하루에 일정이 여러 개 겹치는 사용자 (가상 퍼소나 "민지" — `docs/기획.md` 3장)
- 사용 상황: 휴대폰에서 월간 달력을 훑어보며 "오늘·이번 주 바쁜 날"을 확인할 때

### 스크린샷
이미지는 `docs/screenshots/`. 왼쪽부터 v1(현행 TimeTree) → v2(DayPeek).

| v1 현행 — 월간 | v1 현행 — 날짜 선택 | v2 화면 A | v2 화면 B | v2 화면 C |
|---|---|---|---|---|
| ![v1 월간](<docs/screenshots/일정 5개 중 3개가 보이는 모습.jpg>) | ![v1 날짜 선택](<docs/screenshots/실제 TimeTree 날짜 선택 화면.jpg>) | ![v2 A](<docs/screenshots/화면 A.png>) | ![v2 B](<docs/screenshots/화면 B 하루 브리핑 제공.png>) | ![v2 C](<docs/screenshots/화면 C.png>) |
| 사례 B(2026-10-29): 29일 칸에 일정 3개만, 숨은 수 숫자 없음 ([글자가 더 큰 캡처: 2개](<docs/screenshots/글자를 키웠을 때 2개만 보이는 모습.jpg>)) | 날짜를 선택해야 일정 6개 전체 확인 | 28일 칸 2개 + `+3개 ›`, 20일 2개 + `+5개 ›`, 다 보이는 날은 배지 없음 | 하루 일정 패널 — AI 하루 브리핑(예시) 펼침 · 5개 시간순 ([접힌 상태](<docs/screenshots/화면 B.png>)) | 일정 상세 — 팀 캘린더 · 등록: 팀원 A · 시간 · 회의실 B · 일정 메모 |

- 현행 캡처는 **사례 B**(실제 TimeTree, 2026-10-29, 일정 6개 — 두 월간 캡처의 글자 크기 설정 이름은 캡처에 없음)입니다. 아래 "설명"의 2026-10-28 · 5개는 **사례 A**(기존 직접 테스트 기록, 캡처 없음)로 별개의 테스트입니다(`docs/기획.md` 1-2).
- DayPeek 캡처는 **가상 데이터(2026-10-28, 일정 5개)를 쓰는 별도 시연**이며 TimeTree 실제 데이터를 불러온 것이 아닙니다 — 같은 조건의 나란한 비교는 아닙니다.
- 넓은 화면(600dp 이상) 캡처: [원본 증거 삽입 필요]

### 설명
1. **무엇을 하는가**: 공유 캘린더 TimeTree의 v2 UI 프로토타입입니다. 월간 달력(A) → 하루 전체 일정(B) → 일정 상세(C) 흐름을 Flutter로 구현했고, 데이터는 로컬 json-server에서 **GET으로만** 가져옵니다.
2. **v2가 해결하는 문제**: 현행 앱은 같은 날짜에 일정이 많으면 월간 달력에 일부 제목만 보이고, 숨겨진 일정이 몇 개인지 알려 주지 않습니다. 작성자의 기존 직접 테스트 기록(사례 A: 2026-10-28, 같은 날짜에 일정 5개 등록, 캡처 없음)에서 월간 화면에 글자 크기 '작게' 3개, '보통' 2개, '아주 크게' 2개의 제목만 보였고, 날짜를 선택하면 5개를 모두 확인할 수 있었습니다(작성자 기기의 특정 환경). 별도로 확보한 실제 스크린샷(사례 B: 2026-10-29, 일정 6개)에서도 월간 칸에 3개 · 글자가 더 큰 캡처에서 2개만 보이고, 날짜를 선택해야 6개가 모두 보입니다. 데이터 누락이 아니라 숨겨진 일정 수를 알기 어려운 UX 문제입니다. Google Play 리뷰에도 같은 불편이 있습니다 — "하루 일정표가 4개를 넘어가면 날짜를 눌러서 확인하기 전까지는 모르겠더라고요 … 옆에 작게 +2 이런식으로라도 알려주면 훨씬 편할 것 같아요"(★5, 2026-06-21).
3. **v2의 핵심 가치**: 날짜를 누르기 전에 "이 날 일정이 몇 개 더 있는지"를 `+N개`로 바로 알 수 있고, 누르면 그날 일정 전체를 시간순으로 빠짐없이 봅니다.

### 새로운 기능
v2에서 바뀐 것 3개 — 원칙 카드(`docs/원칙카드.md`)의 P번호와 연결합니다.

| P번호 | 바뀐 것 (화면 · 요소 번호) | 근거 (리뷰 · 원칙) |
|---|---|---|
| P01 | 화면 A · A-5 숨겨진 일정 수 표시 `+N개` (원칙 카드 P01) — 칸 높이 · 글자 크기로 들어가는 일정 수를 정하고, 배지 자리를 먼저 확보해 잘림·겹침 없음. 누르면 B로 | 직접 테스트(일부만 보이고 숨은 개수 안내 없음) · Google Play 리뷰 "옆에 작게 +2 이런식으로라도 알려주면"(★5, 2026-06-21) · 닐슨 1 시스템 상태의 가시성 |
| P03 | 화면 B · B-0 하루 일정 패널 — 아래에서 올라오고 뒤의 달력이 보임. ✕ · 뒤로 · 아래로 끌기 · 바깥 누르기로 닫힘 | 닐슨 3 사용자 통제와 자유 |
| P10 | 화면 B · B-9 AI 하루 브리핑(예시) — 하루 전체 개수와 오전·오후·저녁 흐름. 미리 작성된 시연용 문장이며 실제 AI 호출 없음을 화면에 표시 | 닐슨 10 도움말과 문서 (예시임을 밝힘) · AI 활용 기회 |

### 평가 및 리뷰
| 항목 | 내용 |
|---|---|
| 현행 별점 | ★ **4.8** (Google Play, '전화' 탭) — [캡처](<docs/screenshots/평점 및 별점 분포.png>) · 별점별 비율 숫자는 화면에 없어 미기재 |
| 리뷰 수 | **23.6만개** (같은 캡처) |
| 대표 리뷰 | "같은날에 여러 일정이 있을 때 한개만 표시됩니다. 여러 줄로 다 표시가 되게 하려면 어떻게해야하나요?" — ★5 · 2026-09-18 (**작성자 이름 지움**) · 리뷰 5건 분석은 `docs/기획.md` 1-5 |
| 출처 | Google Play 리뷰 캡처 4장(리뷰 5건) — 작성자 이름 · 프로필 사진을 가린 공개용 사본 [1](docs/screenshots/public/review1_public.png) · [2](docs/screenshots/public/review2_public.png) · [3](docs/screenshots/public/review3_public.png) · [4](docs/screenshots/public/review4_public.png) (원본은 로컬 보존, 저장소 제외) · 스토어 링크 · 캡처 날짜 [원본 증거 삽입 필요] |

---

## 작성자 · 제출 정보

| 칸 | 내용 |
|---|---|
| 현행 앱 | TimeTree (스토어 링크 추후 삽입) |
| v2 한 문장 | 월간 달력에서 숨겨진 일정 수를 `+N개`로 보여 주고, 하루 전체 일정을 한 번에 펼쳐 보는 TimeTree v2 |
| 작성자 | 김하람 · 1인 1팀 |
| 저장소 | https://github.com/roykim1203/daypeek-v2 |
| 데모 | **시연 영상 1분 (Google Drive)**: https://drive.google.com/file/d/1vFoFhKfgWuUBk7tnHAw2vh5rPVyGlLcb/view?usp=sharing · 영상 파일(약 6.1MB)은 저장소에 올리지 않고 Drive 링크로 제출 (**제출물 ①**) |
| AI 사용 | Claude Code(Claude Opus 5.5) · 규칙 `AGENTS.md` · 기록 `docs/prompt-log.md`(1~18행) · 셀프 논증 기록 `docs/셀프논증.md`(사용성 중심 쟁점 5개 + 부록 'AI 코드 제안 비판적 검증', 재반론 · 배운 점은 작성자 직접 작성) |
| 기획 문서 | `docs/기획.md` — 현행 분석 · 사업 요약 · 퍼소나 · 저니 · 피쉬본 · 5 Why · 핵심 문제와 개선 근거 (리뷰 · 캡처 원본 삽입 필요) |

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
2. 오른쪽 위 글자 크기 메뉴(DayPeek 자체 3단계) → 작게 `+2개` · 크게 `+3개`
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
    ├── 기획.md               # 현행 분석 · 리뷰 4유형 틀 · 사업 요약 · 퍼소나 · 저니 · 피쉬본 6관점 · 5 Why · 핵심 문제와 개선 근거
    ├── 디자인가이드.md       # 화면 목록 · 원칙 표 · 요소 분석(A-1~A-10 · B-0~B-9 · C-1~C-4) · 가이드 글 · 상태관리 포인트 · 디자인 개선 기록
    ├── 원칙카드.md           # 닐슨 원칙 카드 P01 · P03 · P04 · P06 · P07 · P09 · P10 (+ 해당 없음 P05)
    ├── prompt-log.md         # 개발 세션 요청 · AI 결과 · 판단 · 이유 (1~18행)
    ├── 셀프논증.md           # 쟁점 5개(+N개 · 글자 크기 · AI 브리핑 · 하단 패널 · 디자인) + 부록: 주장 → AI 반론 → 재반론 · 수정 → 결정 → 원칙 · 근거 · 전후 화면
    ├── 자가평가.md           # 공개 배점 40/20/25/15 — 항목별 근거 · 상태 · 남은 일
    ├── 영상/                 # (저장소에 없음) 데모 영상은 로컬 보관 · Drive 링크로 제출 — 원칙별 클립 p01.mp4 … 은 미제작
    └── screenshots/          # 현행 TimeTree 사례 B 캡처(월간 3개 · 2개 · 날짜 선택) · 평점 · DayPeek 화면 A · B · B 브리핑 · C
        └── public/           # Google Play 리뷰 4장 공개용 사본(작성자 이름 · 프로필 사진 가림)
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

- `데모 영상 1분.mp4` — 전체 흐름 1분 [필수 — 제출물 ①] — 작성자가 녹화한 파일(약 6.1MB). `.gitignore`로 저장소에서 제외하고, 시청은 README "데모" 칸의 Google Drive 링크로 합니다.
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

- Windows PowerShell 5.1에서는 `&&`를 쓸 수 없습니다 — `cd clone-test/mock_server; npm install; npm start`처럼 `;`로 나누거나 한 줄씩 실행합니다(Git Bash · PowerShell 7 · cmd는 `&&` 그대로 가능).
- clone 테스트는 **최신 문서 · 이미지를 push한 뒤**에 합니다.
- 리뷰 원본 캡처와 데모 영상 파일은 저장소에서 제외되어 clone에 없습니다 — 문서는 `docs/screenshots/public/`의 공개용 사본만 링크하고, 영상은 Drive 링크로 봅니다.

## 9. 제출물 2종 체크 (LMS, 10/29(목) 15:00 전 — 각자 제출)

- [ ] ① **데모 시연 + 코드** — GitHub 저장소 URL — **clone 테스트 통과**
  - [x] Flutter 코드 + `mock_server/db.json`
  - [ ] README — 앱 소개 8칸(스크린샷 · 평점 · 리뷰 반영됨, 스토어 링크 · 넓은 화면 캡처 남음) · 실행 방법 · **데모 영상 1분** (Google Drive 공유 링크 입력됨 — 영상 파일은 저장소에서 제외)
  - [ ] `docs/` — 기획 · 디자인 가이드 · 원칙 카드 · prompt-log · **셀프 논증 기록** · 자가평가 (작성됨 — 셀프 논증 작성자 이름 입력 완료 · 남은 증거(스토어 링크 · 캡처 날짜 등)는 `docs/자가평가.md` "제출 전 남은 일")
- [x] ② **발표자료** — `mid-project-presentation-template` 사용(PPTX 또는 PDF, 6분 발표 + 2분 질의) — 제작 완료(작성자 보고, 파일은 저장소 밖) · LMS 제출 · 리허설 시간 기록은 작성자 확인
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
