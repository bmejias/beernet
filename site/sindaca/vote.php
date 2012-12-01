<?php
session_start();
include("global.php");
include("macros.php");
include("functions.php");
include("adhocParser.php");

makeHeader( "Sindaca - Sharing Idols N Discussing About Common Addictions",
			"Sindaca",
			"Sharing Idols N Discussing About Common Addictions");

menu("home");
?>

<div id="maincontent">

<?php

if (empty($_SESSION['username']))
{
?>
<p> Please log in using the form on the left menu. If you don't have an 
account, sent an email to Boriss to request for one.</p>
<?php
} else {
	$socket = connect_to_socket($DEFAULT_PORT); 
	echo "<p>Thanks ".$_SESSION['username']." for your submission. ";
	echo "We are processing your voted, which actually ";
	if ($socket == false)
	{
		echo "failed. Blame Canada!</p>\n";
	} else {
		$keys = array_keys($_POST);
		for ($i = 0; $i < count($keys); $i++) {
			$key = $keys[$i];
			if ($key != "submit")
			{
				$msg = "vote(".$_SESSION['username'].",".$_SESSION['password'];
				$msg.= ",".$key.",".$_POST[$key].")";
				write_to_socket($socket, $msg);
				//echo $msg."<br/>";
			}
		}
		$result = read_from_socket_until($socket, $WEA);
		$result = fromSocketToString($result);
		echo $result."</p>";
	}
	close_socket($socket);
}
?>
	
</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

