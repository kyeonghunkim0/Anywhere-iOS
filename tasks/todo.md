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

## 리뷰
- 인앱 언어 선택 화면은 만들지 않았다. iOS 표준 경로(설정 앱 → 앱 → 언어)를 쓰면 iOS가 앱을 재시작하며 언어를 적용하므로 런타임 번들 스위칭 코드가 필요 없다. `Route.settings`는 그대로 자리표시자.
- 설정 앱에 "언어" 행이 안 뜨던 이유는 문구가 전부 `UIComponents` 리소스 번들에만 있어 **앱 번들에 `.lproj`가 하나도 없었기** 때문. `InfoPlist.strings`를 앱 타겟에 넣어 해결했다.
- 우려했던 지점 — 앱별 언어가 중첩 리소스 번들(`UIComponents_UIComponents.bundle`)까지 전파되는가 — 는 `simctl launch -AppleLanguages`로 4개 언어 모두 확인했다. 스텐실/번들 해석 코드를 건드릴 필요 없었다.
- 서버가 내려주는 텍스트(지역명 "강원특별자치도 고성군", 배지 라벨, `levelLabel`)는 여전히 한국어다. 서버 다국어 계약이 없어 이번 범위 밖.
