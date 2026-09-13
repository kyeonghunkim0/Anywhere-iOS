---
name: fastlane-upload
description: fastlane으로 TestFlight/App Store에 빌드를 업로드할 때 사용 (beta, release 레인)
---

# fastlane 업로드 (TestFlight / App Store)

앱 빌드를 TestFlight나 App Store Connect에 올릴 때 이 절차를 따른다. 스크린샷만 갱신할 때는 `.claude/skills/fastlane-screenshots`를 대신 사용한다.

## 레인

`fastlane/Fastfile` 기준:

- `fastlane check_api_key` — App Store Connect API 키가 유효한지만 검증 (사이드 이펙트 없음, 안전하게 먼저 실행 가능)
- `fastlane build` — 시뮬레이터용 Debug 빌드만 (업로드 없음)
- `fastlane beta` — Release 빌드 후 **TestFlight**에 업로드 (`skip_waiting_for_build_processing: true`)
- `fastlane release` — Release 빌드 후 **App Store Connect**에 업로드 (`skip_metadata: true`, `skip_screenshots: true`, `force: true` — 메타데이터/스크린샷은 건드리지 않고 바이너리만 제출)

각 레인은 내부적으로 `clean` → `generate`(tuist) → `get_certificates`/`get_provisioning_profile` → `build_app` → 업로드 순으로 실행된다.

```bash
cd fastlane && fastlane beta      # TestFlight
cd fastlane && fastlane release   # App Store 심사 제출
```

## 사전 요구사항 (App Store Connect API Key)

`load_asc_api_key` 헬퍼가 다음 환경변수를 요구한다:
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_KEY_FILEPATH` 또는 `APP_STORE_CONNECT_API_KEY_KEY_CONTENT` 중 하나

값이 비어 있으면 레인 실행 시 `UI.user_error!`로 즉시 중단된다. 업로드 전에 `fastlane check_api_key`로 먼저 확인하는 것을 권장한다.

앱 식별자/Apple ID는 `fastlane/Appfile`에 고정되어 있다 (`com.kimkhuna.Anywhere.AnywhereApp`).

## 주의사항

- **되돌리기 어려운 원격 작업이다.** TestFlight 업로드나 App Store 심사 제출은 실제로 Apple 서버에 반영되므로, 사용자가 명시적으로 요청했을 때만 `beta`/`release` 레인을 실행한다.
- `release`는 `force: true`로 확인 프롬프트 없이 바로 제출하므로 실행 전에 버전/빌드 번호, 서명 상태를 다시 한번 확인한다.
- 인증서/프로비저닝 프로파일은 매 실행마다 `get_certificates`/`get_provisioning_profile`로 새로 받아온다 — 로컬 키체인 상태에 의존하지 않는다.
- 실패 시 우선 `fastlane check_api_key`로 API 키 문제인지 배제하고, 그다음 코드 서명/프로비저닝 프로파일 문제를 의심한다.
