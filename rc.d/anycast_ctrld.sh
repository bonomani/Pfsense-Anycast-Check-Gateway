#!/bin/sh

### AnyCast Controller Daemon Init Script ###
### Add this file with the Filer package ###
### File: /usr/local/etc/rc.d/anycast_ctrld.sh ###
### Description: AnyCast Controller Daemon Init Script ###
### Permission: 755 ###
### Script/Command: ###
### Execute mode: Background ###

# Set the daemon name
daemon_name="anycast_ctrld"

# Set shell interpreter, daemon shell script file, pid file, and log file paths
shell_path="$(command -v sh)"
daemon_path="/usr/local/bin/$daemon_name"
daemon_script="$daemon_path.sh"
pidfile="/var/run/$daemon_name.pid"
log_file="/var/log/$daemon_name.log"

# Set debug mode (0 for disabled, 1 for enabled)
debug_mode=0

# Function to log messages
log_message() {
    /usr/bin/logger -p daemon.info -t "$daemon_name" "$1"
    [ "$debug_mode" -eq 1 ] && echo "$1"  # Output to console if in debug mode
}

# Function to ensure an executable with the name of the deamon exist (also in /conf/config.xml) as the deamon is a script executed by the shell  
check_shell() {
    if [ ! -f "$daemon_path" ]; then
        if ! cp -p "$shell_path" "$daemon_path"; then
            log_message "Failed to copy $shell_path to $daemon_path. Exiting..."
            exit 1
        fi
        log_message "$shell_path copied successfully to $daemon_path."
    fi
}

# Function to start the daemon
rc_start() {
    check_shell
    if pgrep -f "$daemon_name" >/dev/null 2>&1; then
        log_message "Daemon is already running."
    else
        log_message "Starting daemon"
        (exec "$daemon_path" "$daemon_script" & echo $! > "$pidfile")
        if ! pgrep -f "$daemon_name" >/dev/null 2>&1; then
            sleep 1  # Wait for 1 second if the process failed to start
            if ! pgrep -f "$daemon_name" >/dev/null 2>&1; then
                log_message "Failed to start daemon"
                exit 1
            fi
        fi
        log_message "Daemon started successfully."
    fi
}

# Function to stop the daemon
rc_stop() {
    if pgrep -f "$daemon_name" >/dev/null 2>&1; then
        if [ -f "$pidfile" ]; then
            pid=$(cat "$pidfile")
            log_message "Stopping running daemon"
            kill -TERM "$pid" >/dev/null 2>&1
            sleep 2
            if [ -n "$(ps -p "$pid" -o pid=)" ]; then
                log_message "Daemon with PID $pid is still running after graceful stop attempt, forcing stop."
                kill -9 "$pid" >/dev/null 2>&1
                sleep 1
            fi
            if [ -n "$(ps -p "$pid" -o pid=)" ]; then
                log_message "Failed to stop daemon with PID: $pid. Process still running."
                exit 1
            else
                rm -f "$pidfile"
                log_message "Daemon stopped successfully."
            fi
        else
            log_message "No PID file found. Attempting to stop daemon by name: $daemon_name"
            pkill -f "$daemon_name" >/dev/null 2>&1
            sleep 1
            if pgrep -f "$daemon_name" >/dev/null 2>&1; then
                log_message "Failed to stop daemon by name. Process still running."
                exit 1
            else
                log_message "Daemon stopped successfully."
            fi
        fi
    else
        log_message "Daemon is not running."
    fi
}

# Check the command line argument and perform the corresponding action
case "$1" in
    start)
        rc_start
        ;;
    stop)
        rc_stop
        ;;
    restart)
        rc_stop
        rc_start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart}" >&2
        exit 1
        ;;
esac

exit 0
