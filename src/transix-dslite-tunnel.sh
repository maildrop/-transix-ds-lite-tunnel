#!/bin/sh
# 
#
#

dslite_tunnel(){
    local verb=$1
    local id=$2
    local local_addr=$3
    local remote_addr=$4
    local device=tun$id
    local v4addr=192.168.128.$(expr $id + 1)
    local v4netmask=32
    local table_name=dslite$id
    
    case $1 in
        up)
            # $v4addr/$v4netmask
            echo $verb $id $v4addr $local_addr $remote_addr
            ip -6 tunnel add $device mode ip4ip6 local $local_addr remote $remote_addr encaplimit none
            /usr/sbin/sysctl -w net.ipv6.conf.$device.disable_ipv6=1
            ip -6 link set $device up 
            ip route add $v4addr/$v4netmask dev $device scope link proto kernel table $table_name
            ip route add default via $v4addr dev $device table $table_name
            ip rule add from $v4addr table dslite$id
            ip address add $v4addr/$v4netmask dev $device
            echo tunnel up finished. 
            ;;
        down)
            echo $verb $id $v4addr $local_addr $remote_addr
            ip rule delete from $v4addr table dslite$id
            ip route del default via $v4addr dev $device table $table_name
            ip route del $v4addr/$v4netmask dev $device scope link proto kernel table $table_name

            ip address del $v4addr/$v4netmask dev $device
            ip -6 link set $device down 
            ip -6 tunnel del $device mode ip4ip6 local $local_addr remote $remote_addr encaplimit none
            ;;
        *)
            ;;
    esac 
}

tunnel_id=0
local_addr=$(ip -one -6 -color=never addr show scope global -dynamic up | awk '{ print $4 ; }' | sed 's/\/[[:digit:]]\+//g')
/usr/bin/sleep 5s
for remote_addr in $(host -t aaaa gw.transix.jp | awk '{print $5;}' ) ; do
    dslite_tunnel $1 ${tunnel_id} $local_addr $remote_addr
    tunnel_id=$(expr $tunnel_id + 1)
done
/usr/bin/sleep 5s
