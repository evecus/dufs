FROM alpine:latest AS fetcher

# 定义 Dufs 版本
ARG DUFS_VERSION=0.43.0
WORKDIR /tmp

# 安装依赖用于下载和解压
RUN apk add --no-cache curl tar

# 根据系统架构下载对应的二进制文件
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

# 设置工作目录（文件分享根目录）
WORKDIR /data

# 设置环境变量默认值
ENV USER=admin
ENV PASSWORD=password

# 暴露端口
EXPOSE 5000

# 启动命令：允许上传、搜索、删除、预览，并开启认证
# @/ 表示根目录，:rw 表示读写权限
ENTRYPOINT ["bash", "-c", "dufs /data -p 5000 -a $USER:$PASSWORD@/:rw"]
# 如果没有 bash，改用 sh
# ENTRYPOINT ["sh", "-c", "dufs /data -p 5000 -a ${USER}:${PASSWORD}@/:rw"]
