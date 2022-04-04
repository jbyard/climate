CREATE SCHEMA IF NOT EXISTS climate;

COMMENT ON SCHEMA climate IS 'Time series climate sensor data.';


CREATE TABLE IF NOT EXISTS climate.probes (
	probe_id   MACADDR NOT NULL PRIMARY KEY,
	display    BOOLEAN NOT NULL DEFAULT TRUE,
	label      TEXT,
	color      TEXT NOT NULL DEFAULT (
		SELECT string_agg(to_hex(floor(random()*16+1)::INTEGER),'')
		FROM generate_series(1,6)
	)
);

COMMENT ON TABLE climate.probes IS 'Probes that can report data.';


CREATE TABLE IF NOT EXISTS climate.data (
	ts            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
	probe_id      MACADDR REFERENCES climate.probes(probe_id),
	temperature   NUMERIC(5,2),
	humidity      NUMERIC(5,2)
) PARTITION BY RANGE (ts);

COMMENT ON TABLE weather.measurements IS 'Data reported by probes.';
