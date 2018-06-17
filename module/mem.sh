name=mem
DATABASE=$DBDIR/$name.rrd
IMG=$name.svg
RRDTOOL=/usr/bin/rrdtool
PERIOD=30

TMP_DATA1=`cat /proc/meminfo | grep SwapTotal | awk '{print $2 0 0 0}'` #SwapTotal
TMP_DATA2=`cat /proc/meminfo | grep SwapFree | awk '{print $2 0 0 0}'` #SwapFree

DATA1=`cat /proc/meminfo | grep MemTotal | awk '{print $2 0 0 0}'` #MemTotal
DATA2=`cat /proc/meminfo | grep Buffers | awk '{print $2 0 0 0}'` #Buffers 
DATA3=`cat /proc/meminfo | grep SwapCached | awk '{print $2 0 0 0}'` #SwapCached 
DATA4=`cat /proc/meminfo | grep Active: | awk '{print $2 0 0 0}'` #Active
DATA5=`cat /proc/meminfo | grep Inactive: | awk '{print $2 0 0 0}'` #Inactive
DATA6=$(($TMP_DATA1-$TMP_DATA2)) #SwapUsed


function creat_db {
	if ! [ -f $DATABASE ]
        then
                $RRDTOOL create $DATABASE -s $PERIOD \
				DS:memt:GAUGE:600:0:U \
				DS:buf:GAUGE:600:0:U \
				DS:swc:GAUGE:600:0:U \
				DS:act:GAUGE:600:0:U \
				DS:inact:GAUGE:600:0:U \
				DS:swu:GAUGE:600:0:U \
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
	$RRDTOOL update $DATABASE N:$DATA1:$DATA2:$DATA3:$DATA4:$DATA5:$DATA6
}

function creat_img {
	mkdir -p $IMGDIR/$1/
	$RRDTOOL graph $IMGDIR/$1/$IMG \
		-s $2 \
		-e now \
		-a SVG \
		-t "$(hostname) $name" \
		-r \
		-E \
		-i \
		-R light \
		--zoom 1 \
		-w $3 \
		-h $4 \
		DEF:var1=$DATABASE:memt:AVERAGE \
		DEF:var2=$DATABASE:buf:AVERAGE \
		DEF:var3=$DATABASE:swc:AVERAGE \
		DEF:var4=$DATABASE:act:AVERAGE \
		DEF:var5=$DATABASE:inact:AVERAGE \
		DEF:var6=$DATABASE:swu:AVERAGE \
		DEF:mvar1=$DATABASE:memt:MAX \
		DEF:mvar2=$DATABASE:buf:MAX \
		DEF:mvar3=$DATABASE:swc:MAX \
		DEF:mvar4=$DATABASE:act:MAX \
		DEF:mvar5=$DATABASE:inact:MAX \
		DEF:mvar6=$DATABASE:swu:MAX \
		COMMENT:"mem" \
		LINE2:var2#FFD000:"Buffers" \
		STACK:var4#0A99FF:"Active" \
		STACK:var5#5D00FF:"Inactive" \
		LINE1:var3#6AFF00:"SWCached" \
		LINE1:var6#FF00FB:"SWUsed" \
		LINE1:var1#FF5500:"Total\r" \
		COMMENT:"cur" \
		GPRINT:var2:LAST:'%6.0lf %sB' \
		GPRINT:var4:LAST:'%6.0lf %sB' \
		GPRINT:var5:LAST:'%6.0lf %sB' \
		GPRINT:var3:LAST:'%6.0lf %sB' \
		GPRINT:var6:LAST:'%6.0lf %sB' \
		GPRINT:var1:LAST:'%6.0lf %sB\r' \
		COMMENT:"avr" \
		GPRINT:var2:AVERAGE:'%6.0lf %sB' \
		GPRINT:var4:AVERAGE:'%6.0lf %sB' \
		GPRINT:var5:AVERAGE:'%6.0lf %sB' \
		GPRINT:var3:AVERAGE:'%6.0lf %sB' \
		GPRINT:var6:AVERAGE:'%6.0lf %sB' \
		GPRINT:var1:AVERAGE:'%6.0lf %sB\r' \
		COMMENT:"max" \
		GPRINT:mvar2:MAX:'%6.0lf %sB' \
		GPRINT:mvar4:MAX:'%6.0lf %sB' \
		GPRINT:mvar5:MAX:'%6.0lf %sB' \
		GPRINT:mvar3:MAX:'%6.0lf %sB' \
		GPRINT:mvar6:MAX:'%6.0lf %sB' \
		GPRINT:mvar1:MAX:'%6.0lf %sB\r'
}
