<?php

# "Cards" of the latest readings from each probe.

$html = "
<div id='cards'>
";

require_once('.env.php');

$dbconn = pg_connect("host=localhost dbname=".PGDATABASE." user=".PGUSER." password=".PGPASSWORD)
		or die('Could not connect: ' . pg_last_error());

$query = "
	SELECT
		probe,
		color,
		temperature,
		humidity,
		high_temp,
		low_temp,
		last_updated
	FROM climate.latest
";

$result = pg_query($query) or die('Query failed: ' . pg_last_error());

while ($row = pg_fetch_array($result, null, PGSQL_ASSOC)) {


	$html .= "
	<div class='card'>
		<div>". $row["probe"] ."</div>
		<div class='dot' style='background-color:#". $row["color"] .";'></div>
		<div><span class='big'>". $row["temperature"] ."</span>°F ". $row["humidity"] ."%</div>
		<div class='small'>L:". $row["low_temp"] ." H:". $row["high_temp"] ."</div>
		<div class='small'>".   $row["last_updated"]   ."</div>
	</div>";

}

pg_free_result($result);
pg_close($dbconn);

$html .= "
</div>
";

echo $html;

?>
