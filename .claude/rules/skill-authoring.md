# 스킬 작성 규칙 — Agent Skills 명세

<!-- claude-drafted: 2026-11-02 -->

1. 스킬은 `.claude/skills/<name>/SKILL.md`에 위치하며 YAML 머리말(`name`, `description`)로 시작합니다.
2. `name`은 소문자·숫자·하이픈(1~64자)이며 폴더 이름과 같아야 합니다.
3. `description`은 무엇을 하는지와 언제 쓰는지(자연어 트리거 문구)를 함께 적습니다.
4. 작성·수정 후 `bash .claude/hooks/check-skills.sh`로 검증합니다.
