ARG VERSION=0.4.7.13
ARG USER=toruser
ARG DIR=/data

FROM openresty/openresty:buster as preparer-base

RUN apt update
RUN apt -y install gpg gpg-agent curl

# Add tor key
ENV KEYS 514102454D0A87DB0767A1EBBE6A0531C18A9179 B74417EDDF22AC9F9E90F49142E86A2A11F48D36 7A02B3521DC75C542BA015456AFEE6D49E92B601

RUN gpg --keyserver keyserver.ubuntu.com --recv-keys $KEYS

RUN gpg --list-keys | tail -n +3 | tee /tmp/keys.txt && \
    gpg --list-keys $KEYS | diff - /tmp/keys.txt

FROM preparer-base AS preparer-release

ARG VERSION

ADD https://dist.torproject.org/tor-$VERSION.tar.gz.sha256sum.asc ./
ADD https://dist.torproject.org/tor-$VERSION.tar.gz.sha256sum ./
ADD https://dist.torproject.org/tor-$VERSION.tar.gz ./

RUN gpg --verify tor-$VERSION.tar.gz.sha256sum.asc
RUN sha256sum -c tor-$VERSION.tar.gz.sha256sum
# Extract
RUN tar -xzf "/tor-$VERSION.tar.gz" && rm  -f   "/tor-$VERSION.tar.gz"

FROM openresty/openresty:buster as builder

ARG VERSION

RUN apt update
RUN apt -y install libevent-dev libssl-dev zlib1g-dev build-essential

WORKDIR /tor-$VERSION/

COPY  --from=preparer-release /tor-$VERSION/  ./

RUN ./configure --sysconfdir=/etc --datadir=/var/lib
RUN make -j$(nproc)
RUN make install

FROM openresty/openresty:buster as final

ARG USER
ARG DIR

# 安装 gosu
RUN apt-get update && \
    apt-get install -y gosu && \
    rm -rf /var/lib/apt/lists/*

# Libraries (linked)
COPY  --from=builder /usr/lib /usr/lib
# Copy all the TOR files
COPY  --from=builder /usr/local/bin/tor*  /usr/local/bin/

COPY openresty/nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

EXPOSE 9050-9059 80 29000

# 将启动脚本添加到容器中
COPY start-tor.sh /usr/local/bin/

ENV PROXY=""
ENV TorInstanceNum=10

RUN adduser --disabled-password "$USER"

ENTRYPOINT ["start-tor.sh"]