# Planner Desktop

Flutter로 만든 데스크탑 플래너 앱입니다.
월간 캘린더, 원형 시간표, 체크리스트를 한 화면에서 관리할 수 있습니다.

---

## 주요 기능

### 홈 (월간 캘린더)
- 월별 캘린더에서 일정을 한눈에 확인
- 날짜 클릭 시 오른쪽 패널에 해당 날짜의 상세 정보 표시
- 일정 추가 시 시작/종료 시간, 색상 지정 가능
- 날짜별 메모 작성

### 체크리스트
- **전역 체크리스트**: 매일 반복되는 루틴 항목 관리 (예: 물 마시기, 운동)
- **날짜별 체크리스트**: 특정 날짜에만 필요한 항목 추가
- 전역 항목의 완료 여부는 날짜마다 독립적으로 기록

### 주간 원형 시간표
- 요일별 원형 타임테이블로 주간 루틴 시각화
- 각 요일에 항목 추가/삭제

### 설정
- **언어**: 한국어 / English
- **테마**: 라이트 / 다크 / 시스템
- **타임존**: 서울, 도쿄, 뉴욕, 런던 등 주요 도시 선택 가능

---

## 기술 스택

| 항목 | 내용 |
|------|------|
| Framework | Flutter 3.x (Dart) |
| UI | Material 3 |
| 상태 관리 | `ChangeNotifier` |
| 패키지 | `timezone` |
| 지원 플랫폼 | Windows · macOS · Linux · Android · iOS · Web |

---

## 실행 방법

### 요구 사항
- Flutter SDK `^3.5.3`

### 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 데스크탑 앱 실행 (Windows 기준)
flutter run -d windows

# 다른 플랫폼
flutter run -d macos
flutter run -d linux
```

### 빌드

```bash
# Windows 릴리즈 빌드
flutter build windows --release
```

---

## 프로젝트 구조

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── app_state.dart        # 전역 상태 관리
│   ├── app_theme.dart        # 라이트/다크 테마 정의
│   └── app_strings.dart      # 다국어 텍스트
├── models/
│   ├── planner_item.dart     # 일정 데이터 모델
│   ├── checklist_item.dart   # 체크리스트 항목 모델
│   └── circle_schedule_item.dart  # 원형 시간표 항목 모델
├── screens/
│   ├── main_shell.dart       # 네비게이션 쉘
│   ├── home_screen.dart      # 월간 캘린더 화면
│   ├── checklist_screen.dart # 체크리스트 화면
│   ├── weekly_screen.dart    # 주간 원형 시간표 화면
│   └── settings_screen.dart  # 설정 화면
├── widgets/
│   ├── month_calendar.dart           # 월간 캘린더 위젯
│   ├── day_detail_panel.dart         # 일정 상세 패널
│   ├── circular_day_timetable.dart   # 원형 타임테이블
│   ├── weekly_circle_panel.dart      # 주간 원형 패널
│   ├── global_checklist_panel.dart   # 전역 체크리스트 패널
│   ├── planner_clock_time_picker.dart # 시간 선택 위젯
│   ├── custom_color_picker_dialog.dart # 색상 선택 다이얼로그
│   └── month_picker_dialog.dart      # 월 선택 다이얼로그
└── utils/
    └── date_utils.dart       # 날짜 유틸리티
```
