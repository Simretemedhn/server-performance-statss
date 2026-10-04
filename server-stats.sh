#!/bin/bash

# ============================================
# Server Performance Stats
# ============================================

# Stop the script if an error occurs,
# an unset variable is used, or a pipeline fails.
set -euo pipefail


# ============================================
# Helper Functions
# ============================================

print_section() {
    echo
    echo "============================================"
    echo "$1"
    echo "============================================"
}


# ============================================
# System Information
# ============================================

print_section "SYSTEM INFORMATION"

echo "Hostname: $(hostname)"

if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Operating System: $PRETTY_NAME"
fi

echo "Kernel: $(uname -r)"

echo "Uptime: $(uptime -p)"

echo "Load Average: $(awk '{print $1, $2, $3}' /proc/loadavg)"


# ============================================
# CPU Usage
# ============================================

print_section "CPU USAGE"

cpu_line=$(grep '^cpu ' /proc/stat)

read -r _ user nice system idle iowait irq softirq steal _ _ <<< "$cpu_line"

idle_time=$((idle + iowait))

total_time=$((user + nice + system + idle + iowait + irq + softirq + steal))

used_time=$((total_time - idle_time))

if [ "$total_time" -gt 0 ]; then
    cpu_usage=$((used_time * 100 / total_time))
else
    cpu_usage=0
fi

echo "Total CPU Usage: ${cpu_usage}%"


# ============================================
# Memory Usage
# ============================================

print_section "MEMORY USAGE"

memory_info=$(free -b | awk '/^Mem:/ {print $2, $3, $7}')

read -r total_memory used_memory available_memory <<< "$memory_info"

if [ "$total_memory" -gt 0 ]; then
    memory_usage=$((used_memory * 100 / total_memory))
else
    memory_usage=0
fi

echo "Total Memory: $(free -h | awk '/^Mem:/ {print $2}')"
echo "Used Memory: $(free -h | awk '/^Mem:/ {print $3}')"
echo "Available Memory: $(free -h | awk '/^Mem:/ {print $7}')"
echo "Memory Usage: ${memory_usage}%"


# ============================================
# Disk Usage
# ============================================

print_section "DISK USAGE"

disk_info=$(df -B1 / | awk 'NR==2 {print $2, $3, $4, $5}')

read -r total_disk used_disk available_disk disk_percentage <<< "$disk_info"

echo "Total Disk: $(df -h / | awk 'NR==2 {print $2}')"
echo "Used Disk: $(df -h / | awk 'NR==2 {print $3}')"
echo "Available Disk: $(df -h / | awk 'NR==2 {print $4}')"
echo "Disk Usage: $disk_percentage"


# ============================================
# Top 5 CPU Processes
# ============================================

print_section "TOP 5 PROCESSES BY CPU USAGE"

ps aux --sort=-%cpu | head -6


# ============================================
# Top 5 Memory Processes
# ============================================

print_section "TOP 5 PROCESSES BY MEMORY USAGE"

ps aux --sort=-%mem | head -6


# ============================================
# Logged-in Users
# ============================================

print_section "LOGGED-IN USERS"

who


# ============================================
# End
# ============================================

echo
echo "============================================"
echo "Server statistics collection completed."
echo "============================================"