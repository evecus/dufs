# 第一阶段：下载二进制文件
FROM alpine:latest AS fetcher

ARG DUFS_VERSION=0.43.0
WORKDIR /tmp
RUN apk add --no-cache curl tar

RUN ARCH=$(uname -m) && \
    case "$ARCH" in \
      x86_64)  BUILD="x86_64-unknown-linux-musl" ;; \
      aarch64) BUILD="aarch64-unknown-linux-musl" ;; \
      *) echo "Unsupported architecture: $ARCH"; exit 1 ;; \
    esac && \
    curl -LO "https://github.com/sigoden/dufs/releases/download/v${DUFS_VERSION}/dufs-v${DUFS_VERSION}-${BUILD}.tar.gz" && \
    tar -xzf "dufs-v${DUFS_VERSION}-${BUILD}.tar.gz" && \
    mv dufs /usr/local/bin/

# 第二阶段：运行阶段
FROM alpine:latest

# 复制二进制文件
COPY --from=fetcher /usr/local/bin/dufs /usr/local/bin/dufs

# 预创建数据目录并确保权限
RUN mkdir -p /data && chmod 777 /data
WORKDIR /data

# 默认环境变量
ENV USER=admin
ENV PASSWORD=password

EXPOSE 5000

# 改用这种写法，直接调用二进制文件，减少 shell 解析错误
# 注意：为了在参数中使用环境变量，我们仍然需要 sh，但这次改写了顺序
ENTRYPOINT ["sh", "-c", "exec dufs /data -p 5000 -a ${USER}:${PASSWORD}@/:rw -A"]
