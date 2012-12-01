<?php
require("functions.php");

makeHeader( "CiNiSMO - Concurrent Network Simulator in Mozart-Oz",
			"CiNiSMO",
			"Concurrent Network Simulator in Mozart-Oz");

menu("cinismo");
?>

<div id="maincontent">

<h2>CiNiSMO - Concurrent Network Simulator in Mozart-Oz</h2>

<p> <strong>CiNiSMO</strong> is a network simulator where every node run on its
own light-weight thread. This makes the simulator much more realistic, because
there is no serialized synchronization of events, and peers behaves as they
were in distributed machines running in parallel. Of course, if serialization
is needed, it can be achieve with data-flow synchronization.  </p>

<p> <strong>CiNiSMO</strong> has been used for validation tests of the paper 
on the <strong>Relaxed-Ring</strong> submitted to IEEE P2P2008 conference,
implementing Beernet and Chord. It has also being used for validation tests on 
the work on <strong>PALTA</strong>, <b>P</b>eer-to-peer 
<b>A</b>daptab<b>L</b>e <b>T</b>opology for <b>A</b>mbient inteligence, 
submitted to the International Conference of the Chilean Society of Computer 
Science, 2008. Test where run on the implementation of fully connected 
network, Beernet and PALTA. The source code and tests can be found on the 
public SVN repository of <a
	href="http://gforge.info.ucl.ac.be/scm/?group_id=15">Revereendo</a></p>

<p> Here there are some results obtained with <strong>CiNiSMO</strong> on the
evaluation of the Relaxed-Ring, and its comparison with Chord. Experiments
where run using networks from sizes going from 1000 to 10000 nodes. It is not
our current goal to give a detailed explanation of the graphs on this site.
They are presented to show the magnitude of the experiment we are able to run
using <strong>CiNiSMO</strong>.</p>

<p> Messages exchanged in Beernet on the left. Comparison with Chord at the
right.</p>

<center>
	<a href="images/cinismo/p2psmsgs.png">
		<img src="images/cinismo/p2psmsgs.png" width="40%">
	</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="images/cinismo/allmsgs.png">
		<img src="images/cinismo/allmsgs.png" width="40%">
	</a>
</center>

<p>The following graphs present the amount of branches found in Beernet (left) 
and the average size of them (right). Experiments where run using different 
levels of connectivity.</p>

<center>
	<a href="images/cinismo/p2psbranches.png">
		<img src="images/cinismo/p2psbranches.png" width="40%">
	</a>
	&nbsp;&nbsp;&nbsp;&nbsp;
	<a href="images/cinismo/p2pssizes.png">
		<img src="images/cinismo/p2pssizes.png" width="40%">
	</a>
</center>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

