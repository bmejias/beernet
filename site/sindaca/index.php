<?php
session_start();
require("macros.php");

makeHeader( "Sindaca - Sharing Idols N Discussing About Common Addictions",
			"Sindaca",
			"Sharing Idols N Discussing About Common Addictions");

menu("home");
?>

<div id="maincontent">

<center>
<h2>Welcome to SINDACA</h2>
<h3>A community-driven recommendation system</h3>
</center>

<p> Sindaca provides a very simple shared space to suggest, vote and discuss 
music, videos and other cultural expressions. The recommendation system is 
driven by the users themselves who suggest titles to other users. There is 
explicit data collection but no automatic inference for new recommendations. 
Sindaca does not allow storage of songs, videos, or any multimedia file. </p>

<?php

if (empty($_SESSION['user'])) {
	// Our user is connected
?>
<p> Please log in using the form on the left menu. If you don't have an 
account, sent an email to Boriss to request for one.</p>
<?php
} else {
	echo "<p>Welcome ".$_SESSION['user'].". </p>";
} // close if user connected
?>
	
</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

