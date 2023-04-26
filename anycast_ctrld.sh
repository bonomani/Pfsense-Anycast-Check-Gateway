#!/usr/local/bin/anycast_ctrld
# add via Filer package
# File: /usr/local/bin/anycast_ctrld.sh
# Deamon
# Permission: 755

name=$0

/usr/bin/logger -p daemon.info -t $name "${name} starting"
last_gw_status="0"
while :
do
    current_gw_status=$(/usr/local/bin/php /usr/local/sbin/pfSsh.php playback gatewaystatus | grep WAN | grep online | wc -l)
    if [ $current_gw_status != $last_gw_status ]
        then
        if [ "1" = $current_gw_status ]; then
            /usr/local/bin/vtysh -c "configure terminal" -c "int lo0" -c "ip ospf area 0"
            echo "${name} gatewaystatus up"
            /usr/bin/logger -p daemon.info -t $name "${name} gatewaystatus up"
            sleep 30
        else
            /usr/local/bin/vtysh -c "configure terminal" -c "int lo0" -c "no ip ospf area 0"
            echo "${name} gatewaystatus down"
            /usr/bin/logger -p daemon.info -t $name "${name} gatewaystatus down"
            sleep 30
        fi
    fi
    last_gw_status=$current_gw_status
    sleep 10
done
