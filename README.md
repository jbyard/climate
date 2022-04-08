# Climate 

A PostgreSQL schema for time series climate sensor data.

![example](example.png)

## Installing

Clone this repo, desginate a PostgreSQL database, and execute the install make
target.

```bash
PGUSER=joshb PGDATABASE=fishpoopfarms make install
```

## Populating

Pass `climate.add_datum()` a JSON object with your data.  Timestamp is an
optional second argument.  A probe MAC address is required.

```sql
SELECT climate.add_datum(jsonb_build_object(
	'probe',      'DE:AD:BE:EF:CA:FE',
	'temp',       42.213,
	'humidity',   55.5
))
```

## Plotting

The included script, ['example/plot.sh`](example/plot.sh) can help you generate
a gnuplot of your data.

```bash
# Plot the last 24 hours of temperature data to a default location
example/plot.sh

# Plot the last 3 days of humidity data to a custom location
example/plot.sh humidity "3 days" minute ~/last_3_days.png

# Plot the last month of temperature data with 1 hour granularity
example/plot.sh temperature "1 month" hour
```

## climate.latest

The lastest data from each probe with highs and lows over the past 24 hours.

```sql
SELECT
	probe,
	color,
	temperature,
	humidity,
	high_temp,
	low_temp,
	last_updated
FROM climate.latest
```

## Authors

* **Josh Byard** - *Initial work* - [jbyard](https://github.com/jbyard)
