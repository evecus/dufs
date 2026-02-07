# Dockerfile
FROM alpine:latest

# 设置 dufs 版本
ARG DUFS_VERSION=0.41.0
ARG TARGETARCH

# 安装必要的工具
RUN apk add --no-cache wget tar

# 下载并安装 dufs 二进制文件
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

# 创建数据目录
RUN mkdir -p /data
RUN chmod 777 /data

# 设置工作目录
WORKDIR /data

# 暴露端口
EXPOSE 5000

# 设置入口点
ENTRYPOINT ["/usr/local/bin/dufs"]

# 默认参数
CMD ["--bind", "0.0.0.0", "--port", "5000"]
