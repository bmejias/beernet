<html>
<head>
	<title>P2PS - Relax the Ring</title>
</head>
<body>
<?php
include("functions.php");
$DEFAULT_PORT=91530;

//Retrieving values from the form
$key   = $_REQUEST["key"];
$value = $_REQUEST["value"];

if (trim($key) == "")
{
	echo "You have not provided any key.<br/>";
	echo "Please come back and retry your submission with a valid key.<br/>";
}
else
{
	echo "<p>Preparing to open the socket to send <em> put(key, value) </em>";
	echo "to the Mighty Nano Store, using <em>";
	echo "put(".$key.", ".$value.") </em>. </p>"; 

	$socket = connect_to_socket($DEFAULT_PORT); 
	if ($socket != false)
	{
		$msg = "put(".$key.",".$value.")";
		echo "Sending key and value message...<br/>";
		write_to_socket($socket, $msg);
		echo "OK.<br/>";

		echo "Closing socket...<br/>";
		close_socket($socket);
		echo "OK.<br/>\n\n";
		echo "According to our guess, we already send the pair";
		echo "to the nano server.<br/>";
	}
}
?>

</body>
</html>
