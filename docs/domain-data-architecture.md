# Domain / Data 계층 설계

> 기준 계약: **`~/Desktop/Anywhere_server`의 실제 구현**(`src/routes`, `src/controllers`, `src/services`, `prisma/schema.prisma`).
> Swagger(`src/config/swagger.ts`, version 1.2.0)는 참고용이다 — 과거에 문서와 구현이 어긋난 전례가 있어 **소스가 우선**이다.
> 최종 대조: 2026-08-18 (서버를 띄워 24개 엔드포인트 응답을 실측).

## Context

디자인 시스템(UIComponents)과 소셜 로그인(Auth) 위에 서버 통신 계층을 얹는다. 목표는 서버가 제공하는 **24개 오퍼레이션 전부**를 Entity / Repository 프로토콜 / UseCase(Domain)와 구현체·통신 계층(Data)으로 덮는 것이다. 화면(Presentation)은 아직 비어 있으므로 이 계층이 유일한 소비자 없는 상태에서 확정된다.

---

## 확정한 설계 결정

**1. 통신은 `BaseAPI` 프로토콜 + 기능별 enum으로 정의한다.**
Moya `TargetType` 스타일. 엔드포인트 하나가 enum case 하나가 되고, **path parameter는 문자열 보간이 아니라 별도 딕셔너리로 선언해 URL 빌더가 치환**한다. `path`를 서버 라우트의 경로 템플릿과 글자 그대로 같게 유지할 수 있어 대조가 쉽다.

**2. 통신 계층은 Data 안에 둔다. Core는 건드리지 않는다.**
`DependencyInfo.swift`가 `.domain: [.core]`이므로 Core에 URLSession·Keychain을 넣으면 Domain이 인프라 모듈을 링크하게 된다.

**3. 전송 계층 에러는 Data 밖으로 나가지 않는다.**
Domain이 자기 에러(`MatchError`, `CheckInError`, `AuthError`, `ProfileError`, `ReviewError`)를 정의하고, Data의 Repository 구현체가 경계에서 HTTP 상태코드를 도메인 에러로 **번역**한다.

**4. 로그인은 `idToken`을 보낸다 — `socialId`가 아니다.**
서버는 `google-auth-library`/Apple JWKS로 **idToken을 직접 검증**하고, 거기서 나온 `sub`만 socialId로 신뢰한다(`auth.service.ts`, `utils/googleAuth.ts`, `utils/appleAuth.ts`). 클라이언트가 보낸 socialId는 아예 읽지 않는다. 그래서 `SocialSignInResult`/`SocialCredential`이 나르는 값은 idToken이다.
- google: `GIDGoogleUser.idToken.tokenString` — 서버 `GOOGLE_CLIENT_ID`가 iOS 클라이언트 ID와 같아야 검증을 통과한다(audience 검사).
- apple: `ASAuthorizationAppleIDCredential.identityToken` — 서버 `APPLE_CLIENT_ID`가 앱 번들 ID와 같아야 한다.
Firebase 로그인 흐름 자체는 유지한다. Firebase 세션은 앱 내부용이고, 서버는 Firebase를 모른다.

**5. 위치는 Domain 프로토콜 + Data 구현** — Domain에 `Coordinate`와 `LocationRepository`, Data에 CoreLocation 구현. 좌표가 필요한 UseCase(`FetchRandomMatch`, `CheckIn`)가 스스로 좌표를 확보한다.

**6. "내 여권"도 내 userId로 조회한다.** 서버에 `/api/passport` (나 전용) 경로는 없다. `GET /api/passport/{userId}` 하나뿐이다.

**7. 뱃지에 "수집(claim)" API는 없다.** 로컬 히든 뱃지는 **체크인 시 서버가 반경 판정으로 자동 지급**하고(`mission.service.ts: awardHiddenBadges`), 응답의 `newBadges`로 알려준다. 조회는 `/api/badges/me`, `/api/badges/seasonal`.

---

## 의존 방향

```
AnywhereApp ──▶ DIContainer ──▶ Presentation ──▶ ┐
                    │                            │
                    ├──▶ Data ───────────────────┼──▶ Domain
                    └──▶ Auth                    ┘
```

| 규칙 | 이유 |
|---|---|
| Domain에 `import UIKit / CoreLocation / Firebase` 금지 | 프레임워크 무지 |
| Repository 프로토콜은 Domain 에러만 던진다 | 전송 세부가 안으로 새지 않도록 |
| DTO는 Data 밖으로 나가지 않는다 | 서버 스키마 변경이 Domain을 흔들지 않도록 |
| 권한 상태는 Domain의 `LocationAuthorization`으로 표현 | `CLAuthorizationStatus` 누출 차단 |
| `SocialAuthenticating`에 `UIViewController` 금지 | presenting 책임은 DIContainer 어댑터가 흡수 |

---

## 엔드포인트 ↔ 구현 매핑

| 서버 | API enum | Repository | UseCase |
|---|---|---|---|
| `POST /api/auth/login` | `AuthAPI.login` | `AuthRepository` | `SignInUseCase` |
| `GET /api/users/me` | `UserAPI.me` | `UserRepository` | `FetchMyProfileUseCase`, `RestoreSessionUseCase` |
| `GET /api/users/me/stats` | `UserAPI.stats` | `UserRepository` | `FetchProfileStatsUseCase` |
| `PATCH /api/users/me` | `UserAPI.updateProfile` | `UserRepository` | `UpdateProfileUseCase` |
| `PATCH /api/users/me/settings` | `UserAPI.updateSettings` | `UserRepository` | `UpdateSettingsUseCase` |
| `GET /api/users/{id}/detail` | `UserAPI.detail` | `UserRepository` | `FetchRankerDetailUseCase` |
| `GET /api/match/random` | `MatchAPI.random` | `MatchRepository` | `FetchRandomMatchUseCase` |
| `GET /api/match/current` | `MatchAPI.current` | `MatchRepository` | `FetchCurrentTripUseCase` |
| `POST /api/match/{id}/confirm` | `MatchAPI.confirm` | `MatchRepository` | `ConfirmMatchUseCase` |
| `POST /api/match/{id}/cancel` | `MatchAPI.cancel` | `MatchRepository` | `CancelMatchUseCase` |
| `POST /api/mission/check-in` | `MissionAPI.checkIn` | `MissionRepository` | `CheckInUseCase` |
| `GET /api/passport/{userId}` | `PassportAPI.detail` | `PassportRepository` | `FetchPassportUseCase` |
| `GET /api/ranking/users` | `RankingAPI.users` | `RankingRepository` | `FetchUserRankingUseCase` |
| `GET /api/ranking/places` | `RankingAPI.places` | `RankingRepository` | `FetchPlaceRankingUseCase` |
| `GET /api/ranking/me` | `RankingAPI.me` | `RankingRepository` | `FetchMyRankUseCase` |
| `GET /api/feed/recent` | `FeedAPI.recent` | `FeedRepository` | `FetchRecentFeedUseCase` |
| `GET /api/badges/me` | `BadgeAPI.mine` | `BadgeRepository` | `FetchMyBadgesUseCase` |
| `GET /api/badges/seasonal` | `BadgeAPI.seasonal` | `BadgeRepository` | `FetchSeasonalBadgesUseCase` |
| `GET /api/regions/growth` | `RegionAPI.growth` | `RegionRepository` | `FetchGrowthRegionsUseCase` |
| `GET /api/regions/{id}` | `RegionAPI.detail` | `RegionRepository` | `FetchRegionDetailUseCase` |
| `GET /api/tags` | `TagAPI.list` | `TagRepository` | `FetchCurationTagsUseCase` |
| `GET /api/tags/{id}/places` | `TagAPI.places` | `TagRepository` | `FetchPlacesByTagUseCase` |
| `POST /api/reviews` | `ReviewAPI.create` | `ReviewRepository` | `CreateReviewUseCase` |
| `GET /api/reviews/places/{id}` | `ReviewAPI.byPlace` | `ReviewRepository` | `FetchPlaceReviewsUseCase` |
| `GET /api/app/info` | `AppAPI.info` | `AppRepository` | `FetchAppInfoUseCase` |

인증이 필요한 엔드포인트는 `AuthorizationPolicy.required`, 공개 엔드포인트는 `.none`이다. 서버에 optional auth 경로는 없다.

---

## API 계약에서 반드시 지켜야 할 함정

**① 날짜에 소수점 초가 있다.** `2026-08-18T13:48:56.913Z` 형태다. `.iso8601` 기본 전략은 이걸 못 읽으므로 `.withFractionalSeconds`를 켠 `.custom` 전략을 쓴다. → `Data/Network/JSONCoder.swift`

**② `mapX`는 경도, `mapY`는 위도다.** 이름 순서가 관례와 반대다(`schema.prisma`). Mapper에서 `Coordinate(latitude: mapY, longitude: mapX)`로 뒤집고, 그 뒤로는 `Coordinate`만 쓴다.

**③ 신규 가입 여부는 HTTP 상태코드로만 알 수 있다.** `POST /api/auth/login`은 신규 201, 기존 200을 주는데 `isNewUser`가 본문에 없다. `HTTPClient`가 상태코드를 함께 돌려주고 `AuthRepositoryImpl`이 `AuthSession.isNewUser`로 바꿔 담는다.

**④ check-in만 envelope이 다르다.** 다른 API는 전부 `data`로 감싸는데 check-in은 `{success, message, stamp, newBadges}`가 최상위다. 실패 시 `stamp`가 아예 없고 HTTP 400으로 온다.

**⑤ 400 에러는 한국어 메시지로만 구분된다.** 문자열 파싱으로 분기하지 않고 `rejected(message:)`로 담아 **그대로 사용자에게 노출**한다. 429(일일 매칭 3회 초과)와 404는 상태코드로 구분되니 별도 case로 번역한다.

**⑥ `GET /api/match/current`는 `data: null`을 준다.** 진행 중인 여정이 없을 때다. `APIResponse<CurrentTripDTO?>`로 받아 옵셔널로 흘린다.

**⑦ `dash`/`stats`의 `value`는 숫자로도 문자열로도 온다.** (`users/{id}/detail`의 `{"label":"총 도장","value":0}`와 `{"label":"레벨","value":"Lv.1"}`) 표시용 값이므로 `LabeledValueDTO`가 문자열로 통일한다.

**⑧ `socialType`은 enum으로 강제 변환하지 않는다.** DB에 과거 `"kakao"` 값이 남아 있다. 서버가 새로 받는 값은 `apple`/`google`뿐이지만, 조회 응답에는 옛 값이 그대로 실려 오므로 Entity는 서버 원문 문자열을 보관한다.

---

## 알면서 감수하는 트레이드오프

**Entity가 서버 렌더링 문구를 담는다.** `FeedItem.message`, `RegionDetail.remainLabel`/`progressLabel`, `LabeledValue`, `levelLabel`은 서버가 만든 표시용 한국어 문자열이다. 걷어내면 서버의 계산 로직(방문자 순번, 레벨업 잔여 인원, 레벨 라벨)을 클라이언트에서 중복 구현해야 하므로 그대로 둔다.

---

## Info.plist 확인 사항 (`Tuist/Config/Info.plist`)

- **`NSLocationWhenInUseUsageDescription`** — CoreLocation 사용 시 필수.
- **`NSAppTransportSecurity` → `NSAllowsLocalNetworking`** — 개발 서버가 `http://localhost:3000`이라 ATS에 막힌다. 전면 허용은 쓰지 않는다.

`baseURL`은 `APIConfiguration`으로 주입한다. 시뮬레이터는 `localhost`, 실기기는 맥의 LAN IP가 필요하다.

---

## 검증 상태 (2026-08-18)

**완료**
- `DataDebug` / `DIContainerDebug` 스킴 컴파일 통과 (Swift 6 strict concurrency)
- 로컬 서버 기동 후 **13개 엔드포인트 실응답을 DTO로 디코딩** — `app/info`, `tags`, `feed/recent`, `ranking/users`, `ranking/me`, `regions/growth`, `regions/{id}`, `users/me`, `users/me/stats`, `users/{id}/detail`, `badges/me`, `match/current`(`data: null`), `passport/{userId}`
- 데이터가 없어 실응답을 못 받은 6개(`match/random`, `match/confirm`, `check-in` 성공/실패, `reviews`, `tags/{id}/places`, 히든 뱃지)는 **서버 서비스의 반환 타입대로 만든 픽스처**로 디코딩 확인
- **URL 빌더 전수 확인** — 25개 케이스의 method·path·쿼리 조립이 서버 라우트와 일치, 토큰 없는 `.required` 요청은 `unauthorized`로 차단

**남은 것 (실행해야 확인 가능)**
- 실제 Google/Apple 로그인 → `idToken` 검증 통과 → JWT Keychain 저장 → `users/me` 200 (서버 `GOOGLE_CLIENT_ID`/`APPLE_CLIENT_ID` 설정 확인 포함)
- Place 데이터를 동기화한 뒤 `match/random` → `confirm` → `check-in` 전 구간
- 4회 매칭 시 429 → `MatchError.dailyLimitExceeded` 번역

---

## 범위 밖

- Presentation/화면 구현
- Core 모듈 — 공용 유틸이 실제로 필요해질 때
- 테스트 타겟 신설 — CLAUDE.md의 No Unsolicited Tests 원칙에 따라 요청 시에만
- Kakao 로그인 — 서버가 `apple`/`google`만 받는다. `SocialType`에서도 제거했다.
