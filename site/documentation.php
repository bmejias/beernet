<?php
require("functions.php");

makeHeader( "Beernet - Publications and Documentation",
			"Beernet",
			"The relaxed pBeer-to-pBeer network");

menu("docs");
?>

<div id="maincontent">

<h2>Publications</h2>

<p> Beernet is the result of academic research, and therefore, the main way of 
documenting our work is by publishing papers. If you are not interested in 
reading papers, there are other sources of docuementation below. </p>

<h3> Journal </h3>

<ul>
	<li><a href="papers/relaxed-ring-ws-ppl.pdf">"The Relaxed-Ring: A 
fault-tolerant topology for structured overlay networks"</a> - Boris 
Mej&iacute;as and Peter Van Roy. In <em> Parallel Processing Letters</em>, Vol. 18(3):411--432, World Scientific, September 2008. </li>
</ul>

<h3> Conferences </h3>

<ul>
	<li><a href="papers/palta-sccc.pdf">"PALTA : Peer-to-peer AdaptabLe 
Topology for Ambient intelligence"</a> - Alfredo C&aacute;diz, Boris 
Mej&iacute;as, Jorge Vallejos, Kim Mens, Peter Van Roy, Wolfgang de Meuter. In 
<em>SCCC'08: Proceedings of the XXVII International Conference of the Chilean 
Computer Science Society</em>, pages 100--109, November 2008, IEEE Computer 
Society. </li>
	<li><a href="papers/relaxed-ring-sccc.pdf">"A Relaxed-Ring for 
Self-Organising and Fault-Tolerant Peer-to-Peer Networks"</a> - Boris 
Mej&iacute;as and Peter Van Roy. In <em>SCCC'07: Proceedings of the XXVI 
International Conference of the Chilean Computer Science Society</em>, pages 
13--22, November 2007, IEEE Computer Society. </li>
	<li><a href="papers/demoTransDHT.pdf">"Visualizing Transactional 
Algorithms for DHTs"</a> - Boris Mej&iacute;as, Mikael Hogqvist and Peter Van 
Roy. In <em> Proceedings of the Eighth IEEE Peer-to-peer Conference</em>, 
pages 79-80, September 2008.  Demo. </li>
	<li><a href="papers/pepino.pdf">"PEPINO: PEer-to-Peer network 
INspectOr"</a> - Donatien Grolaux, Boris Mej&iacute;as and Peter Van Roy. In 
<em> Proceedings of the Seventh IEEE Peer-to-peer Conference</em>, pages 
247-248, September 2007. Demo. </li>
</ul>

<h3> Workshops </h3>

<ul>
	<li><a href="papers/palta-saso.pdf">"A Self-Adaptable Network Topology for 
Ambient Intelligence"</a> - Boris Mej&iacute;as, Alfredo C&aacute;diz, Peter 
Van Roy, Kim Mens. <em> Workshop on Decentralized Self Management for Grids, 
P2P and User Communities (SELFMAN).</em> October 2008. </li>
	<li><a href="papers/wsn-p2p-saso.pdf">"WSN and P2P: a self-managing 
marriage"</a> - Gustavo Guti&eacute;rrez, Boris Mej&iacute;as, Peter Van Roy 
and Diana Velasco and Juan Torres. <em> Workshop on Decentralized Self 
Management for Grids, P2P and User Communities (SELFMAN).</em> October 2008.  
</li>
	<li><a href="papers/relaxed-ring-coregrid.pdf">"Improving the Peer-to-Peer 
Ring for Building Fault-Tolerant Grids"</a> - Boris Mejias, Donatien Grolaux 
and Peter Van Roy. <em> CoreGRID Workshop on Grid-* and P2P-* .</em> June 
2007. </li>
</ul>

<h3> Presentations </h3>

<ul>
	<li><a href="papers/beernetAntwerpen.pdf">"Self Management of Large Scale
Distributed Systems"</a> (relaxed-ring and transactions) - Boris 
Mej&iacute;as. <em>Invited Talk at "Seminarie Computernetwerken"</em>, 
Univeristeit Antwerpen, March 2009. </li>
	<li><a href="papers/beernetMons.pdf">"Self Management of Large Scale 
Distributed Systems"</a> (relaxed-ring and feedback loops) - Boris 
Mej&iacute;as.  <em>Presentation at EuroDocInfo'09</em>, Mons, Jan 2009. </li> 
</ul>

<h2> Documentation </h2>

<p> This section is more oriented to developers than researchers. You can 
check the <a 
href="http://gforge.info.ucl.ac.be/plugins/wiki/index.php?id=15&type=g"> 
Wiki</a> of P2PS, which is the predecessor of Beernet, and <a 
href="papers/sinf-slides.pdf">this slides</a> which contains a short 
introduction to the relaxed-ring and some examples about how to use P2PS's 
API. </p>


</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

