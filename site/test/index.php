<html>
<head>
	<title>P2PS - Relax the Ring</title>
</head>
<body>
Ceci n'est pas une test<br/>

<!-- global table -->
<table border=0>
	<tr>

		<!-- form for input pairs (key,value) -->
		<td align="center">
		<form method="post" action="submit.php">
		<table border=0>
			<tr>
				<td>Key</td>
				<td><input type="text" name="key" size="15"></td>
			</tr>
			<tr>
				<td>Value</td>
				<td><input type="text" name="value" size="15"></td>
			</tr>
		</table>
		<table border=0>
			<tr>
				<td>
					<input type="submit" name="submit" value="Submit">
				</td>
			</tr>
		</table>
		</form>
		</td>

		<!-- space between tables -->
		<td width=150>
			&nbsp;
		</td>

		<!-- form for requesting values -->
		<td align="center">
			<form method="post" action="request.php">
			Request values assigned to
			<table border=0>
				<tr>
					<td>Key</td>
					<td><input type="text" name="key" size="15"></td>
				</tr>
			</table>
			<table border=0>
				<tr>
					<td>
						<input type="submit" name="submit" value="Request">
					</td>
				</tr>
			</table>
		</td>

	</tr>
</table>
<!-- End of global table -->

</hr>
<center>
<form method="post" action="stop.php">
	<input type="submit" name="stop" value="Stop the NanoServer">
</form>
</center>
</body>
</html>
