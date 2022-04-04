CREATE SCHEMA IF NOT EXISTS climate;

CREATE OR REPLACE FUNCTION climate.add_datum(datum JSONB)
RETURNS void AS $$
DECLARE
	need_to_part BOOLEAN;
BEGIN

	IF NOT ($1 ? 'probe') THEN
		RAISE EXCEPTION 'Requires a probe MAC address.';
	END IF;

	/* Allow for partial, but not entirely empty datapoints */
	IF (NOT ($1 ? 'temp') AND NOT ($1 ? 'humidity')) THEN
		RAISE EXCEPTION 'Requires temperature or humidity.';
	END IF;
	
	INSERT INTO climate.probes (probe_id)
	VALUES (macaddr_in(($1->>'probe')::cstring))
	ON CONFLICT ON CONSTRAINT probes_pkey DO NOTHING;

	/* Insert into the timeseries data table, creating a partition if necessary. */
	need_to_part := true;
	LOOP
		BEGIN
			INSERT INTO climate.data ( probe_id, ts, temperature, humidity )
			VALUES (
				macaddr_in(($1->>'probe')::cstring),
				COALESCE(($1->>'timestamp')::TIMESTAMPTZ, CURRENT_TIMESTAMP),
				($1->>'temp')::NUMERIC,
				($1->>'humidity')::NUMERIC
			);

			need_to_part := false;
			EXIT;

		EXCEPTION WHEN check_violation THEN END;

		IF need_to_part THEN
			EXECUTE format('	
				CREATE TABLE IF NOT EXISTS climate.data_%1$s
				PARTITION OF climate.data 
				FOR VALUES FROM (''%2$s'') TO (''%3$s'')
			',to_char(date_trunc('month',CURRENT_TIMESTAMP),'YYYY_MM'),
			date_trunc('month',CURRENT_TIMESTAMP),
			date_trunc('month',CURRENT_TIMESTAMP) + '1 month'::interval);
		END IF;
	
	END LOOP;
END
$$ LANGUAGE PLPGSQL;
