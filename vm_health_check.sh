#!/bin/bash

# Function to get CPU utilization
get_cpu_utilization() {
  mpstat | awk '$12 ~ /[0-9.]+/ { print 100 - $12 }'
}

# Function to get memory utilization
get_memory_utilization() {
  free | grep Mem | awk '{print $3/$2 * 100.0}'
}

# Function to get disk utilization
get_disk_utilization() {
  df / | grep / | awk '{ print $5 }' | sed 's/%//g'
}

# Function to determine VM health
check_vm_health() {
  cpu_util=$(get_cpu_utilization)
  mem_util=$(get_memory_utilization)
  disk_util=$(get_disk_utilization)

  if (( $(echo "$cpu_util < 60" | bc -l) )) && (( $(echo "$mem_util < 60" | bc -l) )) && (( $(echo "$disk_util < 60" | bc -l) )); then
    echo "VM Health: Healthy"
    if [[ $1 == "explain" ]]; then
      echo "Explanation: CPU, Memory, and Disk utilizations are all below 60%."
      echo "CPU Utilization: $cpu_util%"
      echo "Memory Utilization: $mem_util%"
      echo "Disk Utilization: $disk_util%"
    fi
  else
    echo "VM Health: Not Healthy"
    if [[ $1 == "explain" ]]; then
      echo "Explanation: One or more of CPU, Memory, or Disk utilizations are above 60%."
      echo "CPU Utilization: $cpu_util%"
      echo "Memory Utilization: $mem_util%"
      echo "Disk Utilization: $disk_util%"
    fi
  fi
}

# Check if 'explain' argument is passed
if [[ $1 == "explain" ]]; then
  check_vm_health "explain"
else
  check_vm_health
fi
