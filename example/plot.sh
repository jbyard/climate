#! /bin/bash
#
# plot.sh

DIMENSION="${1:-temperature}"
RANGE="${2:-24 hours}"
INTERVAL="${3:-minute}"
PNG="${4:-/var/www/html/img/$DIMENSION.png}"

CSV="/tmp/plot_$$.csv"
touch $CSV; chmod a+w $CSV

echo "Plot $DIMENSION over the last $RANGE in $INTERVAL intervals to: $PNG";

# Generate the report
psql -qc "
DO \$\$ BEGIN
	EXECUTE 'COPY ( ' ||
		climate.report_format('$DIMENSION', '$RANGE', '$INTERVAL')
	|| ') TO ''$CSV'' WITH (FORMAT CSV, HEADER)';
END; \$\$
"

# Plot the report
read -r -d '' PLOTCMD <<HERE
	set datafile separator ',';
	set output '$PNG';
	set terminal png size 800,300 background rgb '#EAEDF0';
	set key textcolor rgb '#46444D';
	set title '$DIMENSION - last $RANGE';
	set key below autotitle columnhead;
	set xdata time; set timefmt '%Y-%m-%d %H:%M:%S'; set format x '%H:%M';
	plot
HERE

COLUMN=2

# Temperature plots will also have freeze and scorch lines
if [ "$DIMENSION" == 'temperature' ]; then
	PLOTCMD="${PLOTCMD} '$CSV' using 1:2 smooth bezier lw 1 lt rgb'#2669BD',"
	PLOTCMD="${PLOTCMD} '$CSV' using 1:3 smooth bezier lw 1 lt rgb'#BD3C2F',"
	COLUMN=4
fi

for PROBE in $(psql -qt -c "
	SELECT color FROM climate.probes
	WHERE display
"); do
	PLOTCMD="${PLOTCMD} '$CSV' using 1:$COLUMN smooth bezier lw 3 lt rgb'#$PROBE',"
	((COLUMN=COLUMN+1))
done

gnuplot -p -e "$PLOTCMD"

rm $CSV
