<div align="center">

# 🐳 Codyssey 1-1 — 리눅스 CLI · Docker · Git 기반 재현 가능한 개발 환경 구축
### *Reproducible Dev Workstation with Linux CLI, Docker & Git*

<img src="https://img.shields.io/badge/Mission-Codyssey%201--1-blue?style=for-the-badge">
<img src="https://img.shields.io/badge/Docker-29.2.1-2496ED?style=for-the-badge&logo=docker&logoColor=white">
<img src="https://img.shields.io/badge/Linux-Ubuntu%2022.04-E95420?style=for-the-badge&logo=ubuntu&logoColor=white">
<img src="https://img.shields.io/badge/NGINX-1.27--alpine-009639?style=for-the-badge&logo=nginx&logoColor=white">
<img src="https://img.shields.io/badge/Git-2.50.1-F05032?style=for-the-badge&logo=git&logoColor=white">
<img src="https://img.shields.io/badge/Status-PASS%20(Completed)-brightgreen?style=for-the-badge">

---

</div>

<!-- claude-drafted: 2026-11-02 -->

> **한 줄 요약:** 터미널 기본 명령어와 파일 권한(`chmod`), Docker 이미지 빌드·포트 매핑·볼륨 영속성, Git/GitHub 연동을 직접 실험·검증하고, 누가 클론하더라도 동일한 환경과 데이터를 재현할 수 있도록 설계한 프로젝트입니다.

---

## 실행 환경 요약 (Execution Environment)

| 항목 | 버전 및 환경 정보 | 확인 명령어 |
|---|---|---|
| **Host OS / Shell** | `macOS 26.6.2 (arm64)` / `zsh` | `sw_vers`, `echo $SHELL` |
| **CLI 실습 컨테이너 OS** | `Ubuntu 22.04 LTS (Linux aarch64)` / `bash` | `docker run -it ubuntu:22.04 bash` |
| **Docker Engine** | `Docker version 29.2.1, build a5c7197` | `docker --version`, `docker info` |
| **Git / GitHub CLI** | `git version 2.50.1` / `gh 2.99.0` (`main`) | `git --version`, `gh auth status` |

---

## 문서 지도 (라우터)

이 `README.md`는 **전체 설계 구조(항목 2)와 평가 항목 1~5 달성 요약**을 담고 있으며, 각 항목의 상세 원리 설명·실행 로그·트러블슈팅 과정은 아래 세 문서에 나누어 정리했습니다.

| 문서 | 담고 있는 내용 | 대응 평가 항목 |
|---|---|---|
| **[`docs/01-verification-log.md`](docs/01-verification-log.md)** | 리눅스 CLI · 파일 권한 · Docker · 볼륨 · Git 9개 항목의 실제 실행 명령어와 터미널 출력 흔적 | **항목 1 (기능 동작 검증)** · **항목 5 (보너스)** |
| **[`docs/02-core-principles.md`](docs/02-core-principles.md)** | 이미지 vs 컨테이너, 포트 격리와 매핑, 절대/상대 경로, `755`/`644` 권한 계산 원리 도식 및 정리 | **항목 3 (핵심 기술 원리 적용)** |
| **[`docs/03-deep-interview-qa.md`](docs/03-deep-interview-qa.md)** | 호스트 포트 충돌 진단 순서, 컨테이너 삭제 시 데이터 유실 대안 실험, `가설 → 확인 → 조치` 회고 및 PREP 구술 카드 | **항목 4 (심층 인터뷰)** |

---

## 항목 2. 동작 구조 설계

### 2-1. 프로젝트 디렉토리 구조와 구성 기준

변경 빈도와 역할(코드 / 인프라 설정 / 검증·원리 문서)을 분리하여, 컨테이너 이미지를 다시 빌드할 때 불필요한 레이어 캐시 무효화가 일어나지 않도록 디렉토리를 구성했습니다.

```text
codyssey-1-1/
├── README.md                      # [대문] 구조 설계(항목 2), 빠른 재현 가이드, 평가 체크리스트 라우터
├── Dockerfile                     # [인프라] 커스텀 이미지 빌드 명세 (항목 1-6)
├── docker-compose.yml             # [보너스/재현] 포트·볼륨 설정을 코드로 고정한 선언형 실행 파일 (항목 2-2, 항목 5)
├── app/                           # [애플리케이션] 컨테이너 내부에서 서빙·실행할 대상 파일
│   └── index.html                 # 커스텀 NGINX 컨테이너가 서빙하는 정적 웹 페이지
└── docs/                          # [상세 문서] 실행 흔적·원리·심층 인터뷰 분리 보관
    ├── 01-verification-log.md     # 항목 1 (9개 기능 동작 검증 로그) & 항목 5 (보너스)
    ├── 02-core-principles.md      # 항목 3 (핵심 기술 원리 4가지 도식 및 설명)
    ├── 03-deep-interview-qa.md    # 항목 4 (심층 인터뷰 3문항 실험 근거 및 PREP 답변 카드)
    └── images/                    # 포트 매핑 브라우저 화면 및 Git/GitHub 연동 증거 캡처
```

| 구분 기준 | 폴더/파일 | 왜 이렇게 나눴는가 (설계 근거) |
|---|---|---|
| **인프라 명세 (루트)** | [`Dockerfile`](Dockerfile), [`docker-compose.yml`](docker-compose.yml) | 저장소를 클론한 사람이 루트에서 즉시 빌드(`docker build .`)하고 실행(`docker compose up -d`)할 수 있도록 진입점에 배치 |
| **실행 대상 (`app/`)** | [`app/index.html`](app/index.html) | 컨테이너 내부로 복사(`COPY app/ ...`)할 파일만 격리하여, 문서(`docs/`)가 바뀌어도 Docker 이미지 빌드 캐시가 깨지지 않게 분리 |
| **검증·원리 문서 (`docs/`)** | [`docs/01-verification-log.md`](docs/01-verification-log.md) 외 2건 | 대문(`README.md`)의 가독성을 유지하면서, 실행 흔적(How)과 기술 원리(Why)·트러블슈팅 과정을 독립적으로 추적 가능하게 구성 |

### 2-2. 포트/볼륨 설정을 재현 가능하게 정리한 방식

명령어 옵션을 사람 기억에 의존해 매번 수동 입력하면 포트 번호 오타나 볼륨 누락으로 인한 데이터 유실이 발생합니다. 이를 방지하기 위해 **2단계(단일 명령어 표준화 → 선언형 설정 파일 고정)**로 재현성을 확보했습니다.

```mermaid
flowchart LR
    H["호스트 환경 (Host)<br/>포트: 8080 / 볼륨: codyssey-data"] -->|"-p 8080:80<br/>(포트 매핑)"| C["컨테이너 (Container)<br/>내부 포트: 80"]
    H -->|"-v codyssey-data:/usr/share/nginx/html/data<br/>(볼륨 마운트)"| V["영속 데이터 영역 (/data)<br/>컨테이너 삭제 후에도 유지"]
```

1. **Docker CLI 표준 재현 명령어** (변하지 않는 이름으로 고정):
   ```bash
   # 1. 영속 볼륨 생성
   docker volume create codyssey-data

   # 2. 커스텀 이미지 빌드
   docker build -t codyssey-web:1.0 .

   # 3. 포트 매핑(-p 8080:80)과 볼륨 마운트(-v codyssey-data:/usr/share/nginx/html/data)로 실행
   docker run -d --name codyssey-app -p 8080:80 -v codyssey-data:/usr/share/nginx/html/data codyssey-web:1.0
   ```
2. **[`docker-compose.yml`](docker-compose.yml) 코드화 (Infrastructure as Code)**:
   - 프로젝트 이름(`name: codyssey-1-1`), 포트 매핑(`8080:80`), Named Volume(`codyssey-data`)을 [`docker-compose.yml`](docker-compose.yml)에 명시하여, 어느 컴퓨터·어느 폴더명에서든 `docker compose up -d` 한 줄로 동일한 네트워크·스토리지 구성을 재현합니다.

---

## 평가 체크리스트 달성 현황 (항목 1 ~ 5)

> 모든 항목을 직접 실습·실험하여 검증을 완료했으며, 각 항목의 상세 로그와 설명은 오른쪽 상대 링크에서 바로 확인할 수 있습니다.

### 항목 1. 기능 동작 검증 → 상세 흔적: [`docs/01-verification-log.md`](docs/01-verification-log.md)
- [x] 터미널에서 기본 명령어로 폴더/파일 생성·이동·삭제를 수행한 흔적이 있는가? — `mkdir`, `touch`, `cp`, `mv`, `rm`, `ls -la` 전체 생명주기 로그 기록 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-1절)
- [x] 파일 권한 변경 결과가 확인되는가? — `hello.sh`에 `chmod 644`(`Permission denied`) 후 `chmod 755` 변경 및 실행 성공 비교 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-2절)
- [x] `docker --version`이 출력되고, Docker가 동작 가능한 상태인가? — `Docker version 29.2.1` 및 `docker info` Server 정상 응답 확인 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-3절)
- [x] `docker run hello-world`가 정상 실행되는가? — `Hello from Docker!` 출력 및 4단계 동작 흐름 확인 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-4절)
- [x] 이미지/컨테이너 목록 확인 및 정리 흔적이 있는가? — `docker ps -a`, `docker images` 조회 후 `docker rm` → `docker rmi` 정리 전후 비교 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-5절)
- [x] `Dockerfile`로 이미지 빌드가 가능한가? — [`Dockerfile`](Dockerfile)로 `codyssey-web:1.0`(`bbcb31fc5683`, `49.7MB`) 빌드 성공 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-6절)
- [x] 매핑된 포트로 접속이 가능한가? — `-p 8080:80` 실행 후 `curl -i http://localhost:8080` `200 OK` 응답 및 브라우저 캡처([`docs/images/port-8080.png`](docs/images/port-8080.png)) 확인 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-7절)
- [x] Docker 볼륨 데이터가 컨테이너 삭제 후에도 유지되는가? — `codyssey-data` 볼륨 마운트 후 `vol-test-1` 강제 삭제(`docker rm -f`) 뒤 `vol-test-2`에서 `persist.txt` 유지 확인 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-8절)
- [x] Git 설정 및 GitHub 연동이 확인되는가? — `git config`, `git remote -v`, `gh auth status`(마스킹 완료) 및 연동 캡처([`docs/images/git-github-sync.png`](docs/images/git-github-sync.png)) 첨부 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 1-9절)

**결과:** `PASS`

---

### 항목 2. 동작 구조 설계 → 위 [항목 2. 동작 구조 설계](#항목-2-동작-구조-설계) 절
- [x] 프로젝트 디렉토리 구조를 어떤 기준으로 구성했는지 설명할 수 있는가? — 인프라 명세(루트), 웹 자산(`app/`), 검증·원리 문서(`docs/`)를 변경 빈도와 빌드 캐시 격리 기준으로 분리
- [x] 포트/볼륨 설정을 어떤 방식으로 재현 가능하게 정리했는지 설명할 수 있는가? — 고정된 CLI 표준 명령어와 [`docker-compose.yml`](docker-compose.yml) 선언형 파일 2단계로 코드화

**결과:** `PASS`

---

### 항목 3. 핵심 기술 원리 적용 → 상세 설명: [`docs/02-core-principles.md`](docs/02-core-principles.md)
- [x] 이미지와 컨테이너의 차이를 "빌드/실행/변경" 관점에서 구분해 설명할 수 있는가? — 읽기 전용 불변 스냅샷(이미지) vs 임시 RW 레이어가 얹힌 격리 프로세스(컨테이너) 비교 완료 ([`docs/02-core-principles.md`](docs/02-core-principles.md) 3-1절)
- [x] 컨테이너 내부 포트로 직접 접속할 수 없는 이유와 포트 매핑이 필요한 이유를 설명할 수 있는가? — 네트워크 네임스페이스 격리 원리와 `-p 호스트:컨테이너` 포트 포워딩 구조 정리 완료 ([`docs/02-core-principles.md`](docs/02-core-principles.md) 3-2절)
- [x] 절대 경로/상대 경로를 어떤 상황에서 선택하는지 설명할 수 있는가? — 컨테이너 내부 고정 경로(절대 경로) vs 저장소 이식성 확보(상대 경로) 선택 기준 정리 완료 ([`docs/02-core-principles.md`](docs/02-core-principles.md) 3-3절)
- [x] 파일 권한 숫자 표기(예: `755`, `644`)가 어떤 규칙으로 결정되는지 설명할 수 있는가? — `r(4)+w(2)+x(1)` 주체별 합산 규칙 및 실행/진입 비트(`x`) 역할 증명 완료 ([`docs/02-core-principles.md`](docs/02-core-principles.md) 3-4절)

**결과:** `PASS`

---

### 항목 4. 심층 인터뷰 → 상세 실험·답변 카드: [`docs/03-deep-interview-qa.md`](docs/03-deep-interview-qa.md)
- [x] "호스트 포트가 이미 사용 중"이라 포트 매핑이 실패한다면, 어떤 순서로 원인을 진단할지 설명할 수 있는가? — `port is already allocated` 에러 재현 후 `docker ps --filter publish=8080` → `lsof -i :8080` → `-p 8081:80` 분리 조치 실험 및 PREP 카드 완성 ([`docs/03-deep-interview-qa.md`](docs/03-deep-interview-qa.md) 4-1절)
- [x] 컨테이너 삭제 후 데이터가 사라진 경험이 있다면, 이를 방지하기 위한 대안을 설명할 수 있는가? — 볼륨 미사용 시 유실(`ephemeral-test`) vs Named Volume 보존(`codyssey-data`) 비교 실험 및 PREP 카드 완성 ([`docs/03-deep-interview-qa.md`](docs/03-deep-interview-qa.md) 4-2절)
- [x] 이 미션에서 가장 어려웠던 지점과 해결 과정(`가설 → 확인 → 조치`)을 근거와 함께 설명할 수 있는가? — 한글 디렉토리(`미션-수행`)에서 발생한 `project name must not be empty` 에러 원인 규명 및 `name: codyssey-1-1` 고정 조치 기록 완료 ([`docs/03-deep-interview-qa.md`](docs/03-deep-interview-qa.md) 4-3절)

**결과:** `PASS`

---

### 항목 5. 보너스 문제 해결에 따른 크레딧 부여 → 상세 기록: [`docs/01-verification-log.md`](docs/01-verification-log.md)
- [x] 보너스 과제 수행 및 검증 기록 — [`docker-compose.yml`](docker-compose.yml) 작성 및 `docker compose up -d`, `ps`, `curl`, `down` 전체 생명주기 실행 로그 검증 완료 ([`docs/01-verification-log.md`](docs/01-verification-log.md) 항목 5절)

**결과:** `부여`

---

<div align="center">

# 🎉 Mission Complete

**Codyssey 1-1 — Reproducible Development Workstation**

*"원리를 이해하고 코드로 고정한 환경은 어디서든 동일하게 재현됩니다."*

</div>
