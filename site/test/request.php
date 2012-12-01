<html>
<head>
	<title>P2PS - Relax the Ring</title>
</head>
<body>

<?php
include("functions.php");
include("adhocParser.php");

$DEFAULT_PORT=91530;

//Retrieving values from the form
$key   = $_REQUEST["key"];

if (trim($key) == "")
{
	echo "You have not provided any key.<br/>";
	echo "Please come back and retry your submission with a valid key.<br/>";
}
else
{
	echo "<p> Preparing to open the socket to <em>get</em> the value assigned";
	echo "to the requested key: ".$key.". </p>";

	$socket = connect_to_socket($DEFAULT_PORT); 
	if ($socket != false)
	{
		$msg = "get(".$key.")";
		echo "Sending get(key) request...<br/>";
		write_to_socket($socket, $msg, strlen($msg));
		echo "OK.<br/>";

		echo "Reading from socket :";
		$result = read_from_socket($socket);
		$result = fromSocketToString($result);
		echo $result;
		echo "<br/>Closing socket...<br/>";
		close_socket($socket);
	}
}
?>

</body>
</html>
