#!/usr/local/bin/anycast_ctrld

# AnyCast Controller Daemon
# Add this file with the Filer package
# File: /usr/local/bin/anycast_ctrld.sh
# Description: AnyCast Controller
# Permission: 755
# Script/Command:
# Execute mode: Background

name="$0"
logname="anycast_ctrld"
logger_cmd="/usr/bin/logger -p daemon.info -t $logname"
php_cmd="/usr/local/bin/php"
vtysh_cmd="/usr/local/bin/vtysh"
pfSsh_script="/usr/local/sbin/pfSsh.php"
gateway_status_php="$php_cmd $pfSsh_script playback gatewaystatus"
gateway_interface="WAN"
gateway_status="online"
interface="lo0"
sleep_time="30"
check_interval="10"

$logger_cmd "${name} starting"
last_gw_status="0"

while true; do
    current_gw_status=$(echo "$($gateway_status_php)" | grep -E "$gateway_interface.*$gateway_status" | wc -l | sed 's/^[ \t]*//')

    if [ "$current_gw_status" != "$last_gw_status" ]; then
        if [ "$current_gw_status" = "1" ]; then
            $vtysh_cmd -c "configure terminal" -c "int $interface" -c "ip ospf area 0"
            message="${name} gatewaystatus on $gateway_interface is $gateway_status"
        else
            $vtysh_cmd -c "configure terminal" -c "int $interface" -c "no ip ospf area 0"
            message="${name} gatewaystatus on $gateway_interface is not $gateway_status"
        fi

        echo "$message"
        $logger_cmd "$message"
        sleep "$sleep_time"
    fi

    last_gw_status="$current_gw_status"
    sleep "$check_interval"
done
