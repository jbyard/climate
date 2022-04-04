CREATE OR REPLACE FUNCTION climate.report_format(
	dimension        TEXT DEFAULT 'temperature',
	range            TEXT DEFAULT '24 hours',
	interval_width   TEXT DEFAULT 'minute'
) RETURNS TEXT AS $$

SELECT $sql$
SELECT
	ts,
$sql$ ||

CASE WHEN dimension = 'temperature'
THEN $sql$	32 AS "freezing",
	90 AS "scorching",
$sql$ ELSE '' END ||

string_agg(
	format(E'\t"p_%1$s" AS "%2$s"', probe_id, label)
, E',\n')

||$sql$
FROM crosstab($cross$
	SELECT
		date_trunc('$sql$|| interval_width ||$sql$',ts),
		probe_id,
		ROUND(AVG($sql$|| dimension ||$sql$))
	FROM climate.data
	WHERE ts > NOW() - '$sql$|| range ||$sql$'::interval
	GROUP BY 1, 2 ORDER BY 1
$cross$, $cross$VALUES
$sql$||

string_agg(format('(''%1$s'')', probe_id), E',\n')

||$sql$
$cross$) AS ct (
	ts TIMESTAMPTZ,
$sql$||

string_agg(format(E'\t"p_%1$s" TEXT', probe_id), E',\n')

||$sql$
)
$sql$
FROM climate.probes
WHERE probe_id IN (
	SELECT DISTINCT probe_id FROM climate.data
	WHERE ts > NOW() - range::interval
)

$$ LANGUAGE SQL;

COMMENT ON FUNCTION climate.report_format IS
'Generates dynamic crosstab sql for reports.';
