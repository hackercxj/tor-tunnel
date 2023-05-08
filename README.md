# tor-tunnel

Tor是一个匿名网络,可以帮助用户隐藏真实IP地址,访问被屏蔽网站和保护在线隐私，拥有成千上万个IP地址。

本项目启动多个tor进程，再通过openresty组成隧道代理。

开箱即用:
```shell
docker run -d --name tor-tunnel -p 29000:29000 --env PROXY="" --env TorInstanceNum=5 --restart on-failure whatisl/tor-tunnel:3.4
```
国内使用需要梯子，指定PROXY="192.168.1.102:1086"，即梯子的socks5代理。
支持高并发，可通过TorInstanceNum按需求调节tor进程数量。


测试如下,每次请求的ip会发生变化：
```shell
(base) ╭─wiliam@WiliamdeMacBook-Pro ~
╰─$ curl --proxy socks5://127.0.0.1:29000 https://icanhazip.com
45.151.167.12
(base) ╭─wiliam@WiliamdeMacBook-Pro ~
╰─$ curl --proxy socks5://127.0.0.1:29000 https://icanhazip.com
23.137.251.61
(base) ╭─wiliam@WiliamdeMacBook-Pro ~
╰─$ curl --proxy socks5://127.0.0.1:29000 https://icanhazip.com
87.118.116.103
```

PS: 部分网站是禁止tor代理访问的，不同网站代理的可用率也不一样，各网站可用率需要自行测试。
