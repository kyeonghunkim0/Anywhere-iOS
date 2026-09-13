---
name: commit
description: 이 저장소에 git 커밋을 만들 때 사용 (커밋 메시지 컨벤션)
---

# 커밋 컨벤션

이 저장소의 `git log`에서 관찰된 실제 컨벤션. 커밋 메시지를 작성할 때 이 형식을 따른다.

## 제목 (subject)

`git log`를 참고: 항상 영어, Conventional Commits 형식.

```
<type>(<scope>): <summary>
```

- `type`: `feat`, `fix`, `refactor`, `style`, `docs` 등
- `scope`: 보통 Feature/모듈 단위 (`match`, `search`, `passport`, `auth`, `fastlane`, `presentation` 등). 범위가 애매하면 생략 가능 (`feat: show the region badge on trending local`)
- `summary`: 소문자로 시작하는 영어 명령형 구, 마침표 없음, 50~70자 내외

예:
- `fix(match): remove debug location/radius override, dedupe consecutive random matches`
- `feat(passport): navigate to region detail from collection board and show region badges in ranker detail`
- `docs(fastlane): add fastlane-upload skill for TestFlight/App Store builds`

## 본문 (body)

- **"왜"가 자명하지 않을 때만** 작성한다. 단순한 변경(스킬 문서 추가 등)은 1~2줄로 무엇을 다루는지만 적어도 된다.
- 언어는 섞어 써도 된다 — 실제로 한국어로 배경/문제 상황을 설명한 커밋과 영어로 설명한 커밋이 공존한다. 버그 수정처럼 배경 설명이 필요하면 한국어로 상세히 써도 무방.
- WHAT(코드가 뭘 하는지)보다 **WHY**(어떤 문제였는지, 왜 이 방식을 택했는지)를 적는다. 코드를 보면 알 수 있는 내용은 반복하지 않는다.
- 현재 진행 중인 태스크명이나 이슈 번호 나열보다는, 나중에 봐도 이해되는 자기완결적 설명을 우선한다.

## Attribution

세션에서 attribution 지침이 주어졌다면 (system-reminder의 "Attribution for git commits" 등) 본문 뒤에 그대로 붙인다. 예:

```
Co-Authored-By: Claude Sonnet 5 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_XXXX
```

지침이 없다면 attribution 라인을 임의로 추가하지 않는다.

## 실행 규칙

- 사용자가 명시적으로 커밋을 요청했을 때만 커밋한다 (CLAUDE.md Core Principles 참조).
- `git add`는 관련 파일만 지정해서 스테이징한다 (`-A`/`.` 금지).
- 커밋 전 `git status`/`git diff`로 의도치 않은 파일(예: `.env`, 자격증명)이 섞이지 않았는지 확인한다.
- 메시지는 HEREDOC으로 전달해 포맷을 보존한다.
