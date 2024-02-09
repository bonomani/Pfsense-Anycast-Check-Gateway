#!/usr/local/bin/anycast_ctrld

# AnyCast Controller Daemon
# Add this file with the Filer package
# File: /usr/local/bin/anycast_ctrld.sh
# Description: AnyCast Controller
# Permission: 755
# Script/Command:
# Execute mode: Background

# Define logger command
logger_cmd="/usr/bin/logger -p daemon.info -t anycast_ctrld"

# Function to log messages
log_message() {
    $logger_cmd "$1"
}

# Function to handle TERM signal
handle_term_signal() {
    log_message "Received TERM signal. Performing cleanup and exiting..."
    exit_flag=true
}

# Trap TERM signal and call handle_term_signal function
trap 'handle_term_signal' TERM

# Define other variables
php_cmd="/usr/local/bin/php"
vtysh_cmd="/usr/local/bin/vtysh"
pfSsh_script="/usr/local/sbin/pfSsh.php"
gateway_status_php="$php_cmd $pfSsh_script playback gatewaystatus"
gateway_interface="WAN"
gateway_status="online"
interface="lo0"
enable_cmd="ip ospf area 0"
disable_cmd="no $enable_cmd"
sleep_time="30"
check_interval="10"
last_gw_status=""

# Log script start
log_message "$0 started"

# Flag to signal loop exit
exit_flag=false

# Counter for check interval
check_counter=0

# Main loop
while ! $exit_flag; do
    # Increment check counter
    check_counter=$((check_counter + 1))
    if [ "$check_counter" -ge "$check_interval" ]; then
        check_counter=0
        current_gw_status=$(echo "$($gateway_status_php)" | grep -E "$gateway_interface.*$gateway_status" | wc -l | sed 's/^[ \t]*//')
        if [ "$current_gw_status" != "$last_gw_status" ]; then
            last_gw_status="$current_gw_status"
            check_interval="30"
            if [ "$current_gw_status" = "1" ]; then
                $vtysh_cmd -c "configure terminal" -c "int $interface" -c "$enable_cmd"
                message="$gateway_interface gatewaystatus is $gateway_status, '$enable_cmd' was applied on $interface"
            else
                $vtysh_cmd -c "configure terminal" -c "int $interface" -c "$disable_cmd"
                message="$gateway_interface gatewaystatus is not $gateway_status, '$disable_cmd' was applied on $interface"
            fi
            # Log message
            log_message "$message"
        else
            check_interval="10"
        fi
    fi

    # Sleep for 1 second at the end of the loop
    sleep 1
done

# Perform any necessary cleanup tasks before exiting
log_message "Exiting gracefully..."
exit 0
