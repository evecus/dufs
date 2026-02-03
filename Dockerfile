# 第一阶段：下载二进制文件
FROM alpine:latest AS fetcher

# 定义 Dufs 版本
ARG DUFS_VERSION=0.43.0
WORKDIR /tmp

# 安装下载工具
RUN apk add --no-cache curl tar

# 自动识别架构并下载对应的二进制包
RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64)  BUILD="x86_64-unknown-linux-musl" ;; \
      aarch64) BUILD="aarch64-unknown-linux-musl" ;; \
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    curl -LO "https://github.com/sigoden/dufs/releases/download/v${DUFS_VERSION}/dufs-v${DUFS_VERSION}-${BUILD}.tar.gz" && \
    tar -xzf "dufs-v${DUFS_VERSION}-${BUILD}.tar.gz" && \
    mv dufs /usr/local/bin/

# 第二阶段：最终运行镜像
FROM alpine:latest

# 复制二进制文件
COPY --from=fetcher /usr/local/bin/dufs /usr/local/bin/dufs

# 创建数据目录
RUN mkdir -p /data
WORKDIR /data

# 设置环境变量默认值
ENV USER=admin
ENV PASSWORD=password

# 暴露端口
EXPOSE 5000

# 启动命令
# 使用 sh 因为 alpine 默认不带 bash
# -A 开启所有功能 (上传、删除、搜索、预览)
ENTRYPOINT ["sh", "-c", "dufs /data -p 5000 -a ${USER}:${PASSWORD}@/:rw -A"]
