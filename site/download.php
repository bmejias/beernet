<?php
require("functions.php");

makeHeader( "Beernet - Download the Ring!",
			"Beernet",
			"The relaxed pBeer-to-pBeer network");

menu("download", "none");
?>

<div id="maincontent">

<h2>Download</h2>

<p> Current Beernet release is version 0.9. The source code and the binaries
compiled for Mozart-1.3.2 can be downloaded from the table below. Beernet 
provides transactional replicated storage, combining key/value-pairs with 
key/value-sets. The software Pepino and DeTransDraw works with the transition 
library P2PS/Beernet 3.1.1, where part of the transactional support is already 
included. CiNiSMO is our programming framework for network simulation  with 
concurrent agents. You can get Mozart from <a 
href="http://www.mozart-oz.org/download/view.cgi">here</a> </p><br/>

<center>
<table>
	<tr>
	<td bgcolor="#CFE6CF" width="220"> &nbsp; Beernet </td>
	<td width="185" align="center" bgcolor="#CFE6CF">tgz</td>
	<td width="185" align="center" bgcolor="#CFE6CF">zip</td>
	</tr>
	<tr>
	<td>Source Code</td>
	<td><a href="store/beernet-0.9.src.tgz">beernet-0.9.src.tgz</a></td>
	<td><a href="store/beernet-0.9.src.zip">beernet-0.9.src.zip</a></td>
	</tr>
	<tr>
	<td>Compiled for Mozart 1.3.2</td>
	<td><a href="store/beernet-0.9.tgz">beernet-0.9.tgz</a></td>
	<td><a href="store/beernet-0.9.zip">beernet-0.9.zip</a></td>
	</tr>
	
	<tr>
	<td>Source Code</td>
	<td><a href="store/beernet-0.8.src.tgz">beernet-0.8.src.tgz</a></td>
	<td><a href="store/beernet-0.8.src.zip">beernet-0.8.src.zip</a></td>
	</tr>
	<tr>
	<td>Compiled for Mozart 1.3.2</td>
	<td><a href="store/beernet-0.8.tgz">beernet-0.8.tgz</a></td>
	<td><a href="store/beernet-0.8.zip">beernet-0.8.zip</a></td>
	</tr>
	
	<td bgcolor="#CFE6CF" width="220"> &nbsp; P2PS/Beernet + PEPINO</td>
	<td width="185" align="center" bgcolor="#CFE6CF">tgz</td>
	<td width="185" align="center" bgcolor="#CFE6CF">zip</td>
	</tr>
	<tr>
	<td>Source Code</td>
	<td><a href="store/p2psBeernet-v3.1.1-src.tgz">P2PS-Beernet 3.1.1 src</a></td>
	<td><a href="store/p2psBeernet-v3.1.1-src.zip">P2PS-Beernet 3.1.1 src</a></td>
	</tr>
	<tr>
	<td>Compiled for Mozart 1.4.0</td>
	<td><a href="store/p2psBeernet-v3.1.1-oz1.4-bin.tgz">P2PS/Beernet 3.1.1 bin</a></td>
	<td><a href="store/p2psBeernet-v3.1.1-oz1.4-bin.zip">P2PS/Beernet 3.1.1 bin</a></td>
	</tr>
	<tr>
	<td bgcolor="#CFE6CF"> &nbsp; DeTransDraw</td>
	<td align="center" bgcolor="#CFE6CF">tgz</td>
	<td align="center" bgcolor="#CFE6CF">zip</td>
	</tr>
	<tr>
	<td>Source Code</td>
	<td align="center">-</td>
	<td><a href="store/DeTransDraw-src.zip">DeTransDraw src</a></td>
	</tr>
	<tr>
	<td>Compiled for Mozart 1.4.0</td>
	<td align="center">-</td>
	<td><a href="store/DeTransDraw-oz1.4.zip">DeTransDraw oz1.4</a></td>
	</tr>
	<tr>
	<td bgcolor="#CFE6CF"> &nbsp; CiNiSMO</td>
	<td align="center" bgcolor="#CFE6CF">tgz</td>
	<td align="center" bgcolor="#CFE6CF">zip</td>
	</tr>
	<tr>
	<td>Source Code</td>
	<td><a href="store/CiNiSMO-v1.2.tgz">CiNiSMO v1.2</a></td>
	<td><a href="store/CiNiSMO-v1.2.zip">CiNiSMO v1.2</a></td>
	</tr>
</table>
</center>

<br>

<p> In case you are interested in checking out the subversion repository, you 
can find the instructions on <a
	href="http://gforge.info.ucl.ac.be/scm/?group_id=15">GForge/UCLouvain</a> 
</p>

<h2>License</h2>

<p>All software downloadable on this page has been released as Free Software, 
under the <a href="license.php">Beerware License</a>.</p>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

