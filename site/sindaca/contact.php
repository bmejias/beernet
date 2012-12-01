<?php
session_start();
require("macros.php");

makeHeader( "Beernet - Relax the Ring!",
			"Beernet",
			"The relaxed pBeer-to-pBeer network");

menu("none");
?>

<div id="maincontent">

<h2>Contact</h2>

<p> <a href="index.php">Sindaca</a> is a community-driven recommendation 
system  developed by
<a href="http://pldc.info.ucl.ac.be">PLDC</a>: 
Programming Languages and Distributed Computing Research Group, at the 
Universit&eacute; catholique de Louvain
(<a href="http://www.uclouvain.be">UCLouvain</a>), and with the founding of 
the <a href="http://www.ist-selfman.org">SELFMAN</a> project. </p>

<p> Sindaca is implemented with <a href="http://beernet.info.ucl.ac.be">Beernet</a> and it is under continuous development. Therefore, there might be some problems while running some test. In such case, please contact Boriss Mej&iacute;as at &nbsp; <img src="images/emailBoriss.png"> </p>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

