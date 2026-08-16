# Domain / Data 계층 설계

> 작성 시점의 백엔드 기준: Swagger **v1.2.0** (`~/Desktop/Anywhere-backend`)

## Context

디자인 시스템(UIComponents)과 소셜 로그인(Auth)은 구현됐지만 `Domain`, `Data` 모듈은 아직 빈 placeholder 파일뿐이다. 화면을 붙이려면 서버와 통신하는 계층이 먼저 필요하다.

백엔드는 Swagger v1.2.0이 실제 구현과 일치하는 것을 소스 대조로 확인했으므로 **Swagger를 API 계약으로 삼는다**. (v1.1.0까지는 실제 구현과 여러 곳에서 어긋나 있었다 — 없는 엔드포인트가 문서에 있거나, 있는 엔드포인트가 문서에 없었다. 문서를 믿기 전에 `src/routes`·`src/services`를 확인하는 습관이 필요하다.)

목표: 11개 API 오퍼레이션을 덮는 Entity / Repository 프로토콜 / UseCase(Domain)와 그 구현체·통신 계층(Data)을 만든다.

---

## 확정한 설계 결정

**1. 통신은 `BaseAPI` 프로토콜 + 기능별 enum으로 정의한다.**
Moya `TargetType` 스타일. 엔드포인트 하나가 enum case 하나가 되고, **path parameter는 문자열 보간이 아니라 별도 딕셔너리로 선언해 URL 빌더가 치환**한다. `path`를 Swagger의 path 템플릿과 글자 그대로 같게 유지할 수 있어 문서 대조가 쉽다.

**2. 통신 계층은 Data 안에 둔다. Core는 건드리지 않는다.**
CLAUDE.md 모듈 표가 "API 연동"을 Data의 역할로 못박고 있고, Core는 "공통 유틸리티, 확장, 기반 타입"이다. `DependencyInfo.swift:15`가 `.domain: [.core]`이므로 Core에 URLSession·Keychain을 넣으면 **Domain이 인프라 모듈을 링크**하게 된다. Core에 두려던 유일한 근거였던 "Auth가 TokenStore를 재사용"은 실제로 성립하지 않는다 — Auth는 소셜 SDK 로그인만 하고 서버 JWT를 쓰지 않는다. 없는 재사용성을 위해 모듈을 나누지 않는다.

**3. 전송 계층 에러는 Data 밖으로 나가지 않는다.**
Domain이 자기 에러(`MatchError`, `CheckInError`, `AuthError` …)를 정의하고, Data의 Repository 구현체가 경계에서 HTTP 상태코드를 도메인 에러로 **번역**한다. Domain·Presentation은 HTTP를 모른다.

**4. `socialId`는 원본 소셜 ID를 쓴다** — Google `GIDGoogleUser.userID`, Apple `ASAuthorizationAppleIDCredential.user`.
백엔드 `schema.prisma:21` 주석("소셜 로그인 고유 ID")과 의미가 맞고, 나중에 서버가 소셜 토큰 검증을 붙여도 그대로 호환된다. Firebase 로그인 흐름 자체는 지금 코드 그대로 두고, 원본 ID를 함께 반환하도록만 넓힌다.

> 참고: 현재 백엔드는 소셜 토큰을 **검증하지 않고** `socialId` 문자열만 신뢰한다(`auth.service.ts:37`). 또한 `socialType`은 조회 조건에 들어가지 않으므로 `socialId`는 전역 유일해야 한다. 서버가 검증을 붙이기 전까지는 신원 위조가 가능한 구조라는 걸 알고 있어야 한다.

**5. 위치는 Domain 프로토콜 + Data 구현** — Domain에 `Coordinate` 값 타입과 `LocationRepository` 프로토콜, Data에 CoreLocation 구현. UseCase가 좌표를 스스로 확보해 자기완결적이 되고, `match`/`check-in`/`claim` 세 곳에 흩어질 위치 로직이 한 군데로 모인다.

**6. 범위는 11개 오퍼레이션 전부** — API가 작아서 한 번에 끝내야 DTO·에러 처리 규칙이 일관된다.

---

## 의존 방향

```
AnywhereApp ──▶ DIContainer ──▶ Presentation ──▶ ┐
                    │                            │
                    ├──▶ Data ───────────────────┼──▶ Domain
                    └──▶ Auth                    ┘
```

- **Domain은 어떤 바깥 모듈도 참조하지 않는다.** 순수 Swift 타입과 프로토콜만.
- **Data는 Domain의 프로토콜을 구현**한다(의존성 역전). URLSession·Keychain·CoreLocation은 전부 Data 안에 갇힌다.
- **DIContainer가 합성 루트**다. 최외곽이므로 Auth·Data·Domain을 모두 아는 게 맞다.
- Tuist 의존성 그래프(`DependencyInfo.swift`)는 **변경하지 않는다.**

### 경계에서 지킬 규칙

| 규칙 | 이유 |
|---|---|
| Domain에 `import UIKit / CoreLocation / Firebase` 금지 | 프레임워크 무지 |
| Repository 프로토콜은 Domain 에러만 던진다 | 전송 세부가 안으로 새지 않도록 |
| DTO는 Data 밖으로 나가지 않는다 | 서버 스키마 변경이 Domain을 흔들지 않도록 |
| 권한 상태는 Domain의 `LocationAuthorization`으로 표현 | `CLAuthorizationStatus` 누출 차단 |
| `SocialAuthenticating`에 `UIViewController` 금지 | 아래 DIContainer 항목 참조 |

---

## 통신 계층 설계 (`BaseAPI`)

```swift
// Data/Network/BaseAPI.swift
protocol BaseAPI: Sendable {
    var path: String { get }                        // "/api/quests/{id}/claim"
    var method: HTTPMethod { get }
    var pathParameters: [String: String] { get }    // ["id": questId]
    var queryParameters: [String: String] { get }
    var task: RequestTask { get }                   // .plain / .jsonBody(...)
    var authorization: AuthorizationPolicy { get }
}

extension BaseAPI {   // 대부분의 case가 기본값으로 끝나도록
    var pathParameters: [String: String] { [:] }
    var queryParameters: [String: String] { [:] }
    var task: RequestTask { .plain }
    var authorization: AuthorizationPolicy { .none }
}

enum RequestTask: Sendable {
    case plain
    case jsonBody(any Encodable & Sendable)
}

enum AuthorizationPolicy: Sendable {
    case none        // 토큰 안 붙임
    case required    // 반드시 붙임
    case optional    // 있으면 붙이고 없으면 그냥 보냄
}
```

`baseURL`은 `BaseAPI`가 들고 있지 않는다. API enum은 "어떤 엔드포인트인지"만 말하고, "어디로 보낼지"는 `APIConfiguration`을 주입받은 `HTTPClient`가 안다. 덕분에 모든 enum이 baseURL을 반복 선언하지 않는다.

**URL 빌더**(`URLRequest+BaseAPI.swift`)는 `path`의 `{key}`를 `pathParameters[key]`로 치환하고 값은 percent-encoding한다. 치환 후에도 `{`가 남아 있으면 `TransportError.invalidPath`로 **던진다** — 오타나 파라미터 누락을 요청 직전에 잡는다.

사용 예:

```swift
// Data/API/QuestAPI.swift
enum QuestAPI: BaseAPI {
    case list
    case claim(questId: String, request: ClaimQuestRequestDTO)

    var path: String {
        switch self {
        case .list:  "/api/quests"
        case .claim: "/api/quests/{id}/claim"     // ← Swagger와 동일 문자열
        }
    }
    var pathParameters: [String: String] {
        switch self {
        case .list:                      [:]
        case .claim(let questId, _):     ["id": questId]
        }
    }
    var method: HTTPMethod {
        switch self {
        case .list:  .get
        case .claim: .post
        }
    }
    var authorization: AuthorizationPolicy {
        switch self {
        case .list:  .optional          // 토큰 있으면 isAcquired가 채워짐
        case .claim: .required
        }
    }
    var task: RequestTask {
        switch self {
        case .list:                      .plain
        case .claim(_, let request):     .jsonBody(request)
        }
    }
}
```

`HTTPClient`는 `func request<T: Decodable>(_ api: some BaseAPI, as: T.Type) async throws -> (T, HTTPStatus)` 형태의 actor로, Bearer 주입·상태코드 매핑·디코딩을 담당한다. 던지는 건 `TransportError`이며 **Repository 구현체가 이를 Domain 에러로 번역해 밖으로 내보낸다.**

---

## 모듈 구조

### Domain — 순수 Swift만

```
Projects/Domain/Sources/
  Entity/
    Coordinate.swift  LocationAuthorization.swift  SocialCredential.swift
    AuthSession.swift  User.swift  Place.swift  Region.swift
    RandomMatch.swift  DurationFilter.swift  StampResult.swift
    CheckInResult.swift  Passport.swift  Quest.swift  ClaimedBadge.swift
    Ranking.swift  HomeFeed.swift
  Error/
    AuthError.swift      sessionExpired / signInCancelled / rejected(message)
    MatchError.swift     dailyLimitExceeded(message) / noPlaceNearby
    CheckInError.swift   rejected(message)      ← 400 계열을 메시지째로
    QuestError.swift     rejected(message)
    NetworkError.swift   offline / server / unknown  (전송 실패의 도메인 표현)
  Repository/          (전부 protocol, Sendable)
    AuthRepository  MatchRepository  MissionRepository  PassportRepository
    RankingRepository  FeedRepository  QuestRepository
    LocationRepository  SessionRepository  SocialAuthenticating
  UseCase/
    SignInUseCase  SignOutUseCase  RestoreSessionUseCase  FetchMyProfileUseCase
    FetchRandomMatchUseCase  CheckInUseCase  FetchPassportUseCase
    FetchUserRankingUseCase  FetchMyRankUseCase  FetchHomeFeedUseCase
    FetchQuestsUseCase  ClaimQuestUseCase
```

위치가 필요한 UseCase(`FetchRandomMatch`, `CheckIn`, `ClaimQuest`)는 `LocationRepository`를 주입받아 내부에서 좌표를 얻는다. 호출부는 좌표를 넘기지 않는다.

### Data — 인프라는 전부 여기 갇힌다

```
Projects/Data/Sources/
  Network/
    BaseAPI.swift  HTTPMethod.swift  RequestTask.swift  AuthorizationPolicy.swift
    URLRequest+BaseAPI.swift   path 치환 · 쿼리 · 바디 조립
    HTTPClient.swift           actor. URLSession + Bearer 주입 + 상태코드 매핑
    TransportError.swift       Data 내부 전용 (밖으로 안 나감)
    JSONCoder.swift            소수점 초까지 파싱하는 공용 encoder/decoder
    APIConfiguration.swift     baseURL 주입 (하드코딩 금지)
  Storage/
    KeychainStorage.swift      Security 프레임워크 래퍼
    TokenStore.swift           actor. Keychain 기반 JWT 보관
  API/         AuthAPI  MatchAPI  MissionAPI  PassportAPI
               RankingAPI  FeedAPI  QuestAPI          ← 전부 BaseAPI 채택 enum
  DTO/         Swagger 스키마 1:1 대응 (UserDTO, PlaceDTO, PassportDTO, QuestDTO …)
  Response/    APIResponse<T>          {success, message?, data}
               CheckInResponseDTO      stamp가 최상위인 예외 케이스
               RankingResponseDTO      data와 period가 형제
  Mapper/      DTO → Entity 변환 + TransportError → Domain 에러 번역
  Repository/  각 Repository 프로토콜 구현체
               + LocationRepositoryImpl (CoreLocation)
               + SessionRepositoryImpl  (TokenStore 래핑)
```

### Core

**이번 작업에서 건드리지 않는다.** 공용 유틸리티가 실제로 필요해지는 시점에 채운다.

### Auth (수정)

`AuthProvider`가 Firebase 로그인 결과와 함께 원본 소셜 ID를 반환하도록 넓힌다. 기존 Firebase 흐름·nonce 처리(`AppleSignInCoordinator`)는 건드리지 않는다.

```swift
public struct SocialSignInResult: Sendable {
    public let socialId: String        // GIDGoogleUser.userID / credential.user
    public let nickname: String?
    public let profileImageURL: URL?
}
```

### DIContainer (수정) — 합성 루트

Domain의 `SocialAuthenticating`을 Auth의 `AuthProvider`로 구현하는 어댑터를 둔다. Domain과 Auth는 서로를 못 보고 DIContainer만 둘 다 보므로(`DependencyInfo.swift:12-17`) 여기가 유일한 접점이다.

**중요**: `AuthProvider.signInWithGoogle(presenting:)`(`AuthProvider.swift:13`)은 `UIViewController`를 요구한다. Domain의 `SocialAuthenticating.signIn(with:) async throws -> SocialCredential`에는 이 파라미터가 없어야 하므로, **어댑터가 활성 window scene에서 presenting VC를 직접 찾아 흡수**한다. UIKit 접촉은 최외곽에만 남는다.

---

## API 계약에서 반드시 지켜야 할 함정

실제 백엔드 코드를 읽어 확인한 것들이다. 놓치면 런타임에 조용히 깨진다.

**① 날짜에 소수점 초가 있다.** 서버 응답이 `2026-08-16T08:22:49.573Z` 형태다(`/health`로 실측). `JSONDecoder.DateDecodingStrategy.iso8601`은 소수점 초를 못 읽고 실패하므로, `ISO8601DateFormatter`에 `.withFractionalSeconds`를 켜서 `.custom`으로 넣는다. → `Data/Network/JSONCoder.swift`

**② `mapX`는 경도, `mapY`는 위도다.** 이름 순서가 위경도 관례와 반대다(`schema.prisma:69-70`, `match.service.ts:85`에서 확인). Mapper에서 `Coordinate(latitude: mapY, longitude: mapX)`로 뒤집어 담고, 그 뒤로는 `Coordinate`만 쓴다.

**③ 신규 가입 여부는 HTTP 상태코드로만 알 수 있다.** `POST /api/auth/login`은 신규면 **201**, 기존이면 **200**을 주는데 `isNewUser`가 응답 본문에 없다(`auth.controller.ts:37`). `HTTPClient`가 상태코드를 함께 돌려주고, `AuthRepositoryImpl`이 이를 `AuthSession.isNewUser`로 바꿔 담는다 — 상태코드 자체는 Domain에 노출하지 않는다.

**④ check-in만 envelope이 다르다.** 다른 API는 전부 `data`로 감싸는데 check-in은 `{success, message, stamp}`로 `stamp`가 최상위다(`mission.controller.ts:40`). 공용 `APIResponse<T>`로 처리되지 않으므로 전용 DTO를 둔다.

**⑤ 400 에러는 한국어 메시지로만 구분된다.** check-in 실패가 "존재하지 않는 관광지 / 500m 이탈 / 오늘 이미 체크인" 셋 다 400 + 서로 다른 한글 `message`로 온다. 문자열 파싱으로 분기하면 서버 문구가 바뀔 때 깨지므로 `CheckInError.rejected(message:)`로 담아 **메시지를 그대로 사용자에게 노출**한다. 429(일일 매칭 초과)와 404(주변 명소 없음)는 상태코드로 구분되니 `MatchError`의 별도 case로 번역한다.

**⑥ `GET /api/quests`는 토큰이 선택이다.** optional auth 미들웨어가 붙어 있어, 토큰이 있으면 붙여 보내야 `isAcquired`가 채워지고 없어도 성공해야 한다. → `AuthorizationPolicy.optional`로 표현한다.

---

## 알면서 감수하는 트레이드오프

**Entity가 서버 렌더링 문구를 담는다.** `visitorOrderMessage`("당신은 ... #135번째 방문자입니다!"), `engravingText`, `dDay`, `growingRegions[].message`는 서버가 만든 표시용 한국어 문자열이다. 엄밀히는 Domain이 UI 카피를 나르는 것이라 순수하지 않다. 걷어내고 클라이언트에서 재조립하면 서버의 계산 로직(방문자 순번, 레벨업 잔여 인원, D-Day)을 중복 구현해야 하므로 **그대로 둔다.** 다만 화면에서 다른 문구가 필요해지는 순간 이 필드들은 Presentation에서 재조립 대상이 된다는 걸 기억해 둔다.

---

## Info.plist 변경 (`Tuist/Config/Info.plist`)

둘 다 지금 없어서 추가하지 않으면 각각 크래시/통신 실패로 이어진다.

- **`NSLocationWhenInUseUsageDescription`** — CoreLocation 사용 시 필수. 없으면 권한 요청이 즉시 실패한다.
- **`NSAppTransportSecurity` → `NSAllowsLocalNetworking`** — 개발 서버가 `http://localhost:3000`이라 ATS에 막힌다. 로컬 전용 예외라 전면 허용(`NSAllowsArbitraryLoads`)은 쓰지 않는다.

`baseURL`은 `APIConfiguration`으로 주입하고 AnywhereApp에서 조립한다. 시뮬레이터는 `localhost`로 붙지만 실기기는 맥의 LAN IP가 필요하다.

---

## 구현 순서

1. **Domain Entity + Error + Repository 프로토콜** — 의존성이 없으므로 가장 먼저 확정
2. **Data 통신 계층** — BaseAPI/URL 빌더/HTTPClient/TransportError/JSONCoder/Keychain/TokenStore
3. **Data API enum + DTO + Mapper** — Swagger 스키마 1:1, 함정 ①②를 여기서 흡수
4. **Data Repository 구현** — 에러 번역 포함 + LocationRepositoryImpl
5. **Domain UseCase** — 위치 결합 UseCase 포함
6. **Auth 확장 + DIContainer 어댑터/조립**
7. **Info.plist 키 추가**

각 단계마다 `tuist generate` 후 빌드가 통과하는지 확인하며 진행한다.

---

## 검증

**백엔드 없이 할 수 있는 것**
- `tuist generate` 후 전 모듈 컴파일 통과 — Swift 6 strict concurrency 하에서 Sendable 위반 포함
- **경계 검사** — `Projects/Domain/Sources`에 `import UIKit|CoreLocation|Firebase`가 하나도 없는지 grep으로 확인. Data가 SwiftUI/UIKit을 끌어오지 않는지도 함께 확인
- **URL 빌더 확인** — `PassportAPI.detail(userId: "abc")` → `/api/passport/abc`, `QuestAPI.claim(questId: "q1", …)` → `/api/quests/q1/claim`이 나오는지, 파라미터를 빠뜨리면 `invalidPath`로 던지는지
- **DTO 디코딩 확인** — Swagger의 example JSON을 문자열로 넣어 디코딩되는지. 특히 함정 ①(소수점 초)과 ④(check-in envelope)

**서버 연동 후**
- `POST /api/auth/login` → 토큰 Keychain 저장 → `GET /api/auth/me` 200 확인
- 신규 계정으로 201, 같은 `socialId` 재로그인으로 200이 오는지 (함정 ③)
- `GET /api/match/random`을 4회 호출해 4번째에 `MatchError.dailyLimitExceeded`로 번역되는지
- 좌표를 멀리 두고 check-in해 400 + 한글 메시지가 그대로 노출되는지 (함정 ⑤)
- 토큰 없이/있이 `GET /api/quests`를 호출해 `isAcquired`가 달라지는지 (함정 ⑥)

컴파일 통과만으로는 "검증"이라 부르지 않는다. 위 서버 연동 항목까지 확인해야 검증 완료다.

---

## 범위 밖

- Presentation/화면 구현 — 이 문서는 Domain/Data까지
- Core 모듈 — 공용 유틸이 실제로 필요해질 때
- 테스트 타겟 신설 — CLAUDE.md의 No Unsolicited Tests 원칙에 따라 요청 시에만
- Kakao 로그인 — 서버는 받지만 iOS에 SDK가 없다. `SocialType`에 `kakao` 케이스만 정의해두고 연동은 하지 않는다
