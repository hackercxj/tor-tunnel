#!/bin/sh

# 修改此值以启动所需的 Tor 进程数
TOR_INSTANCES=$TorInstanceNum


mkdir -p /etc/tor

for i in $(seq 1 $TOR_INSTANCES); do
  SOCKS_PORT=$((9050 + $i - 1))

  # 为每个 Tor 实例创建一个 torrc 配置文件
  cat << EOF > /etc/tor/torrc-$i
SOCKS5Proxy $PROXY
NewCircuitPeriod 10
MaxCircuitDirtiness 10
SOCKSPort 0.0.0.0:$SOCKS_PORT
DataDirectory /var/lib/tor/instance-$i
EOF
  mkdir -p /var/lib/tor/instance-$i
  chown -R toruser:toruser /var/lib/tor/instance-$i
  chmod -R 700 /var/lib/tor/instance-$i
  # 以后台模式启动 Tor 进程
  gosu toruser tor -f /etc/tor/torrc-$i &
done

# Start OpenResty
echo "Starting OpenResty..."
gosu root openresty -g "daemon off;"

