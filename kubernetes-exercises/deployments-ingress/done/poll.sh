#! /bin/sh
#check if any parameters are passed
if [ $# -eq 0 ]
then
    echo "No arguments supplied, please pass the ip address of the server"
    echo "And remember the port as well"
    exit 1
fi
while true; do  curl --connect-timeout 1 -m 1 -s $1; sleep 0.5; done