<?php
require("functions.php");

makeHeader( "Beernet - Relax the Ring!",
			"Beernet",
			"The relaxed pBeer-to-pBeer network");

menu("none");
?>

<div id="maincontent">

<h2>What's going on?</h2>

<?
	$entries = getEntries();
	if ($entries != 'nil') {
		$i = 0;
		while ($entries != 'nil' && $i < 5) {
			$filename = car($entries);
			echo "<div class=\"item\">\n";
			postitem($filename);
			echo "</div>\n";
			$entries = cdr($entries);
			$i++;
		}
	} else {
		echo "<div class=\"item\">\n";
		echo "<center><h2><em>No news to display!</em></h2></center>\n";
		echo "</div>\n";
	}
?>


</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

