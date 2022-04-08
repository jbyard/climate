CREATE SCHEMA IF NOT EXISTS climate;

CREATE OR REPLACE VIEW climate.latest AS
SELECT DISTINCT ON (probe_id)
	label                     AS probe,
	color                     AS color,
	ROUND(temperature)        AS temperature,
	ROUND(humidity)           AS humidity,
	MIN(ROUND(temperature)) OVER(PARTITION BY probe_id)  AS low_temp,
	MAX(ROUND(temperature)) OVER(PARTITION BY probe_id)  AS high_temp,
 CASE WHEN NOW() - ts < '3 seconds'::interval THEN 'just now'
 WHEN NOW() - ts < '1 minute'::interval THEN
	EXTRACT(second from date_trunc('second', NOW() - ts))::TEXT || ' seconds ago'
 WHEN NOW() - ts < '1 hour'::interval THEN
	EXTRACT(minute from date_trunc('minute', NOW() - ts))::TEXT || ' minutes ago'
 WHEN NOW() - ts < '2 hours'::interval THEN '1 hour ago' ELSE 
	EXTRACT(hour from date_trunc('hour', NOW() - ts))::TEXT || ' hours ago'
 END AS last_updated
FROM climate.data
LEFT JOIN climate.probes USING (probe_id)
WHERE display AND ts > NOW() - '1 day'::interval
ORDER BY probe_id, ts DESC;

COMMENT ON VIEW climate.latest IS
'The latest data from each probe';
