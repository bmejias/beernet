<?php
session_start();
session_destroy();
$_SESSION['username'] = "";
require("macros.php");

makeHeader( "Sindaca - Sharing Idols N Discussing About Common Addictions",
			"Sindaca",
			"Sharing Idols N Discussing About Common Addictions");

menu("home");
?>

<div id="maincontent">

<center>
<strong>You are not logged in any more... Come back whenever you want.</strong>
</center>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>


