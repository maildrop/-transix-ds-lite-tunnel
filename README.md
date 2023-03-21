# transix-ds-lite-tunnel
transix.jp の DS-Lite 用のトンネルを作るスクリプト

## モチベーション
 IPoE -  IPv4 over IPv6 サービスである、gw.transx.jp では、帯域が確保できる一方セッション数に限りがある。
 また PPPoE と併用する際に、Flet's は、mtu が 1454 octet である一方 IPoE では、1460 octet になる。
 これら些細な問題に対応するために、一旦LAN内からの要求を squid で受けて、IPoE 経由で外へ流す事を考える。

 このために、ipv4 over ipv6 のトンネルを proxy サーバ内で用意するためのスクリプトを作成し、
 systemd の unit ファイルを作成、
 debian のパッケージにしたので公開する。

## 使い方

make で transix-ds-lite-tunnel_0.0.0_all.deb が作成されるので、
```
apt install ./transix-ds-lite-tunnel_0.0.0_all.deb
```
でインストールする。


## 有効化
```
systemctl enable transix-ds-lite-tunnel.service 
```
で 有効化する。

## 説明

gw.transix.jp
```
$ host gw.transix.jp
gw.transix.jp has IPv6 address 2404:8e00::feed:100
gw.transix.jp has IPv6 address 2404:8e00::feed:101
gw.transix.jp has IPv6 address 2404:8e00::feed:102
```
現在 100 - 102 までが存在し、192.168.128.1 からを割り当てた、トンネルを作成する。
192.168.128.1 が 100 から 102 のどれに割り当てられるかは host コマンドの返す順番に依存する

## up
インターフェースを up するには以下のコマンドで行う
```
/usr/libexec/transix-dslite-tunnel/transix-dslite-tunnel.sh up
```

## 確認

systemd の確認は、
```
systemctl status transix-dslite-tunnel.service
```
で行うことが出来る。

また、ip コマンドで、address の割り当てを確認することができる。
```
ip address show 
```

## down
インターフェースを down するには以下のコマンドで行う
```
/usr/libexec/transix-dslite-tunnel/transix-dslite-tunnel.sh down
```

# ヒント
 セッション数を浪費する多くの原因は、 DNS の UDP パケットであるので、DNS の指定を IPv6 アドレスにする。
 具体的には 8.8.8.8 では無く、2001:4860:4860::8888 を指定し、
 8.8.8.8 や、1.1.1.1 等IPv4アドレスへのパブリックDNSへのアクセスを遮断するか PPPoE 側へルーティングしてやること。
 

