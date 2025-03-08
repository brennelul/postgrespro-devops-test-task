#!/bin/bash

port1=22
port2=22

# function check_load {
#     echo $(ssh -q root@$1 -p $2 "uptime" | awk -F 'load average:' '{print $2}' | cut -d, -f1 | tr -d ' ')
# }

# function check_mem {
#     echo $(ssh -q root@$1 -p $2 "cat /proc/meminfo | grep MemFree" | awk '{print $2}')
# }

if [[ $# -gt 2 || ! $@ =~ ^[^,]+,[^,]+$ ]]; then echo "Incorrect arguments"; exit 1; fi

server1=$(echo $@ | tr -d ' ' | cut -d, -f1 )
server2=$(echo $@ | tr -d ' ' | cut -d, -f2 )

echo "Checking connection on $server1..."
echo Hostname: $(ssh -q root@$server1 -p $port1 "hostname")
if [ $? -ne 0 ]; then echo "Can't connect to $server1"; exit 1;
else echo "OK"; fi

echo

echo "Checking connection on $server2..."
echo Hostname: $(ssh -q root@$server2 -p $port2 "hostname")
if [ $? -ne 0 ]; then echo "Can't connect to $server2"; exit 1;
else echo "OK"; fi

echo

# bash method of getting master server, alternative for ansible check_load role

# load1=$(check_load $server1 $port1)
# load2=$(check_load $server2 $port2)
# mem1=$(check_mem $server1 $port1)
# mem2=$(check_mem $server2 $port2)

# main_server=$server1 # if mem and load are equal, main_server will be server1 by default

# if [ $load1 == $load2 ]; then
#     if [ $mem1 -gt $mem2 ]; then
#         main_server=$server1
#     else
#         main_server=$server2
#     fi
# elif (( $(echo "$load1 > $load2" | bc -l) )); then
#     main_server=$server1
# else
#     main_server=$server2
# fi

echo "Now running ansible"
ansible-playbook ansible/playbook.yml -i "$server1:$port1,$server2:$port2" -u root

if [ $? -ne 0 ]; then
    echo "Something went wrong while executing playbook..."
    exit 1
else
    echo "Now everything is ready to use!"
fi