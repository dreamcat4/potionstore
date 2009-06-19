#!/bin/bash

# Kill previous instance of server from last session

echo "" > "log/QWCLog.txt"

if [ "$?" ]; then
	# sort out log files	
	mv "log/development.log" "log/development.log.log"
	ln -s "log/QWCLog.txt" "log/development.log"
	
	mv "log/production.log" "log/production.log.log"
	ln -s "log/QWCLog.txt" "log/production.log"

	tail -f "log/QWCLog.txt"
	
	# *and* in background
	script/server thin -e production -p 3001 -d
	# wait 4 seconds
	sleep 4
	vmrun-cmd ~/.vmware/winxp.vmx "C:\Documents and Settings\Administrator\Desktop\qbwc_update_all.exe"
	# wait 2 seconds
	# (optional) kill / shutdown server after session
	
else
	# Fail and Exit
fi

# Switch on the existence of a file
LOCK=/var/run/tunnel-keepalive.pid
echo $$ >LOCK # $$ expands to the process ID of the currently running script.

# start tunnel here

while [ -f $LOCK ]; do
   # Test to see if tunnel is still up, if not: start again
   sleep 5
done


