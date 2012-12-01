<?php
/* *********************************************************************
 * This file contains functions to connect, read, write and close
 * sockets. Having in mind that they are meant for communicating
 * with a Mozart process running in the same machine
 * *********************************************************************/

function connect_to_socket($service_port)
{
	//$socket = socket_create(AF_UNIX, SOCK_STREAM, SOL_SOCKET);
	$socket = socket_create(AF_INET, SOCK_STREAM, SOL_TCP);
	//$socket = socket_create(AF_UNIX, SOCK_STREAM, 0);
	if ($socket == false)
	{
		echo "socket_create() failed: reason:\n";
		echo socket_strerror(socket_last_error()) . "</br>";
		return false;
	}
	else 
	{
		$address = gethostbyname('localhost');
		$result = socket_connect($socket, $address, $service_port);
		if ($result == false)
		{
			echo "socket_connect() failed.<br/>Reason: ($result) ";
			echo socket_strerror(socket_last_error($socket)) . "\n";
			return false;
		}
		else
		{
			//Success!
			return $socket;
		}
	}
}

function write_to_socket($socket, $msg)
{
	socket_write($socket, $msg, strlen($msg));
}

function read_from_socket($socket)
{
	$result = socket_read($socket, 100);
	if ($result == false)
	{
		echo "There was an error reading from the socket. Blame Canada!</br>";
	}
	return $result;
}

function close_socket($socket)
{
	socket_close($socket);
}

?>
