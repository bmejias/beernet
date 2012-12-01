<?php
session_start();
include("global.php");
include("macros.php");
include("functions.php");
include("adhocParser.php");

//Use values from the form is not session is active
if (empty($_SESSION['username']))
{
	$username = $_POST["username"];
	$password = $_POST["password"];
} else {
	$username = $_SESSION['username'];
	$password = $_SESSION['password'];
}

makeHeader( "Sindaca - Sharing Idols N Discussing About Common Addictions",
			"Sindaca",
			"Sharing Idols N Discussing About Common Addictions");

if (trim($username) != "")
{
	$socket = connect_to_socket($DEFAULT_PORT); 
	if ($socket != false)
	{
		$msg = "signin(".$username.",".$password.")";
		write_to_socket($socket, $msg);
		// Welcome message!
		$result = read_from_socket_until($socket, $WEA);
		$result = fromSocketToString($result);
		if (substr($result, 0, 5) != "Wrong") {
			$_SESSION['username'] = $result;
			$_SESSION['password'] = $password;
		}
	}
}
menu("profile");
?>

<div id="maincontent">

<center>
<h2>SINDACA</h2>
</center>

<?

if (trim($_SESSION['username']) == "")
{
	echo "Wrong username or password. Please try again.<br/>";
}
else
{
	//echo "<p>Preparing to open the socket to send ";
	//echo "<em> signin(username, password) </em>";
	//echo "to the Mighty Nano Store, using <em>";
	//echo "signin(".$username.", ".$password.") </em>. </p>"; 

//	$socket = connect_to_socket($DEFAULT_PORT); 
//	if ($socket != false)
//	{
//		$msg = "signin(".$username.",".$password.")";
		//echo "Sending key and value message...<br/>";
//		write_to_socket($socket, $msg);
		//echo "OK.<br/>";

		//echo "Reading from socket :<br/>";
		// Welcome message!
		$result = read_from_socket_until($socket, $WEA);
		$result = fromSocketToString($result);
		echo $result;
		if (substr($result, 0, 5) != "Wrong") {
?>
		<!-- Print recommendations from the community -->
		<form method="post" action="vote.php">
		<table border=0 width="100%">
		<tr><td bgcolor="#CFE6CF" width="100%">
			<b>Recommendation made by the community.</b>
		</td></tr>
		<tr><td>
			<table border=0 width="100%">
<?php
			$result = read_from_socket_until($socket, $WEA);
			$result = fromSocketToString($result);
			echo $result;
?>
			</table>
		</td></tr>
		<tr><td align="right">
			<input  type="submit" name="submit"
					value="Vote" style="width:9em">
		</td></tr>
		</table>
		</form>


		<!-- Form to make a new recommendation -->
		<form method="post" action="recommend.php">
		<table border=0 width="100%">
		<tr><td bgcolor="#CFE6CF" width="100%">
			<b>Make your own recommendation</b>
		</td></tr>
		<tr><td>
			<table border=0>
			<tr>
				<td width="15%">Title</td>
				<td><input type="text" name="title" size="42"></td>
			</tr>
			<tr>
				<td width="15%">Artist</td>
				<td><input type="text" name="artist" size="42"></td>
			</tr>
			<tr>
				<td width="15%">Link</td>
				<td><input type="text" name="link" size="42"></td>
			</tr>
			</table>
		</td></tr>
		<tr><td align="right">
			<input  type="submit" name="submit"
					value="Recommend" style="width:9em">
		</td></tr>
		</table>
		</form>

		<!-- Print my recommendations -->
		<table border=0 width="100%">
		<tr><td bgcolor="#CFE6CF" width="100%">
			<b>Your recommendations</b>
		</td></tr>
		<tr><td>
			<table border=0 width="100%">
<?php
			$result = read_from_socket_until($socket, $WEA);
			$result = fromSocketToString($result);
			echo $result;
?>
			</table>
		</td></tr>
		</table>

<?php
		//}
		//echo "<br/>Closing socket...<br/>";
		//echo "OK.<br/>\n\n";
		//echo "According to our guess, we already send the pair";
		//echo "to the nano server.<br/>";
	}
	close_socket($socket);
}
?>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

