name=disk
DIR=$(echo $name/ | sed -e 's/^disk//' -e 's/-/\//g')
DATABASE=$DBDIR/$name.rrd
RRDTOOL=/usr/bin/rrdtool
PERIOD=30

function creat_db {
	if ! [ -f $DATABASE ]; then
		$RRDTOOL create $DATABASE -s $PERIOD \
			DS:used:GAUGE:600:0:U \
			DS:size:GAUGE:600:0:U \
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
	DATA1=$(df $DIR | awk '/^\// {print $3*1024}') #used space
	DATA2=$(df $DIR | awk '/^\// {print $2*1024}') #capacity size
	$RRDTOOL update $DATABASE N:$DATA1:$DATA2
}

function creat_img {
	mkdir -p $IMGDIR/$1/
	$RRDTOOL graph $IMGDIR/$1/$name.$5 \
		-s $2 \
		-e now \
		-a ${5^^} \
		-t "$(hostname) - disk space $DIR" \
		-r \
		-E \
		-i \
		-R light \
		--zoom 1 \
		-w $3 \
		-h $4 \
		--base 1024 \
		DEF:var1=$DATABASE:used:AVERAGE \
		DEF:var2=$DATABASE:size:AVERAGE \
		DEF:mvar1=$DATABASE:used:MAX \
		DEF:mvar2=$DATABASE:size:MAX \
		AREA:var1#0D82DC:"used\:" GPRINT:var1:LAST:'current\: %6.2lf %sB' GPRINT:var1:AVERAGE:'average\: %6.2lf %sB' GPRINT:mvar1:MAX:'max\: %6.2lf %sB \r' \
		LINE1:var2#FF6325:"size\:" GPRINT:var2:LAST:'current\: %6.2lf %sB' GPRINT:var2:AVERAGE:'average\: %6.2lf %sB' GPRINT:mvar2:MAX:'max\: %6.2lf %sB \r' \
		LINE:0#000000 \
		LINE1:var1#065795
}

