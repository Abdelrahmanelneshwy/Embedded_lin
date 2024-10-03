#!/usr/bin/bash -i

# Configuration file
CONFIG_FILE="./process_monitor.conf"

# Default values if not specified in the configuration file
UPDATE_INTERVAL=5
CPU_ALERT_THRESHOLD=90
MEMORY_ALERT_THRESHOLD=80

# Load configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Log file
LOG_FILE="./process_monitor.log"

# Function to log activities
log_activity() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Function to list running processes
list_processes() {
    # List the top 15 processes sorted by CPU usage
    ps aux --sort=-%cpu | awk '{ printf "%-10s %-15s %-5s %-5s %-10s %-10s\n", $2, $1, $3, $4, $11, $13 }' \
    | head -n 15    
}

# Function to get detailed information about a specific process
process_info() {
    echo -n "Enter PID of the process: "
    read pid
    ps -p "$pid" -o pid,ppid,uid,%cpu,%mem,cmd
}

# Function to kill a process
kill_process() {
    echo -n "Enter PID of the process to kill: "
    read pid
    if kill "$pid"; then
        log_activity "Process $pid killed."
        echo "Process $pid terminated."
    else
        echo "Failed to terminate process $pid."
    fi
}

# Function to display process statistics
process_statistics() {
    echo "System Process Statistics:"
    total_processes=$(ps -e --no-headers | wc -l)
    cpu_load=$(uptime | awk -F 'load average:' '{ print $2 }')
    memory_usage=$(free -m | awk 'NR==2{printf "%.2f%%", $3*100/$2 }')

    echo "Total processes: $total_processes"
    echo "CPU load (1, 5, 15 min):$cpu_load"
    echo "Memory usage: $memory_usage"
}

# Function for real-time monitoring
real_time_monitoring() {
    echo "Real-time Monitoring (Ctrl+C to exit)..."
    while true; do
    tput cup 0 0  # Move cursor to top-left corner of the terminal
    echo "PID        USER           %CPU  %MEM   COMMAND   ARGS"
    
    # List the top 15 processes sorted by CPU usage
    ps aux --sort=-%cpu | awk '{ printf "%-10s %-15s %-5s %-5s %-10s %-10s\n", $2, $1, $3, $4, $11, $13 }' \
    | head -n 15 

    echo ""
    echo "Press 'q' to quit the process monitor."
    
    # Check for user input, refresh every 1 second
    read -t 1 -n 1 input
    if [[ $input = "q" ]]; then
        echo "Exiting process monitor..."
        break
    fi
    done
}

# Function to search and filter processes
search_process() {
    echo -n "Enter the name or criteria for filtering: "
    read filter
    ps aux | grep -i "$filter" | grep -v "grep"
}

# Resource usage alert function
check_resource_alerts() {
    ps aux --sort=-%cpu | awk -v cpu_threshold="$CPU_ALERT_THRESHOLD" -v mem_threshold="$MEMORY_ALERT_THRESHOLD" '
    $3 > cpu_threshold || $4 > mem_threshold { printf "Alert: Process %s (PID: %s) exceeds CPU (%.2f%%) or Memory (%.2f%%) threshold\n", $11, $2, $3, $4 }'
}

# Function for interactive menu
interactive_mode() {
    while true; do
        echo "Process Monitor Menu:"
        echo "1. List Running Processes"
        echo "2. View Detailed Process Information"
        echo "3. Kill a Process"
        echo "4. View Process Statistics"
        echo "5. Real-time Monitoring"
        echo "6. Search for Processes"
        echo "7. Check Resource Usage Alerts"
        echo "8. Exit"
        echo -n "Choose an option: "
        read choice

        case $choice in
            1) list_processes ;;
            2) process_info ;;
            3) kill_process ;;
            4) process_statistics ;;
            5) real_time_monitoring ;;
            6) search_process ;;
            7) check_resource_alerts ;;
            8) exit 0 ;;
            *) echo "Invalid option. Please try again." ;;
        esac
    done
}

# Start the script in interactive mode
interactive_mode

