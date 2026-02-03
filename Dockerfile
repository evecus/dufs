# 启动命令：允许上传、搜索、删除、预览，并开启认证
# @/ 表示根目录，:rw 表示读写权限
ENTRYPOINT ["bash", "-c", "dufs /data -p 5000 -a $USER:$PASSWORD@/:rw"]
# 如果没有 bash，改用 sh
# ENTRYPOINT ["sh", "-c", "dufs /data -p 5000 -a ${USER}:${PASSWORD}@/:rw"]
FROM alpine:latest AS fetcher

ARG DUFS_VERSION=0.43.0
WORKDIR /tmp
RUN apk add --no-cache curl tar

# 自动匹配架构下载
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64)  BUILD="x86_64-unknown-linux-musl" ;; \
      aarch64) BUILD="aarch64-unknown-linux-musl" ;; \
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    curl -LO "https://github.com/sigoden/dufs/releases/download/v${DUFS_VERSION}/dufs-v${DUFS_VERSION}-${BUILD}.tar.gz" && \
    tar -xzf "dufs-v${DUFS_VERSION}-${BUILD}.tar.gz" && \
    mv dufs /usr/local/bin/

FROM alpine:latest
# 安装 sh 运行环境需要的依赖
RUN apk add --no-cache ca-certificates

COPY --from=fetcher /usr/local/bin/dufs /usr/local/bin/dufs

WORKDIR /data

# 默认环境变量
ENV USER=admin
ENV PASSWORD=password

EXPOSE 5000

# 修复后的启动命令：确保 dufs 是命令，/data 是参数
# 使用 -A 启用所有功能（上传、删除、搜索等）
ENTRYPOINT ["sh", "-c", "dufs /data -p 5000 -a ${USER}:${PASSWORD}@/:rw -A"]
