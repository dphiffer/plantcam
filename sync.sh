#!/bin/bash

upload_server="user@hostname"
upload_path="/var/www/html/plantcam"

lockfile="/tmp/sync.lock"
if ( set -o noclobber; echo "locked" > "$lockfile") 2> /dev/null; then
	
	trap 'rm -f "$lockfile"; exit $?' INT TERM EXIT

	basedir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
	location="nowhere"

	# Don't run if stopped
	if [ -f "$basedir/stopped" ] ; then
		exit 1
	fi

	if [ -f "/etc/hostname" ] ; then
		location=`cat /etc/hostname`
	fi

	date=`date +%Y-%m-%d`
	time=`date +%H:%M:%S`
	logfile="$basedir/logs/$location-sync-$date.log"

	{
		echo "-- $date $time --"

		# Sync video files to server
		rsync \
			--recursive \
			--verbose \
			--ignore-existing \
			--remove-source-files \
			--timeout=30 \
			"$basedir/images/$location/" \
			"$upload_server:$upload_path/$location/"

		# Update scripts
		cd "$basedir" && git pull origin plantcam -q
		
		date=`date +%Y-%m-%d`
		time=`date +%H:%M:%S`
		echo "Finished at $date $time"
	} >> "$logfile"

	# Sync log files
	rsync \
		--recursive \
		--exclude .keep-dir \
		--timeout=30 \
		"$basedir/logs/" \
		"$upload_server:$upload_path/$location/logs/"

	# Release lockfile
	rm -f "$lockfile"

fi
