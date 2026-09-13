---
name: fastlane-screenshots
description: App Store Connect 스크린샷(미리보기 이미지)을 fastlane으로 업로드/교체할 때 사용
---

# fastlane App Store 스크린샷 업로드

App Store Connect의 "미리보기 및 스크린샷"을 fastlane `deliver`로 업로드할 때 이 절차를 따른다.
메타데이터(설명, 키워드 등)나 바이너리는 건드리지 않고 **스크린샷만** 갱신한다.

## 폴더 구조

`fastlane/screenshots/<locale>/` 아래에 로케일별로 이미지를 둔다. (`.gitignore`에 등록되어 있어 git에는 커밋되지 않음 — 로컬에만 존재)

```
fastlane/screenshots/
  ko/         # 한국어
  en-US/      # 영어 (미국)
  ja/         # 일본어
  zh-Hans/    # 중국어 간체
```

이 앱이 지원하는 로케일은 `Projects/AnywhereApp/Resources/*.lproj` 기준 ko, en, ja, zh-Hans이며, App Store Connect 로케일 코드로는 각각 `ko`, `en-US`, `ja`, `zh-Hans`를 쓴다.

- 파일명은 순서만 지키면 되므로 `1_..png`, `2_..png` 처럼 번호를 앞에 붙여 노출 순서를 제어한다.
- fastlane은 이미지 해상도로 기기(예: 6.9" iPhone, iPad 등)를 자동 판별한다. 새 기기 프레임(예: iPhone 16 Pro Max = 1320x2868)을 추가할 때는 정확한 해상도로 export된 PNG를 그대로 넣으면 된다.
- 같은 이미지를 여러 로케일에 쓰려면 각 로케일 폴더에 동일 파일을 복사해 넣는다 (심볼릭 링크 대신 실제 복사 — Xcode Cloud/CI 환경에서 심볼릭 링크가 깨질 수 있음).

## 업로드 실행

`fastlane/Fastfile`의 `upload_screenshots` 레인을 사용한다:

```bash
cd fastlane && fastlane upload_screenshots
```

이 레인은 `upload_to_app_store`를 다음 옵션으로 호출한다:
- `skip_binary_upload: true` — 앱 빌드는 올리지 않음
- `skip_metadata: true` — 설명/키워드 등 메타데이터는 건드리지 않음
- `skip_app_version_update: true`
- `overwrite_screenshots: true` — 기존 스크린샷을 새 이미지로 교체
- `force: true` — HTML 리포트 확인 프롬프트 생략

## 사전 요구사항 (App Store Connect API Key)

`load_asc_api_key` 헬퍼가 다음 환경변수를 요구한다 (`.env` 또는 셸 환경에 설정):
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_API_KEY_ISSUER_ID`
- `APP_STORE_CONNECT_API_KEY_KEY_FILEPATH` 또는 `APP_STORE_CONNECT_API_KEY_KEY_CONTENT` 중 하나

`fastlane check_api_key` 레인으로 먼저 키가 유효한지 검증할 수 있다.

## 주의사항

- **되돌리기 어려운 원격 작업이다.** App Store Connect에 실제로 반영되므로, 사용자가 명시적으로 요청했을 때만 `fastlane upload_screenshots`를 실행한다. 이미지/폴더 준비까지만 하고 실행은 확인받는 것을 기본으로 한다.
- 심사 중(In Review)이거나 편집 불가 상태의 버전에는 스크린샷을 덮어쓸 수 없다. 실패 시 App Store Connect에서 해당 버전 상태를 먼저 확인한다.
