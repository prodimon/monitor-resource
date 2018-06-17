name=cpu
DATABASE=$DBDIR/$name.rrd
RRDTOOL=/usr/bin/rrdtool
PERIOD=30
TMP=`cat /proc/cpuinfo | grep "cpu MHz" | wc -l` #cpus 
DATA1=$(($(cat /proc/stat | head -n1 | cut -d " " -f 3)/$TMP)) #user
DATA2=$(($(cat /proc/stat | head -n1 | cut -d " " -f 4)/$TMP)) #nice
DATA3=$(($(cat /proc/stat | head -n1 | cut -d " " -f 5)/$TMP)) #system
DATA4=$(($(cat /proc/stat | head -n1 | cut -d " " -f 6)/$TMP)) #idle
DATA5=$(($(cat /proc/stat | head -n1 | cut -d " " -f 7)/$TMP)) #iowait


function creat_db {
	if ! [ -f $DATABASE ]
        then
                $RRDTOOL create $DATABASE -s $PERIOD \
				DS:user:COUNTER:600:U:U \
				DS:nice:COUNTER:600:U:U \
				DS:system:COUNTER:600:U:U \
				DS:idle:COUNTER:600:U:U \
				DS:iowait:COUNTER:600:U:U \
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
	$RRDTOOL update $DATABASE N:$DATA1:$DATA2:$DATA3:$DATA4:$DATA5
}

function creat_img {
	$RRDTOOL graph $IMGDIR/$1/$name.$5 \
		-s $2 \
		-e now \
		-a ${5^^} \
		-t "$(hostname) $name %" \
		-r \
		-E \
		-i \
		-R light \
		--zoom 1 \
		-w $3 \
		-h $4 \
		DEF:var1=$DATABASE:user:AVERAGE \
		DEF:var2=$DATABASE:nice:AVERAGE \
		DEF:var3=$DATABASE:system:AVERAGE \
		DEF:var4=$DATABASE:idle:AVERAGE \
		DEF:var5=$DATABASE:iowait:AVERAGE \
		DEF:mvar1=$DATABASE:user:MAX \
		DEF:mvar2=$DATABASE:nice:MAX \
		DEF:mvar3=$DATABASE:system:MAX \
		DEF:mvar4=$DATABASE:idle:MAX \
		DEF:mvar5=$DATABASE:iowait:MAX \
		COMMENT:"cpu" \
		AREA:var3#FF1100:"system" \
		STACK:var5#33cc33:"iowait" \
		STACK:var2#000000:"nice" \
		STACK:var1#FFDD00:"user\r" \
		COMMENT:"cur" \
		GPRINT:var3:LAST:'%7.0lf' \
		GPRINT:var5:LAST:'%7.0lf' \
		GPRINT:var2:LAST:'%7.0lf' \
		GPRINT:var1:LAST:'%7.0lf\r' \
		COMMENT:"avr" \
		GPRINT:var3:AVERAGE:'%7.0lf' \
		GPRINT:var5:AVERAGE:'%7.0lf' \
		GPRINT:var2:AVERAGE:'%7.0lf' \
		GPRINT:var1:AVERAGE:'%7.0lf\r' \
		COMMENT:"max" \
		GPRINT:mvar3:MAX:'%7.0lf' \
		GPRINT:mvar5:MAX:'%7.0lf' \
		GPRINT:mvar2:MAX:'%7.0lf' \
		GPRINT:mvar1:MAX:'%7.0lf\r' 
}
