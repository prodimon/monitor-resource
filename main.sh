#!/bin/bash
#

DBDIR=db
MODULEDIR=module
IMGDIR=img
REPORTDIR=report

mkdir -p $DBDIR $IMGDIR $REPORTDIR

for i in `ls ./$MODULEDIR/*.sh`
do
	source $i
	creat_db
	update_rrd
	creat_img 1day -1day 1839 720 svg
#	creat_img 1hour -1hour 1839 720 svg
#	creat_img 8hour -8hour 1839 720 svg
done

if [ "$1" == "report" ] && [ "$2" != "" ] && [ "$3" != "" ]
then
	mkdir -p $REPORTDIR
	EMAILREPORT=$3
	REPORTDATE=`date '+%H%M%d%m%Y'`
	REPORTFILE=$REPORTDIR/$REPORTDATE-$2.pdf

	if [ "$2" == "1day" ] || [ "$2" == "7day" ] || [ "$2" == "8hour" ] || [ "$2" == "1hour" ]
	then
		for i in `ls ./$MODULEDIR/*.sh`
		do
			source $i
			creat_img $2 -$2 1440 500 png
		done	

		IMG=`find $IMGDIR/$2/ -name "*.png"`
		if [ "$IMG" != "" ]
		then
			convert $IMG $REPORTFILE
			echo `date` | mail -s "report" -A $REPORTFILE $EMAILREPORT
		fi
	fi
fi

