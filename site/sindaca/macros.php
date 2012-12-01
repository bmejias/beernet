<?php
// I am not sure whether these are real macros, but the objective is to build
// the header, menu and footer of every page based on certain parameters
//
//--------------- Header --------------------------
function makeHeader($metatitle, $title, $slogan) {
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><?php echo $metatitle; ?></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<meta name="description" content="Beernet's website. Releases, documentation" 
/>
<meta name="keywords" content="beernet, peer-to-peer, relaxed-ring, 
self-management, selfman, mancoosi" />
<link href="style.css" rel="stylesheet" type="text/css" />
</head>
<body>

<div id="header">

<div id="contact"><a href="contact.php">Contact</a></div>

<div id="title"><?php echo $title; ?></div>

<div id="slogan"><?php echo $slogan; ?></div>

</div>
<?php
}

//--------------- Footer --------------------------
function makeFooter() {
?>
<div id="footer">

	<div id="copyright">
		Developed by
		<a href="http://pldc.info.ucl.ac.be">PLDC</a>
		- Universit&eacute; catholique de Louvain |
		Design by <a href="http://ContentedDesigns.com">Contented Designs</a>
	</div>

	<div id="footercontact">
		<a href="contact.php">Contact</a>
	</div>

</div>

</body>
</html>

<?php
}

//--------------- Menu --------------------------
function menu($page) {
	$entries = array(
		array("home", 		"index.php",			"Sindaca"),
		array("profile",	"profile.php",			"Profile"),
		array("docs",		"documentation.php",	"Documentation"));
		
	echo "<div id=\"sidecontent\">\n";
	echo "<ul id=\"nav\">\n";
	if (empty($_SESSION['username'])) {
	?>
		<form method="post" action="profile.php">
		<table border=0>
			<tr>
				<td>Username</td>
			</tr>
			<tr>
				<td><input type="text" name="username" size="15"></td>
			</tr>
			<tr>
				<td>Password</td>
			</tr>
			<tr>
				<td><input type="password" name="password" size="15"></td>
			</tr>
			<tr>
				<td align="right">
					<input type="submit" name="submit" value="Sign in">
				</td>
			</tr>
		</table>
		</form>
	<?php
	} else {
		echo "<li><h2>Welcome ".$_SESSION['username']."</h2></li>\n";
		echo "<li><a href=\"signout.php\">Sign out</a></li>\n";
	}
	echo "</ul>\n";

	echo "<ul id=\"nav\">\n";

	for ($i = 0; $i < count($entries); $i++) {
		if ($entries[$i][0] != "profile" || !(empty($_SESSION['username'])))
		{
			echo "<li>";
			if ($entries[$i][0] == $page) {
				echo "<strong>".$entries[$i][2]."</strong>\n";
			} else {
				echo "<a href=\"".$entries[$i][1]."\">".$entries[$i][2]."</a>";
			}
			echo "</li>\n";
		}
	}

	echo "</ul>\n";

	echo "<h2>Links</h2>\n";
	echo "<ul id=\"nav\">\n";
	echo "<li><a href=\"http://beernet.info.ucl.ac.be\"> Beernet </a></li>\n";
	echo "<li><a href=\"http://www.ist-selfman.org\"> SELFMAN </a></li>\n";
	echo "<li><a href=\"http://www.mancoosi.org\"> Mancoosi </a></li>\n";
	echo "<li><a href=\"http://www.mozart-oz.org\"> Mozart-Oz </a></li>\n";
	echo "<li><a href=\"http://pldc.info.ucl.ac.be\"> PLDC </a></li>\n";
	echo "</ul>\n";

	echo "</div> <!-- end sidecontent -->\n";
}

?>
