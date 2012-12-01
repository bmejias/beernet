<?php
require("functions.php");

makeHeader( "Beernet - Relax the Ring!",
			"Beernet",
			"The relaxed pbeer-to-pbeer network");

menu("home");
?>

<div id="maincontent">

<?
	$entries = getEntries();
	if ($entries != 'nil') {
		$filename = car($entries);
		echo "<div class=\"item\">\n";
		postmain($filename);
		echo "<div align=\"right\"><a href=\"news.php\">More news</a></div>";
		echo "</div>\n";
	}
?>

<h2>Beernet: pBeer-to-pbeer network</h2>

<p> <strong>Beernet</strong> is a pbeer-to-pbeer network for building 
<strong>self-managing</strong> and <strong>scalable</strong> systems with 
<strong>transactional</strong> and robust storage. Beernet stands for
pbeer-to-pbeer network, where words <strong>peer</strong> and 
<strong>beer</strong> are mixed to emphasise the fact that this is 
peer-to-peer built on top of a <em>relaxed</em>-ring topology (beers are a 
known mean to achieve relaxation). The <strong>relaxed-ring</strong> topology 
is designed to deal with non-transitive connectivity, avoiding problems of 
inconsistency and unavailability. The relaxed-ring provides a distributed hash 
table (DHT) with no central point of control and without relying on transitive 
connectivity between peers. Beernet's storage provides replication with 
transactional operations guaranteeing <strong>strong consistency</strong> of 
data. Every transaction has its own dynamic set of managers, making it highly 
robust and more tolerant to failures compared to centralized approaches.  
Storage is based on key/value-pairs and key/value-sets. We are currently 
studying Beernet's elasticity to build systems for cloud computing, as part of 
the <a href="transreal.php">Transreal Initiative</a>. </p>

<h2>To Developers</h2> 

<p> Beernet is one of the results of the <a 
href="http://www.ist-selfman.org">SELFMAN</a> and <a 
href="http://www.mancoosi.org">MANCOOSI</a> research projects. Therefore, the 
<a href="documentation.php">documentation</a> is still in the form of papers.  
But, we  are currently working on providing a good API and simple examples to 
start developing with Beernet. Meanwhile you may check <a 
href="pepino">PEPINO</a>, <a href="detransdraw">DeTransDraw</a> and <a 
href="smallwiki">Small Wiki</a>, which are some prototypes developed with 
Beernet. You may also like to check the development infrastructure on <a
	href="http://gforge.info.ucl.ac.be/projects/beernet"> GForge/UCLouvain</a> 
</p>

<br />
<center><img src="images/big-branch.png" width="50%"></center>
<br />

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

