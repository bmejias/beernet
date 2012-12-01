<html>
<head>
	<title>P2PS - Relax the Ring</title>
</head>
<body>
Preparing to open the socket to send the request to stop the Mighty Nano Server <br/>
<?php
	//$socket = socket_create(AF_UNIX, SOCK_STREAM, SOL_SOCKET);
	$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
	if ($socket === false) {
		echo "socket_create() failed: reason: <br/>";
		echo socket_strerror(socket_last_error()) . "\n";
	} else {
    	echo "OK.\n";
	}
	$address = gethostbyname('localhost');
	$service_port = 66666; //Try to make a loop in case we cannot connect
	echo "Attempting to connect to '$address' on port '$service_port'...<br/>";
	$result = socket_connect($socket, $address, $service_port);
	if ($result === false) {
    	echo "socket_connect() failed.\nReason: ($result) ";
		echo socket_strerror(socket_last_error($socket)) . "\n";
	} else {
    	echo "OK.\n";
	}

	$msg = "stop"; // Change this for a form with key/value entries

	echo "Sending stop message...";
	socket_write($socket, $msg, strlen($msg));
	echo "OK.\n";

	echo "Closing socket...";
	socket_close($socket);
	echo "OK.\n\n";
?>

According to our guess, we already stop the nano server.<br/>
</body>
</html>
