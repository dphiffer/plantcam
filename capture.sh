#!/bin/bash

width="1920"
height="1440"
quality="70"
min_time="80000"    # start at 8am
max_time="230000"   # end at 11pm

lockfile="/tmp/capture.lock"
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

	images="$basedir/images/$location"

	if [ ! -d "$images" ] ; then
		mkdir -p "$images"
	fi
	
	logs="$basedir/logs"
	
	if [ ! -d "$logs" ] ; then
		mkdir -p "$logs"
	fi

	date=`date +%Y%m%d`
	time=`date +%H%M%S`
	log_date=`date +%Y-%m-%d`
	comp_time=`echo $time | sed 's/^0*//'`
	logfile="$logs/$location-capture-$log_date.log"
	
	{
		if (( $comp_time > $min_time )) && (( $comp_time < $max_time )) ; then

				jpg_file="$location-$date-$time.jpg"
				echo "$jpg_file"
				
				# Create the date folder if none exists
				if [ ! -d "$images/$date" ] ; then
					mkdir -p "$images/$date"
				fi
				# Capture video
				raspistill \
				    --output "$images/$date/$jpg_file" \
				    --width "$width" \
				    --height "$height" \
				    --nopreview \
				    --quality "$quality"

		fi
	} >> $logfile
	
	# Release lockfile
	rm -f "$lockfile"
	
fi
