# claude-drafted: 2026-11-02
FROM nginx:1.27-alpine

# 컨테이너 내부 작업 디렉토리 (절대 경로 사용)
WORKDIR /usr/share/nginx/html

# 호스트의 app/ 폴더 내용을 컨테이너 내부 웹 루트로 복사 (상대 경로 → 절대 경로)
COPY app/ /usr/share/nginx/html/

# 영속 볼륨이 마운트될 데이터 디렉토리 미리 생성 및 권한(755) 설정
RUN mkdir -p /usr/share/nginx/html/data && chmod 755 /usr/share/nginx/html/data

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
