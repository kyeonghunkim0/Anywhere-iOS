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
