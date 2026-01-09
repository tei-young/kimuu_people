# KIMUU Schedule

KIMUU 뷰티샵(반영구 화장 전문)의 원장님들을 위한 내부용 스케줄 관리 iOS 앱입니다.

## 개요

뷰티샵 내 여러 원장님(샵인샵 형태로 공간을 공유하는 입주 원장님 포함)의 스케줄을 한눈에 확인하고 관리할 수 있는 앱입니다.

### 타겟 사용자

| 역할 | 인원 | 권한 |
|------|------|------|
| Admin | 1명 | 모든 일정 CRUD + 계정 관리 |
| 원장님 | 3~4명 (최대 6명) | 본인 일정 CRUD + 타 원장 일정 열람 |

## 기술 스택

| 영역 | 기술 |
|------|------|
| 플랫폼 | iOS 16.0+ |
| 언어 | Swift 5.9 |
| UI | SwiftUI |
| 아키텍처 | MVVM |
| 백엔드 | Supabase (PostgreSQL + Auth) |

## 프로젝트 구조

```
ios/KimuuSchedule/
├── App/
│   └── KimuuScheduleApp.swift       # 앱 진입점
├── Models/
│   ├── User.swift                   # 원장 모델
│   ├── Appointment.swift            # 일정 모델
│   └── Customer.swift               # 고객 모델
├── ViewModels/
│   ├── AuthViewModel.swift          # 인증
│   ├── CalendarViewModel.swift      # 캘린더 상태
│   ├── AppointmentViewModel.swift   # 일정 CRUD
│   └── SettingsViewModel.swift      # 설정
├── Views/
│   ├── Auth/                        # 로그인
│   ├── Calendar/                    # 월별/일별 캘린더
│   ├── Appointment/                 # 일정 폼/상세
│   └── Settings/                    # 설정 화면들
├── Services/
│   └── SupabaseService.swift        # Supabase 클라이언트
└── Utils/
    ├── Constants.swift              # 상수
    └── Extensions.swift             # 유틸리티 확장
```

## 주요 기능

### 1. 인증
- Supabase Auth 기반 이메일/비밀번호 로그인
- 자동 세션 복구

### 2. 월별 캘린더
- 좌우 스와이프로 월 이동
- 일정 있는 날짜에 원장별 **색상 도트** 표시
- 날짜 탭 시 일별 상세 캘린더로 이동

### 3. 일별 상세 캘린더
- **열(Column)**: 원장별 구분 (최대 4열, 5명 이상 시 필터/스와이프)
- **행(Row)**: 24시간 타임라인 (진입 시 오전 9시로 스크롤)
- **시간 단위 전환**: 1시간 ↔ 30분 ↔ 10분 (Pinch-Zoom 또는 메뉴)
- **원장 필터**: 표시할 원장 선택 가능

### 4. 일정 관리
- **추가**: 빈 시간 영역 탭 → 일정 추가 폼
- **조회**: 일정 블럭 탭 → 상세 보기
- **수정/삭제**: 본인 일정 또는 Admin만 가능
- **중복 체크**: 동일 원장의 시간 겹침 방지
- **다중 고객**: 한 일정에 여러 고객 등록 가능

### 5. 설정
- **개인 색상**: 12색 팔레트 중 선택 (중복 불가)
- **시술 종류**: 추가/삭제/순서 변경/수정

## 데이터 모델

### User (원장)
```swift
struct User {
    let id: UUID
    let email: String
    let displayName: String      // 표시명
    var color: String            // HEX 색상 (캘린더 구분용)
    let isAdmin: Bool
    var treatmentTypes: [String] // 시술 종류 목록
}
```

### Appointment (일정)
```swift
struct Appointment {
    let id: UUID
    let userId: UUID              // 담당 원장
    var customers: [CustomerInfo] // 고객 정보 (다중)
    var treatmentType: String     // 시술 종류
    var startTime: Date
    var endTime: Date
    var memo: String?
}
```

## 앱 흐름

```
[로그인] → [메인 탭뷰]
              │
              ├── [캘린더 탭]
              │       └── 월별 캘린더 → 일별 상세 → 일정 추가/조회/수정
              │
              └── [설정 탭]
                      └── 색상 설정 / 시술 종류 관리 / 로그아웃
```

## 설치 및 실행

### 요구사항
- Xcode 15.0+
- iOS 16.0+

### 빌드
1. `ios/` 디렉토리에서 `KimuuSchedule.xcodeproj` 열기
2. Signing & Capabilities에서 Development Team 설정
3. 빌드 및 실행

### Supabase 설정
Supabase 프로젝트 연동 정보는 `Constants.swift`에 정의되어 있습니다:
```swift
enum Supabase {
    static let url = URL(string: "https://...")!
    static let anonKey = "..."
}
```

데이터베이스 스키마는 `supabase/migrations/` 폴더의 SQL 파일을 참고하세요.

## 색상 팔레트

원장별 구분을 위한 12색:

| 색상 | HEX |
|------|-----|
| 코랄 레드 | `#FF6B6B` |
| 틸 | `#4ECDC4` |
| 스카이 블루 | `#45B7D1` |
| 민트 | `#96CEB4` |
| 레몬 | `#FFEAA7` |
| 플럼 | `#DDA0DD` |
| 아쿠아 | `#98D8C8` |
| 골드 | `#F7DC6F` |
| 라벤더 | `#BB8FCE` |
| 파스텔 블루 | `#85C1E9` |
| 앰버 | `#F8B500` |
| 라이트 그린 | `#82E0AA` |

## 참고 문서

- 기획서: `docs/PLANNING.md`
- DB 스키마: `supabase/migrations/001_initial_schema.sql`
- DB 스키마는 migrations/ 하위 sql 파일을 모두 run 한 상태임
