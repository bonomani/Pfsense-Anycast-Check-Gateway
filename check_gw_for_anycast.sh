#!/bin/sh
if [ 0 != $(pgrep -f $(basename $0) | wc -l) ]; then
 echo "info: another instance of $0 is already running"
 exit 1
fi
echo "info: starting"
last_gw_status="0"
while :
do
  current_gw_status=$(/usr/local/bin/php /usr/local/sbin/pfSsh.php playback gatewaystatus | grep WAN | grep online | wc -l)
  echo $current_gw_status
  if [ $current_gw_status != $last_gw_status ]
    then
    if [ "1" = $current_gw_status ]; then
      /usr/local/bin/vtysh -c "configure terminal" -c "int lo0" -c "ip ospf area 0"
      echo "yes"
    else
      /usr/local/bin/vtysh -c "configure terminal" -c "int lo0" -c "no ip ospf area 0"
      echo "no"
    fi
  fi
  last_gw_status=$current_gw_status
  echo $last_gw_status
  sleep 10
done
