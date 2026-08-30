# Domain/Data ↔ Anywhere_server 계약 정합화

## 할 일
- [x] 서버 실제 구현(routes/controllers/services/prisma)과 현재 iOS 코드 대조
- [x] 서버에 없는 계약 제거 (quests, feed/home, auth/me, passport 내 여권, ranking period)
- [x] Domain Entity/Error/Repository/UseCase를 실제 계약으로 재작성
- [x] Data API/DTO/Mapper/Repository 재작성 + 서버 전체 24개 오퍼레이션 커버
- [x] Auth 모듈: socialId → idToken 전달로 변경
- [x] DIContainer 재조립
- [x] 컴파일 통과 (DataDebug, DIContainerDebug)
- [x] 로컬 서버 실응답으로 DTO 디코딩 확인 + URL 빌더 전수 확인
- [ ] 실기기/시뮬레이터에서 소셜 로그인 → 체크인 전 구간 런타임 확인 (Place 데이터 동기화 필요)

## 리뷰 (프로토타입 반영 후)
- 처음엔 "내 맘대로"를 하단 별도 버튼으로 만들었는데, `Prototype.dc.html`을 받아 보니 **조건 목록의 4번째 행**(셰브론 달린)이고 누르면 바로 장소 검색으로 넘어간다. 골라서 돌아오면 조건 화면 하단 CTA가 `"%@으로 떠나기"`로 바뀌고, 고르기 전에는 secondary로 잠긴다. 프로토타입 구조로 다시 맞췄다.
- 조건 화면과 검색 화면은 스택으로 떨어져 있어 선택 결과를 주고받을 방법이 없었다. `TripPlanModel`(@Observable)을 `NavigationCoordinator`와 같은 방식으로 환경에 실어 공유한다 — Route에 선택 상태를 싣고 스택을 갈아끼우는 것보다 조작이 적다. 홈에서 조건 화면에 새로 들어올 때 `reset()`한다.
- 검색 목록 기본 정렬은 인구감소지역 우선(프로토타입의 "사람 적은 추천 지역"). 서버가 거리·아이콘을 주지 않아 프로토타입의 거리 표기와 장소별 아이콘은 옮기지 않았고, 아이콘은 인구감소 여부로만 갈랐다(`sprout`/`pin`).
- 거리 문구는 프로토타입이 아직 120/250km지만 **요청대로 100/200km를 유지**했다.

## 리뷰
- 기존 Domain/Data는 현재 서버와 다른 계약(옛 스냅샷)으로 작성돼 있었다. 엔드포인트 자체가 없는 것(`/api/quests`, `/api/feed/home`, `/api/auth/me`)과 필드 불일치가 섞여 있어 부분 수정이 아니라 계약 재작성으로 처리했다.
- 가장 중요한 변경은 로그인이다. 서버가 idToken을 공개키로 검증하도록 바뀌어 있어, socialId를 보내던 기존 코드로는 **로그인 자체가 401로 실패**한다.
- 검증 상세는 `docs/domain-data-architecture.md`의 "검증 상태" 참조.

---

# 자동 로그인 (세션 복구)

## 할 일
- [x] Keychain 저장 경로 점검 — 저장은 정상, `RestoreSessionUseCase` 호출부가 없어 자동 로그인만 누락된 것으로 확인
- [x] `RootViewModel` 추가 (restoring / authenticated / unauthenticated 상태 기계)
- [x] `RootView`를 3분기로 재작성 + `.task`에서 세션 복구
- [x] `HomeViewModel`이 `AuthSession` 대신 `User`를 받도록 변경 (복구 경로엔 토큰만 있고 AuthSession이 없다)
- [x] `AnywhereApp`에서 ViewModel을 `@State`로 소유하도록 조립 변경
- [x] 컴파일 통과 (AnywhereAppDebug)
- [x] 시뮬레이터 실행 — 토큰 없는 상태에서 Splash → LoginView 확인
- [ ] 서버 켠 상태에서 실제 로그인 → 앱 재실행 시 HomeView 직행 확인 (서버 필요)

## 리뷰 (프로토타입 반영 후)
- 처음엔 "내 맘대로"를 하단 별도 버튼으로 만들었는데, `Prototype.dc.html`을 받아 보니 **조건 목록의 4번째 행**(셰브론 달린)이고 누르면 바로 장소 검색으로 넘어간다. 골라서 돌아오면 조건 화면 하단 CTA가 `"%@으로 떠나기"`로 바뀌고, 고르기 전에는 secondary로 잠긴다. 프로토타입 구조로 다시 맞췄다.
- 조건 화면과 검색 화면은 스택으로 떨어져 있어 선택 결과를 주고받을 방법이 없었다. `TripPlanModel`(@Observable)을 `NavigationCoordinator`와 같은 방식으로 환경에 실어 공유한다 — Route에 선택 상태를 싣고 스택을 갈아끼우는 것보다 조작이 적다. 홈에서 조건 화면에 새로 들어올 때 `reset()`한다.
- 검색 목록 기본 정렬은 인구감소지역 우선(프로토타입의 "사람 적은 추천 지역"). 서버가 거리·아이콘을 주지 않아 프로토타입의 거리 표기와 장소별 아이콘은 옮기지 않았고, 아이콘은 인구감소 여부로만 갈랐다(`sprout`/`pin`).
- 거리 문구는 프로토타입이 아직 120/250km지만 **요청대로 100/200km를 유지**했다.

## 리뷰
- 토큰은 처음부터 Keychain에 정상 저장되고 있었다. 빠진 건 저장이 아니라 **복구 호출부**였다 — `RestoreSessionUseCase`가 DIContainer에만 있고 아무도 부르지 않았다.
- 화면 전환 권한은 `RootViewModel` 하나가 갖는다. `LoginViewModel`은 로그인 결과(`session`)만 알리고, `RootView`가 그 변화를 받아 `authenticate(_:)`로 넘긴다 — 상태 소유자를 둘로 나누지 않기 위함.
- 복구 실패(네트워크 오류 포함)는 모두 `unauthenticated`로 떨어진다. 즉 **오프라인으로 앱을 켜면 토큰이 있어도 로그인 화면**이 뜬다. 서버가 만료를 판정해야 하는 구조(리프레시 토큰 없음)라 현재는 이 선택이 안전하지만, 오프라인 UX가 필요해지면 재검토 대상.

---

# 다국어 지원 (ko / en / ja / zh-Hans)

## 할 일
- [x] `UIComponents`에 `ja.lproj` / `zh-Hans.lproj` `Localizable.strings` 추가 (50개 키, en/ko와 키·포맷 지정자 동일)
- [x] 앱 번들을 다국어 번들로 전환 — `AnywhereApp/Resources/{en,ko,ja,zh-Hans}.lproj/InfoPlist.strings` (앱 이름 + 위치 권한 문구)
- [x] `Tuist/Config/Info.plist`에 `UIPrefersShowingLanguageSettings`, `CFBundleDisplayName` 추가
- [x] `Project+Template.swift`의 `defaultKnownRegions`에 ja, zh-Hans 추가
- [x] `tuist generate` + `AnywhereAppDebug` 컴파일 통과
- [x] 시뮬레이터 실행 — 4개 언어로 홈 화면 문구·포맷(`Lv.%d`) 전환 확인 (스크린샷)
- [ ] 설정 앱 → Anywhere → "언어" 행 노출 육안 확인 (탭이 필요해 자동 확인 불가)
- [ ] 위치 권한 다이얼로그 문구가 선택 언어로 나오는지 확인 (권한 초기화 후 재요청 필요)

## 리뷰 (프로토타입 반영 후)
- 처음엔 "내 맘대로"를 하단 별도 버튼으로 만들었는데, `Prototype.dc.html`을 받아 보니 **조건 목록의 4번째 행**(셰브론 달린)이고 누르면 바로 장소 검색으로 넘어간다. 골라서 돌아오면 조건 화면 하단 CTA가 `"%@으로 떠나기"`로 바뀌고, 고르기 전에는 secondary로 잠긴다. 프로토타입 구조로 다시 맞췄다.
- 조건 화면과 검색 화면은 스택으로 떨어져 있어 선택 결과를 주고받을 방법이 없었다. `TripPlanModel`(@Observable)을 `NavigationCoordinator`와 같은 방식으로 환경에 실어 공유한다 — Route에 선택 상태를 싣고 스택을 갈아끼우는 것보다 조작이 적다. 홈에서 조건 화면에 새로 들어올 때 `reset()`한다.
- 검색 목록 기본 정렬은 인구감소지역 우선(프로토타입의 "사람 적은 추천 지역"). 서버가 거리·아이콘을 주지 않아 프로토타입의 거리 표기와 장소별 아이콘은 옮기지 않았고, 아이콘은 인구감소 여부로만 갈랐다(`sprout`/`pin`).
- 거리 문구는 프로토타입이 아직 120/250km지만 **요청대로 100/200km를 유지**했다.

## 리뷰
- 인앱 언어 선택 화면은 만들지 않았다. iOS 표준 경로(설정 앱 → 앱 → 언어)를 쓰면 iOS가 앱을 재시작하며 언어를 적용하므로 런타임 번들 스위칭 코드가 필요 없다. `Route.settings`는 그대로 자리표시자.
- 설정 앱에 "언어" 행이 안 뜨던 이유는 문구가 전부 `UIComponents` 리소스 번들에만 있어 **앱 번들에 `.lproj`가 하나도 없었기** 때문. `InfoPlist.strings`를 앱 타겟에 넣어 해결했다.
- 우려했던 지점 — 앱별 언어가 중첩 리소스 번들(`UIComponents_UIComponents.bundle`)까지 전파되는가 — 는 `simctl launch -AppleLanguages`로 4개 언어 모두 확인했다. 스텐실/번들 해석 코드를 건드릴 필요 없었다.
- 서버가 내려주는 텍스트(지역명 "강원특별자치도 고성군", 배지 라벨, `levelLabel`)는 여전히 한국어다. 서버 다국어 계약이 없어 이번 범위 밖.

---

# 도착 인증 → 후기 (Prototype `isGpsSuccess` / `isReview`)

## 할 일
- [x] 프로토타입과 앱 화면 대조 — 16개 중 6개 구현, placeholder 10개 확인
- [x] `Route`에 `arrivalVerification(place:)` / `review(place:)` 추가 (체크인 API가 matchId가 아닌 placeId를 받음)
- [x] `ArrivalVerificationView` + ViewModel — 진입 시 `CheckInUseCase` 1회 시도, 성공 시 도장/방문 순번/보상 표시
- [x] `ReviewView` + ViewModel — 80자 한 줄 후기, `CreateReviewUseCase`
- [x] `ViewModelFactory` 도입 — RootView/RouteDestinationView의 팩토리 파라미터가 화면 수만큼 늘어나는 걸 차단
- [x] `BackBar` 공용 추출 — MatchingView/TripFilterView/ReviewView가 같은 줄을 쓴다
- [x] ja/zh-Hans에 빠져 있던 `matchResult.*` 8개 키 채움 (직전 커밋 누락분)
- [x] 4개 언어 문구 추가 + `tuist generate` + `AnywhereAppDebug` 컴파일 통과
- [x] 시뮬레이터 실행 — 팩토리 리팩터링 후에도 앱이 LoginView까지 정상 부팅
- [ ] 체크인/후기 런타임 확인 (서버 기동 + 소셜 로그인 + 목적지 반경 안 GPS가 모두 필요해 자동 확인 불가)

## 리뷰 (프로토타입 반영 후)
- 처음엔 "내 맘대로"를 하단 별도 버튼으로 만들었는데, `Prototype.dc.html`을 받아 보니 **조건 목록의 4번째 행**(셰브론 달린)이고 누르면 바로 장소 검색으로 넘어간다. 골라서 돌아오면 조건 화면 하단 CTA가 `"%@으로 떠나기"`로 바뀌고, 고르기 전에는 secondary로 잠긴다. 프로토타입 구조로 다시 맞췄다.
- 조건 화면과 검색 화면은 스택으로 떨어져 있어 선택 결과를 주고받을 방법이 없었다. `TripPlanModel`(@Observable)을 `NavigationCoordinator`와 같은 방식으로 환경에 실어 공유한다 — Route에 선택 상태를 싣고 스택을 갈아끼우는 것보다 조작이 적다. 홈에서 조건 화면에 새로 들어올 때 `reset()`한다.
- 검색 목록 기본 정렬은 인구감소지역 우선(프로토타입의 "사람 적은 추천 지역"). 서버가 거리·아이콘을 주지 않아 프로토타입의 거리 표기와 장소별 아이콘은 옮기지 않았고, 아이콘은 인구감소 여부로만 갈랐다(`sprout`/`pin`).
- 거리 문구는 프로토타입이 아직 120/250km지만 **요청대로 100/200km를 유지**했다.

## 리뷰
- 체크인 호출 위치를 홈이 아니라 도착 인증 화면 안으로 넣었다. 프로토타입은 홈에서 성패를 판정한 뒤 성공 화면으로 넘어가지만, "500m 이탈"·"오늘 이미 체크인" 같은 사유는 전부 서버가 정하는 값이라 홈이 그걸 흉내내면 판정 주체가 둘로 갈린다. 실패는 화면 안 알림(재시도/뒤로)으로 처리한다.
- 보상 줄은 `CheckInResult`가 실제로 준 값만 만든다. 프로토타입의 "12 → 13곳" 같은 증감 표기는 이전 값을 모르므로 옮기지 않았다.
- 프로토타입의 "여권에서 보기" 버튼은 여권 화면이 아직 없어 "홈으로 돌아가기"로 대신 뒀다. 2번(여권) 작업에서 원래 목적지로 되돌린다.
- 후기 등록 후에는 홈으로 되돌아온다(프로토타입은 여권으로 간다). 같은 이유.

---

# 떠날 조건 거리 변경 + "내 맘대로" 직접 고르기

## 할 일
- [x] 거리 조건 120km → 100km, 250km → 200km (`TripRange` + ko/en/ja/zh 문구)
- [x] `PlaceRef`(id + name) 추가 — 체크인·후기에 좌표가 필요 없다는 사실을 타입으로 못박는다
- [x] `FetchSearchablePlacesUseCase` — 서버에 장소 검색 API가 없어 큐레이션 태그 장소를 합쳐 검색 풀로 쓴다
- [x] `PlaceSearchView` / `PlaceSearchViewModel` — 검색창 + 결과 목록 (풀은 1회 로드, 필터는 로컬)
- [x] `PickedPlaceView` — 고른 장소 결과 창 → "GPS 위치 인증하기"
- [x] `Route.placeSearch` / `.pickedPlace` 추가, `arrivalVerification`·`review`를 `PlaceRef`로 전환
- [x] `TripFilterView`에 "내 맘대로" 행 추가 — 프로토타입(`Prototype.dc.html`의 `isFilter`/`isSpotSearch`)에 맞춰 재작업
- [x] L10n 키 추가(ko/en/ja/zh) + `tuist generate`
- [x] `AnywhereAppDebug` 컴파일 통과
- [ ] 런타임 확인 — 개발 서버(172.20.10.3:3000)가 꺼져 있어 로그인부터 막힌다. 서버 켜고 검색 → 선택 → 도착 인증 흐름 확인 필요

## 전제
- 서버에 장소 검색 엔드포인트가 없다(`docs/domain-data-architecture.md` 매핑표 확인). `GET /api/tags/{id}/places` 합집합이 유일한 검색 대상이다.
- 직접 고른 장소는 matchId가 없어 `POST /api/match/{id}/confirm`을 못 탄다. 체크인은 placeId만 받으므로 도착 인증까지는 그대로 동작한다.

## 리뷰 (프로토타입 반영 후)
- 처음엔 "내 맘대로"를 하단 별도 버튼으로 만들었는데, `Prototype.dc.html`을 받아 보니 **조건 목록의 4번째 행**(셰브론 달린)이고 누르면 바로 장소 검색으로 넘어간다. 골라서 돌아오면 조건 화면 하단 CTA가 `"%@으로 떠나기"`로 바뀌고, 고르기 전에는 secondary로 잠긴다. 프로토타입 구조로 다시 맞췄다.
- 조건 화면과 검색 화면은 스택으로 떨어져 있어 선택 결과를 주고받을 방법이 없었다. `TripPlanModel`(@Observable)을 `NavigationCoordinator`와 같은 방식으로 환경에 실어 공유한다 — Route에 선택 상태를 싣고 스택을 갈아끼우는 것보다 조작이 적다. 홈에서 조건 화면에 새로 들어올 때 `reset()`한다.
- 검색 목록 기본 정렬은 인구감소지역 우선(프로토타입의 "사람 적은 추천 지역"). 서버가 거리·아이콘을 주지 않아 프로토타입의 거리 표기와 장소별 아이콘은 옮기지 않았고, 아이콘은 인구감소 여부로만 갈랐다(`sprout`/`pin`).
- 거리 문구는 프로토타입이 아직 120/250km지만 **요청대로 100/200km를 유지**했다.

## 리뷰
- `PlaceRef` 도입은 검색 장소에 좌표가 없어서 생긴 선택이다. 확인해보니 `ArrivalVerificationViewModel`·`ReviewViewModel`은 애초에 `place.id`와 `place.name`만 쓰고 있었다 — 좌표는 `Place`를 통째로 넘기느라 딸려온 것이지 요구사항이 아니었다. 가짜 좌표(0,0)를 채워 넣는 대신 타입을 필요한 크기로 줄였다.
- 검색은 네트워크를 한 번만 탄다. 태그 목록 → 태그별 장소를 모아 캐시하고, 키워드 필터는 로컬(`이름·주소·시도·시군구` 부분일치)에서 돈다. 태그 하나가 실패해도 나머지로 목록을 만든다.
- 직접 고른 장소는 `confirm`을 타지 않으므로 **홈의 "이동 중" 카드에는 뜨지 않는다.** 도장은 정상적으로 찍힌다(체크인은 placeId만 받는다). 여정으로도 잡히게 하려면 서버에 "직접 지정 매칭 생성" 계약이 필요하다.
- [x] `DebugScreenView` (임시) — `DEBUG_SCREEN=arrival|review` 환경변수로 가짜 응답을 물려 화면만 띄운다. 시뮬레이터에서 두 화면 렌더링 육안 확인 완료.
- [ ] **확인 끝나면 지울 것**: `Presentation/Sources/Common/DebugScreenView.swift` + `AnywhereApp.swift`의 `#if DEBUG` 분기
- [x] **로딩에서 멈추던 버그 수정** — 뷰가 ViewModel을 `@Bindable`로 참조만 해 부모 body 재평가 때마다 새 인스턴스가 붙었다. `@State`로 소유하도록 변경 (ArrivalVerification/Review + 같은 결함이 있던 Matching/MatchResult)
- [x] 로딩 상태에도 `BackBar` 노출 — 응답이 안 오면 빠져나갈 구멍이 없었다
- [x] `HTTPClient` 요청 타임아웃 60초 → 15초 (서버가 꺼져 있으면 1분간 스피너였다)

---

# 여권 화면 (디지털 여권)

## 할 일
- [x] `DSStampTile` — 프로토타입 DS의 `StampTile.jsx`를 그대로 옮긴 도장 타일
- [x] `PassportViewModel` — 여권 + 내 뱃지 병렬 로드
- [x] `PassportView` — 여권 카드 / 기초자치단체 수집판(4열) / 스페셜·히든 뱃지
- [x] ~~`Route.passport(userId:)`~~ → **탭으로 전환**. `MainTabView`가 상단 바·탭바를 소유하고 홈/여권/랭킹/설정을 갈아끼운다
- [x] L10n 키(ko/en/ja/zh) + `tuist generate`
- [x] 컴파일 통과 + 시뮬레이터에서 실서버 데이터로 화면 확인 (3/229곳)

## 리뷰
- 처음엔 여권을 `Route.passport`로 **push**했는데 그건 틀렸다. 프로토타입의 `showNav = [home, passport, ranking, settings]`가 말해주듯 이 넷은 밀고 들어가는 화면이 아니라 **탭**이다. push하면 뒤로가기 버튼이 생기고 탭바와 상단 바가 사라진다.
- 그래서 상단 바와 `DSBottomNav`의 소유권을 `HomeView`에서 `MainTabView`로 옮겼다. 화면은 내용만 그리고, 껍데기는 컨테이너가 그린다. 홈/여권 ViewModel도 컨테이너가 `@State`로 들고 있어 탭을 오갈 때 다시 받아오지 않는다.
- 랭킹·설정은 아직 화면이 없어 탭 안에서 "준비 중" 자리표시자를 보여준다 — 탭바는 그대로 남는다.
- 여권 탭은 **가진 것만** 보여준다(획득한 뱃지 / 찍은 도장). 아직 못 얻은 뱃지와 못 간 지역은 섹션 헤더의 `>`로 들어가는 `PassportDetailView`에서 잠긴 모습으로 본다.
- 상단 바 좌측 앱 이름은 뺐다 — 프로필 아바타만 남긴다.
- 지역 아이콘은 `regionId` 고정 해시로 고른다. 서버가 아이콘을 주지 않아서인데, 같은 지역은 항상 같은 그림이 나오지만 지역의 성격과는 무관하다(부여군이 야구공이 될 수 있다). 서버가 아이콘 키를 주면 바로 교체할 자리다.

## 서버가 안 주는 것 (프로토타입에서 옮기지 않음)
- 여권 번호(`AMD-2026-0412`) — 계약에 없다.
- 지역별 아이콘 — `PassportRegion`에 없다. `regionId` 기반 고정 해시로 지역 아이콘 세트에서 고른다(같은 지역은 항상 같은 아이콘).

---

# 랭킹 탭 (성장 & 랭킹)

## 할 일
- [x] `RankingViewModel` — 성장 지역 / 유저 랭킹 / 내 순위 병렬 로드, 한쪽이 실패해도 나머지는 보여준다
- [x] `RankingView` — 세그먼트(도시 성장 게이지 / 유저 랭킹)
- [x] `MainTabView`의 랭킹 탭 연결 + 팩토리 조립
- [x] L10n 키(ko/en/ja/zh) + `tuist generate`
- [x] 컴파일 통과 + 시뮬레이터 실서버 확인 (고성군·여주시 Lv.1 / 내 순위 1위 · 상위 25.0%)

## 서버가 안 주는 것 (프로토타입에서 옮기지 않음)
- **내 관심 로컬(북마크)** — 저장 API가 없다. 프로토타입의 ★는 로컬 상태다.
- **유저 레벨 문구**("Lv.8 전국구 방랑자") — `GET /api/ranking/users`는 `totalStamps`만 준다. "도장 N개"로 대체.
- 지역 카드의 진행률은 서버가 성장 목록에 `progressLabel`을 주지 않아 `current / target`으로 직접 계산한다.

## 남은 것
- 랭커 행을 눌러 여는 **랭커 상세**(`GET /api/users/{id}/detail`, `FetchRankerDetailUseCase`)는 아직 화면이 없어 행을 누를 수 없게 뒀다 — 죽은 셰브론을 두지 않기 위함.
- 지역 카드도 같은 이유로 아직 `regionDetail`로 넘기지 않는다.

---

# 지역 상세 / 랭커 상세

## 할 일
- [x] `RegionDetailDTO`·`RegionDetail`에 `imageUrl`/`imageCredit` 추가 — 서버는 주고 있었는데 우리가 버리고 있었다
- [x] `DSQuoteCallout` — 프로토타입 DS의 `QuoteCallout.jsx` 이식
- [x] `RegionDetailView` — 사진 히어로 / 성장 게이지 / 통계 / 레벨 달성 현황 / 주민 한마디
- [x] `RankerDetailView` — 프로필 / 요약 지표 2×2 / 이번 달 활동 막대 / 대표 도장
- [x] 진입 연결 — 랭킹 탭의 지역 카드·랭커 행, 홈의 "지금 뜨는 로컬" 행
- [x] 컴파일 통과 + 시뮬레이터 실서버 확인 (강원 고성군 / 김경훈 1위)

## 리뷰
- 히어로 사진에서 `scaledToFill`을 그대로 두니 **히어로가 사진 원본 비율만큼 넓어지고 화면 전체가 좌우로 밀렸다.** `.clipped()`는 그린 뒤 자를 뿐 레이아웃 폭은 이미 커진 뒤였다. 사진을 고정 크기 `Rectangle`의 `overlay`로 넣어 부모 밖으로 못 자라게 했다.
- 프로토타입 히어로는 OSM 지도 타일이지만 서버가 지역 대표 사진을 주므로 그쪽을 썼다. 저작자 표기 자리는 프로토타입의 지도 출처 자리와 같다.
- ★ 북마크는 저장 API가 없어 옮기지 않았다.
- 순위는 상세 API가 주지 않아 목록에서 눌린 값을 Route에 실어 보낸다.

---

# 설정 탭

## 할 일
- [x] `SettingsViewModel` — 프로필 조회 / 푸시 설정 변경 / 로그아웃
- [x] `SettingsView` — 프로필 카드 · 알림 · 정보 · 로그아웃
- [x] `LegalDocument` + `LegalDocumentView` — 약관·처리방침 본문 (프로토타입 `isDoc`)
- [x] `RootViewModel.signOut()` + 로그아웃 시 스택 초기화
- [x] 컴파일 통과 + 시뮬레이터 실서버 확인 (김경훈 · 골목 탐험가 · Apple 연결)

## 결정
- 프로토타입은 알림을 "스페셜 퀘스트 / 관심 로컬 레벨업" 둘로 나누지만 서버 설정은 `pushEnabled` 하나뿐이라 **한 줄 토글**로 합쳤다. 없는 설정을 있는 척 두 줄로 그리지 않는다.
- 약관·처리방침 본문은 서버에 문서 API가 없어 앱이 들고 있는다(`LegalDocument`). **프로토타입 문안 그대로이고 법무 검토를 거친 문서가 아니다** — 실제 문안이 나오면 그 파일만 교체하면 된다. 4개 언어로 번역할 대상이 아니라 판단해 L10n으로 쪼개지 않았다.
- 프로필 카드는 아직 누를 수 없다. 프로필 편집 화면(`PATCH /api/users/me`)이 없어 셰브론도 두지 않았다.
- 로그인 화면에서 시트로 열리던 약관/처리방침도 이제 같은 화면을 쓴다.

## 다음
- `GET /api/places/{id}`가 서버에 생겼다(확인 완료). 장소 상세를 만들 수 있다.
