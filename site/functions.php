<?php

require("list.php");

//--------------- Header --------------------------
function makeHeader($metatitle, $title, $slogan, $mypath = "") {
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
<link href="<? echo $mypath; ?>style.css" rel="stylesheet" type="text/css" />
</head>
<body>

<div id="header">

<div id="contact"><a href="<? echo $mypath; ?>contact.php">Contact</a></div>

<div id="title"><?php echo $title; ?></div>

<div id="slogan"><?php echo $slogan; ?></div>

</div>
<?php
}

//--------------- Footer --------------------------
function makeFooter($mypath = "") {
?>
<div id="footer">

	<div id="copyright">
		Developed by
		<a href="http://pldc.info.ucl.ac.be">PLDC</a>
		- Universit&eacute; catholique de Louvain |
		Design by <a href="http://ContentedDesigns.com">Contented Designs</a>
	</div>

	<div id="footercontact">
		<a href="<? echo $mypath; ?>contact.php">Contact</a>
	</div>

</div>

</body>
</html>

<?php
}

//--------------- Menu --------------------------
function menu($page) {
	$entries = array(
		array("home", 		"index.php",			"Beernet"),
		array("pepino", 	"pepino.php",			"PEPINO"),
		array("cinismo", 	"cinismo.php",			"CiNiSMO"),
		array("detransdraw","detransdraw.php",		"DeTransDraw"),
		array("smallwiki",	"smallwiki.php",		"Small Wiki"),
		array("download",	"download.php",			"Download"),
		array("docs",		"documentation.php",	"Publications"),
		array("docs",		"documentation.php",	"Documentation"));
		
	echo "<div id=\"sidecontent\">\n";
	echo "<h2>Software</h2>\n";
	echo "<ul id=\"nav\">\n";

	for ($i = 0; $i < count($entries); $i++) {
		echo "<li>";
		if ($entries[$i][0] == $page) {
			echo "<strong>".$entries[$i][2]."</strong>\n";
		} else {
			echo "<a href=\"".$entries[$i][1]."\">".$entries[$i][2]."</a>";
		}
		echo "</li>\n";
	}

	echo "</ul>\n";

	include("static_menu.html");

	echo "</div> <!-- end sidecontent -->\n";
}

//--------------- Transreal Menu --------------------------
function trealMenu($page) {
	$entries = array(
		array("home", 		"index.php",			"Transreal"),
		array("realworld", 	"real_world_computing.php", "Real-world computing"),
		array("elasticity", "resource_amplification.php", "Resource amplification"),
		array("mlearning",	"machine_learning.php",	"Machine Learning"),
		array("fosdem",		"at_fosdem.php",		"At Fosdem"),
		array("challenges",	"challenges.php",		"Challenges"),
		array("partners",	"participants.php",		"Initial Participants"));
		
	echo "<div id=\"sidecontent\">\n";
	echo "<h2>Software</h2>\n";
	echo "<ul id=\"nav\">\n";

	for ($i = 0; $i < count($entries); $i++) {
		echo "<li>";
		if ($entries[$i][0] == $page) {
			echo "<strong>".$entries[$i][2]."</strong>\n";
		} else {
			echo "<a href=\"".$entries[$i][1]."\">".$entries[$i][2]."</a>";
		}
		echo "</li>\n";
	}

	echo "</ul>\n";

	echo "<h2>Links</h2>\n";
	echo "<ul id=\"nav\">\n";
	echo "<li><a href=\"../\"> Beernet </a></li>\n";
	echo "<li><a href=\"http://www.ist-selfman.org\"> Selfman </a></li>\n";
	echo "<li><a href=\"http://www.mancoosi.org\"> Mancoosi </a></li>\n";
	echo "<li><a href=\"http://www.mozart-oz.org\"> Mozart-Oz </a></li>\n";
	echo "<li><a href=\"http://pldc.info.ucl.ac.be\"> PLDC </a></li>\n";
	echo "</ul>\n";

	echo "</div> <!-- end sidecontent -->\n";
}

//--------------- Getting News --------------------------
function getEntries($dir = 'newsentries/') {
	$ret = 'nil';
	
	if (is_dir($dir)) {
		if ($dh = opendir($dir)) {
			while (($file = readdir($dh)) != false) {
				if (substr($file, -4) == "html") {
					$ret = insertReverseList($ret, $file);
				}
			}
			closedir($dh);
		}
	}
	return $ret;
}

function postitem($filename, $dir = 'newsentries/') {
	$handle = @fopen($dir.$filename, "r");
	if ($handle) {
		$title = fgets($handle);
?>
		<table border=0>
		<tr><td>
			<table border=0 bgcolor="#CFE6CF">
			<tr><td width="425">
<?
			echo "<h3>".$title."</h3>\n";
?>
			</td><td width="100" align=\"right\">
<?
			echo substr($filename, 0, 4)."-".substr($filename, 4, 2);
			echo "-".substr($filename, 6, 2);
?>
			</td></tr>
			</table>
		</td></tr>
		<tr><td>
			<table border=0>
			<tr><td width="525">
<?
			while (!feof($handle)) {
				$buffer = fgets($handle, 4096);
				echo $buffer;
			}
?>
			</td></tr>
			</table>
		</td></tr>
		</table>
<?
		fclose($handle);
	}
}

function postmain($filename, $dir = 'newsentries/') {
	$handle = @fopen($dir.$filename, "r");
	if ($handle) {
		$title = fgets($handle);
?>
		<table border=0>
		<tr><td>
			<table border=0 bgcolor="#CFE6CF">
			<tr><td width="525">
<?
			echo "<strong>".$title."</strong><br/>\n";
			echo substr($filename, 0, 4)."-".substr($filename, 4, 2);
			echo "-".substr($filename, 6, 2)."\n";
			while (!feof($handle)) {
				$buffer = fgets($handle, 4096);
				echo $buffer;
			}
?>
			</td></tr>
			</table>
		</td></tr>
		</table>
<?
		fclose($handle);
	}
}

?>
