#!/bin/bash
while true
do
  timeStr=$(date +%y%m%d-%H:%M:%S)

  # mem
  memTotal=`free -m|awk 'NR==2'|awk '{print $2}'`
  memUsed=`free -m|awk 'NR==2'|awk '{print $3}'`
  memFree=`free -m|awk 'NR==2'|awk '{print $3}'`
  memPercent=$(awk 'BEGIN{printf "%.2f",'$memUsed'/'$memTotal'*100}')
#  memStr="MEM:        TOTAL:$memTotal    USED:$memUsed    FREE:$memFree    USED PERCENT:$memPercent"
  memStr="MEM:        TOTAL:$memTotal    USED:$memUsed   USED PERCENT:$memPercent"

  #load
  load=`top -n 1|awk 'NR'==1|awk '{print $12}'`
  loadStr="load: $load"

  #cpu
  cpuUse=`top -n 1|awk 'NR'==3|awk '{print $2}'`
  cpuStr="CPU-us: $cpuUse"

  lineStr="$timeStr : $memStr    $loadStr    $cpuStr"
  dirStr=$1
  echo -e $lineStr >> $dirStr
  sleep 5
done