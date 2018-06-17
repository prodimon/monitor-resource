name=sda
DATABASE=$DBDIR/$name.rrd
IMG=$name.svg
RRDTOOL=/usr/bin/rrdtool
PERIOD=30

function creat_db {
	if ! [ -f $DATABASE ]
        then
			$RRDTOOL create $DATABASE -s $PERIOD \
			DS:rbyte:COUNTER:600:U:U \
			DS:rcount:COUNTER:600:U:U \
			DS:wbyte:COUNTER:600:U:U \
			DS:wcount:COUNTER:600:U:U \
			RRA:AVERAGE:0.5:1:2880 \
			RRA:AVERAGE:0.5:5:4032 \
			RRA:AVERAGE:0.5:15:5760 \
			RRA:AVERAGE:0.5:120:8640 \
			RRA:MAX:0.5:1:2880 \
			RRA:MAX:0.5:5:4032 \
			RRA:MAX:0.5:15:5760 \
			RRA:MAX:0.5:120:8640
		fi
		
}

function update_rrd {
	DATA1=$(($(cat /proc/diskstats | grep "$name " | awk '{print $6}')*512)) #byte read
	DATA2=`cat /proc/diskstats | grep "$name " | awk '{print $4}'` #count read
	DATA3=$(($(cat /proc/diskstats | grep "$name " | awk '{print $10}')*512)) #byte write
	DATA4=`cat /proc/diskstats | grep "$name " | awk '{print $8}'` #count write
	$RRDTOOL update $DATABASE N:$DATA1:$DATA2:$DATA3:$DATA4
}

function creat_img {
	mkdir -p $IMGDIR/$1/$name/
	$RRDTOOL graph $IMGDIR/$1/$name/byte-$IMG \
		-s $2 \
		-e now \
		-a SVG \
		-t "$(hostname) $name byte/s" \
		-r \
		-E \
		-i \
		-R light \
		--zoom 1 \
		-w $3 \
		-h $4 \
		DEF:var1=$DATABASE:rbyte:AVERAGE \
		DEF:var2=$DATABASE:wbyte:AVERAGE \
		DEF:mvar1=$DATABASE:rbyte:MAX \
		DEF:mvar2=$DATABASE:wbyte:MAX \
		COMMENT:"$name" \
		AREA:var1#FF6A00:"read" \
		LINE1:var2#0F9BFF:"write\r" \
		COMMENT:"cur" \
		GPRINT:var1:LAST:'%6.0lf %sB/s' \
		GPRINT:var2:LAST:'%6.0lf %sB/s\r' \
		COMMENT:"avr" \
		GPRINT:var1:AVERAGE:'%6.0lf %sB/s' \
		GPRINT:var2:AVERAGE:'%6.0lf %sB/s\r' \
		COMMENT:"max" \
		GPRINT:mvar1:MAX:'%6.0lf %sB/s' \
		GPRINT:mvar2:MAX:'%6.0lf %sB/s\r'
		
	$RRDTOOL graph $IMGDIR/$1/$name/count-$IMG \
		-s $2 \
		-e now \
		-a SVG \
		-t "$(hostname) $name iops" \
		-r \
		-E \
		-i \
		-R light \
		--zoom 1 \
		-w $3 \
		-h $4 \
		DEF:var1=$DATABASE:rcount:AVERAGE \
		DEF:var2=$DATABASE:wcount:AVERAGE \
		DEF:mvar1=$DATABASE:rcount:MAX \
		DEF:mvar2=$DATABASE:wcount:MAX \
		COMMENT:"$name" \
		AREA:var1#FF6A00:"read" \
		LINE1:var2#0F9BFF:"write\r" \
		COMMENT:"cur" \
		GPRINT:var1:LAST:'%6.0lf n/s' \
		GPRINT:var2:LAST:'%6.0lf n/s\r' \
		COMMENT:"avr" \
		GPRINT:var1:AVERAGE:'%6.0lf n/s' \
		GPRINT:var2:AVERAGE:'%6.0lf n/s\r' \
		COMMENT:"max" \
		GPRINT:mvar1:MAX:'%6.0lf n/s' \
		GPRINT:mvar2:MAX:'%6.0lf n/s\r'
}
