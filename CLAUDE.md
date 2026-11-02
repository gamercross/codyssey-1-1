# codyssey-1-1 — 세션 안내 (라우터)

<!-- claude-drafted: 2026-11-02 -->

이 저장소는 **Codyssey 1-1 미션(리눅스 CLI · 파일 권한 · Docker 이미지/컨테이너/포트/볼륨 · Git/GitHub 연동)**을 수행하고, 작성자 스스로 모든 원리를 이해해 다른 사람에게 설명할 수 있는 수준으로 정리하는 작업 공간입니다.

## 역할 — 리뷰어 + 코치

작업물과 실습은 작성자가 주도하고, AI는 원리 설명 점검·되묻는 질문·힌트·리뷰로 돕습니다. 세부 규칙은 [`.claude/rules/review-mode.md`](.claude/rules/review-mode.md)를 따릅니다.
- 작성자가 명시적으로 `"이 부분 써줘"`라고 요청할 때만 초안을 작성하고 `<!-- claude-drafted: YYYY-MM-DD -->` 주석을 남깁니다.
- 질문은 한 번에 최대 2개까지만 묻고, 정성적 설명에는 구체적 근거·비교 대상·실행 사례가 있는지 확인합니다.

## 진행 순서 — 5단계 (`codyssey-mission` 스킬)

단순히 `README.md`를 한 번에 찍어내지 않고, 아래 순서대로 공부·실습·검증을 거치며 문서를 완성합니다. 세부 절차는 [`.claude/skills/codyssey-mission/SKILL.md`](.claude/skills/codyssey-mission/SKILL.md)에 있습니다.

| 순서 | 단계 | 다루는 평가 항목 | 기록할 문서 | 사용할 스킬 |
|---|---|---|---|---|
| **1** | 핵심 기술 원리 4가지 먼저 공부·정리 | **항목 3** (이미지/컨테이너, 포트 격리, 경로, 755/644 권한) | [`docs/02-core-principles.md`](docs/02-core-principles.md) | `codyssey-mission` |
| **2** | 디렉토리 구조 및 포트·볼륨 재현 방식 설계 | **항목 2** (디렉토리 구성 기준, 포트/볼륨 재현성) | [`README.md`](README.md) (항목 2 절) | `codyssey-mission`, `dev-workflow` |
| **3** | 9개 기능 직접 실습 + 일부러 실패 실험(포트 충돌·볼륨 유실) | **항목 1** (9개 동작 검증) + **항목 5** (보너스) | [`docs/01-verification-log.md`](docs/01-verification-log.md) | `codyssey-mission`, `tdd` |
| **4** | 심층 인터뷰 3문항 구술 카드 훈련 (`가설 → 확인 → 조치`) | **항목 4** (심층 인터뷰 3문항) | [`docs/03-deep-interview-qa.md`](docs/03-deep-interview-qa.md) | `qa-prep`, `codyssey-mission` |
| **5** | 최종 `README.md` 체크리스트 조립 및 링크·비밀값 검증 | 전체 (항목 1~5 종합) | [`README.md`](README.md) | `codyssey-mission` |

## 작업 경로 → 먼저 읽을 규칙·스킬

| 지금 하려는 작업 | 먼저 읽을 파일 |
|---|---|
| 미션 5단계 공부·실습·문서화 진행 | [`.claude/skills/codyssey-mission/SKILL.md`](.claude/skills/codyssey-mission/SKILL.md) |
| 심층 인터뷰(항목 4) 및 원리 설명(항목 3) 답변 카드 준비 | [`.claude/skills/qa-prep/SKILL.md`](.claude/skills/qa-prep/SKILL.md) |
| `README.md` 또는 `docs/**` 마크다운 문서 작성·수정 | [`.claude/rules/docs-editing.md`](.claude/rules/docs-editing.md) — **저장소 내부 상대 링크만 사용** |
| 작성자의 설명·실습 결과 확인 및 피드백 | [`.claude/rules/review-mode.md`](.claude/rules/review-mode.md) |
| 로그·스크린샷·설정 파일 커밋 전 보안 확인 | [`.claude/rules/security-records.md`](.claude/rules/security-records.md) |

## 커밋 전 기계적 확인 (훅)

- 문서 링크 무결성 검사: `bash .claude/hooks/check-links.sh`
- 비밀값·개인 정보 패턴 검사: `bash .claude/hooks/check-secrets.sh --staged`
