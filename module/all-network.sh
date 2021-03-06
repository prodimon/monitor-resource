RRDTOOL=/usr/bin/rrdtool
PERIOD=30
IFSNETWORKING=`ls /proc/net/dev_snmp6`


function creat_db {

	for IF in $IFSNETWORKING; do
		DATABASE=$DBDIR/$IF.rrd
		if ! [ -f $DATABASE ]
		then
		        $RRDTOOL create $DATABASE -s $PERIOD \
				DS:input:COUNTER:600:0:1000000000000 \
				DS:inpackets:COUNTER:600:0:1000000 \
				DS:inerrors:COUNTER:600:0:1000000 \
				DS:indropped:COUNTER:600:0:1000000 \
				DS:output:COUNTER:600:0:1000000000000 \
				DS:outpackets:COUNTER:600:0:1000000 \
				DS:outerrors:COUNTER:600:0:1000000 \
				DS:outdropped:COUNTER:600:0:1000000 \
				RRA:AVERAGE:0.5:1:2880 \
				RRA:AVERAGE:0.5:5:4032 \
				RRA:AVERAGE:0.5:15:5760 \
				RRA:AVERAGE:0.5:120:8640 \
				RRA:MAX:0.5:1:2880 \
				RRA:MAX:0.5:5:4032 \
				RRA:MAX:0.5:15:5760 \
				RRA:MAX:0.5:120:8640
		fi
	done

	
}

function update_rrd {

	for IF in $IFSNETWORKING; do
		DATABASE=$DBDIR/$IF.rrd
		DATA1=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$2}"); #input
		DATA2=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$3}"); #packets
		DATA3=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$4}"); #errors
		DATA4=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$5}"); #dropped

		DATA5=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$10}"); #output
		DATA6=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$11}"); #packets
		DATA7=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$12}"); #errors
		DATA8=$(cat /proc/net/dev | sed 's/^[ ]*//g' | awk "/^$IF:/ {print \$13}"); #dropped
		$RRDTOOL update $DATABASE N:$DATA1:$DATA2:$DATA3:$DATA4:$DATA5:$DATA6:$DATA7:$DATA8
	done
}

function creat_img {

	for IF in $IFSNETWORKING; do
		DATABASE=$DBDIR/$IF.rrd
		IMG=$IF.$5
		mkdir -p $IMGDIR/$1/$IF/
		$RRDTOOL graph $IMGDIR/$1/$IF/pps-$IMG \
			-s $2 \
			-e now \
			-a ${5^^} \
			-t "$(hostname) $IF pps" \
			-r \
			-E \
			-i \
			-R light \
			--zoom 1 \
			-w $3 \
			-h $4 \
			DEF:var1=$DATABASE:inpackets:AVERAGE \
			DEF:var2=$DATABASE:inerrors:AVERAGE \
			DEF:var3=$DATABASE:indropped:AVERAGE \
			DEF:var4=$DATABASE:outpackets:AVERAGE \
			DEF:var5=$DATABASE:outerrors:AVERAGE \
			DEF:var6=$DATABASE:outdropped:AVERAGE \
			DEF:mvar1=$DATABASE:inpackets:MAX \
			DEF:mvar2=$DATABASE:inerrors:MAX \
			DEF:mvar3=$DATABASE:indropped:MAX \
			DEF:mvar4=$DATABASE:outpackets:MAX \
			DEF:mvar5=$DATABASE:outerrors:MAX \
			DEF:mvar6=$DATABASE:outdropped:MAX \
			COMMENT:"input" \
			LINE1:var1#FF5500:"pac" \
			LINE1:var2#FFD000:"err" \
			LINE1:var3#6AFF00:"drop\r" \
			COMMENT:"cur" \
			GPRINT:var1:LAST:'%4.0lf' \
			GPRINT:var2:LAST:'%4.3lf' \
			GPRINT:var3:LAST:'%4.3lf\r' \
			COMMENT:"avr" \
			GPRINT:var1:AVERAGE:'%4.0lf' \
			GPRINT:var2:AVERAGE:'%4.3lf' \
			GPRINT:var3:AVERAGE:'%4.3lf\r' \
			COMMENT:"max" \
			GPRINT:mvar1:MAX:'%4.0lf' \
			GPRINT:mvar2:MAX:'%4.3lf' \
			GPRINT:mvar3:MAX:'%4.3lf\r' \
			COMMENT:"output" \
			LINE1:var4#0A99FF:"pac" \
			LINE1:var5#5D00FF:"err" \
			LINE1:var6#FF00FB:"drop\r" \
			COMMENT:"cur" \
			GPRINT:var4:LAST:'%4.0lf' \
			GPRINT:var5:LAST:'%4.3lf' \
			GPRINT:var6:LAST:'%4.3lf\r' \
			COMMENT:"avr" \
			GPRINT:var4:AVERAGE:'%4.0lf' \
			GPRINT:var5:AVERAGE:'%4.3lf' \
			GPRINT:var6:AVERAGE:'%4.3lf\r' \
			COMMENT:"max" \
			GPRINT:mvar4:MAX:'%4.0lf' \
			GPRINT:mvar5:MAX:'%4.3lf' \
			GPRINT:mvar6:MAX:'%4.3lf\r' \
			
		$RRDTOOL graph $IMGDIR/$1/$IF/byte-$IMG \
			-s $2 \
			-e now \
			-a ${5^^} \
			-t "$(hostname) $IF byte/s" \
			-r \
			-E \
			-i \
			-R light \
			--zoom 1 \
			-w $3 \
			-h $4 \
			DEF:var1=$DATABASE:input:AVERAGE \
			DEF:var2=$DATABASE:output:AVERAGE \
			DEF:mvar1=$DATABASE:input:MAX \
			DEF:mvar2=$DATABASE:output:MAX \
			CDEF:var1bit=var1,8,* \
			CDEF:var2bit=var2,8,* \
			CDEF:mvar1bit=mvar1,8,* \
			CDEF:mvar2bit=mvar2,8,* \
			CDEF:ivar2bit=var2bit,-1,* \
			AREA:var1bit#FF5500:"input " \
			GPRINT:var1bit:LAST:'cur %4.0lf %sbit/s' \
			GPRINT:var1bit:AVERAGE:'avr %4.0lf %sbit/s' \
			GPRINT:mvar1bit:MAX:'max %4.0lf %sbit/s \r' \
			AREA:ivar2bit#0A99FF:"output" \
			GPRINT:var2bit:LAST:'cur %4.0lf %sbit/s' \
			GPRINT:var2bit:AVERAGE:'avr %4.0lf %sbit/s' \
			GPRINT:mvar2bit:MAX:'max %4.0lf %sbit/s \r'
	done
}
