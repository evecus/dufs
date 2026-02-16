# 使用轻量的 Alpine Linux 作为基础镜像
FROM alpine:latest

# 设置 dufs 版本和架构变量（由 Docker Buildx 自动传入）
ARG DUFS_VERSION=0.41.0
ARG TARGETARCH

# 安装必要的工具
RUN apk add --no-cache wget tar

# 下载并安装符合当前架构的 dufs 二进制文件
RUN ARCH=${TARGETARCH} && \
    if [ "$ARCH" = "amd64" ]; then \
        DUFS_ARCH="x86_64"; \
    elif [ "$ARCH" = "arm64" ]; then \
        DUFS_ARCH="aarch64"; \
    else \
        echo "Unsupported architecture: $ARCH" && exit 1; \
    fi && \
    wget "https://github.com/sigoden/dufs/releases/download/v${DUFS_VERSION}/dufs-v${DUFS_VERSION}-${DUFS_ARCH}-unknown-linux-musl.tar.gz" && \
    tar -xzf "dufs-v${DUFS_VERSION}-${DUFS_ARCH}-unknown-linux-musl.tar.gz" && \
    mv dufs /usr/local/bin/ && \
    chmod +x /usr/local/bin/dufs && \
    rm "dufs-v${DUFS_VERSION}-${DUFS_ARCH}-unknown-linux-musl.tar.gz"

# 创建数据存储目录
RUN mkdir -p /data
WORKDIR /data

# 设置默认环境变量（可以在 docker run 时通过 -e 覆盖）
ENV ADMIN_USER=admin
ENV ADMIN_PASS=123456

# 暴露 Dufs 默认端口
EXPOSE 5000

# 使用 shell 形式启动，以便解析环境变量
# 权限逻辑说明：
# 1. -a ${ADMIN_USER}:${ADMIN_PASS}@/:rw -> 为 admin 开启根目录的读写权限
# 2. 默认情况下，未登录用户（Guest）自动获得只读权限
# 3. --allow-search -> 允许所有人（包括 Guest）搜索文件
ENTRYPOINT ["sh", "-c", "/usr/local/bin/dufs /data --bind 0.0.0.0 --port 5000 --auth ${ADMIN_USER}:${ADMIN_PASS}@/:rw --allow-search --allow-archive"]
