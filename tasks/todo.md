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
