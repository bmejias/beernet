<?php
require("functions.php");

makeHeader( "PEPINO: PEer-to-Peer network INspectOr",
			"PEPINO",
			"PEer-to-Peer network INspectOr");

menu("pepino");
?>

<div id="maincontent">

<h2>PEPINO: PEer-to-Peer network INspectOr</h2>

<p> PEPINO is a graphical PEer-to-Peer network INspectOr running on top of <a
	href="index.php"> P2PS</a>, a structured overlay network using the 
Relaxed-Ring topology. The goal is to monitor the network by detecting 
failures, and by observing the messages sent between peers.  A dynamic and 
self-organizing view of the network is presented to the user, who can 
interacts with it to inject failures or send messages in order to study the 
network protocols. </p>

<p> Since many systems implement <strong>DHT</strong> in different ways - in
particular by choosing the finger table with a different strategy -
<strong>PEPINO</strong> also helps to study three different strategies, in
particular finger tables following the strategy of <a
	href="http://dks.sics.se"> DKS</a>, <strong>Tango</strong>, and <a
	href="http://pdos.csail.mit.edu/papers/chord:sigcomm01/"> Chord </a>.  A
demo of <strong>PEPINO</strong> was shown in the Seventh IEEE international
Conference on Peer-to-Peer Computing (<a
	href="http://www.p2p2007.org">P2P'07</a>).  </p>

<h2>Screenshots</h2>

<p> Some screen-shots are presented on this page to depicts some of the
features of PEPINO. The following image shows a ring composed by 10 nodes.
Arrows have different colours in order to present meaningful information. Green
arrows represent successor pointers. Red ones correspond to predecessors. Blue
arrows are fingers. On the bottom-right corner there are 3 buttons to organized
the ring according to a particular colour. In the case of the image,
predecessor pointers are followed to verified that no inconsistency is
presented (correct sharing of responsibility). Fingers and other arrows are
highlighted when the mouse is focus on top of a particular node. </p>

<center>
	<a href="images/pepino/fingers.jpg">
		<img src="images/pepino/fingers.jpg" width="80%">
	</a>
</center>

<p> One of the main features that differentiate the relaxed-ring from other 
structured overlay networks, is the ability of accepting nodes with 
connectivity problems forming branches annexed to the core ring. The following 
screen-shot organized the peers with respect to the successor pointer (green 
arrow). It is possible to observe peers painted in yellow as members of the 
cor ring, and white peers belonging to branches.  </p>

<center>
	<a href="images/pepino/branch-fingers.jpg">
		<img src="images/pepino/branch-fingers.jpg" width="80%">
	</a>
</center>

<p> <strong>PEPINO</strong> not only visualizes the network as a ring of 
peers. It also shows the messages exchanged between nodes as it is depicted on 
the screen-shot here bellow. This feature is place at the resizable left side 
of the application. If the mouse is place over a message exchanged between to 
peers, all the other messages between them will be highlighted. </p>

<center>
	<a href="images/pepino/events.jpg">
		<img src="images/pepino/events.jpg" width="80%">
	</a>
</center>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

