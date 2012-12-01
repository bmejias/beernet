<?php
require("functions.php");

makeHeader( "DeTransDraw: Decentralized Transactional collaborative Drawing",
			"DeTransDraw",
			"Decentralized Transactional collaborative Drawing");

menu("detransdraw");
?>

<div id="maincontent">

<h2>DeTransDraw: Decentralized Transactional collaborative Drawing</h2>

<p> DeTransDraw is a decentralized collaborative vector-based graphical editor
with a shared drawing area.  It provides synchronous collaboration between 
users with graphical support for notifications about other users' activities.
Conflict resolution is achieved with a decentralized transactional service
with storage replication, and self-management replication for fault-tolerance.
The transactional service also allows the application to prevent performance
degradation due to network latency, which is an important feature for
synchronous collaboration. </p>

<?php
/* Jérémie: Add a longer description here of DeTransDraw */
?>

<h2>Screenshots</h2>

<p> DeTransDraw offers a simple user interface to create a ring of P2PS nodes.
The first screenshot is the manager window for the node 21797.
Two buttons named <i>Save:</i> and <i>Save</i> allow the user to save the 
ticket, while <i>Load:</i> and <i>Join</i> help to connect to some already 
saved tickets.
When the ring is ready, the editor window may be opened thanks to 
<i>Open editor</i> button.</p> 

<center>
	<a href="images/detransdraw/manager.png">
		<img src="images/detransdraw/manager.png" width="324">
	</a>
</center>

<p> The drawing area is divided in three parts : the toolbar, the drawing part 
and the status bar.
Button <i>SEL</i> stands for the selection of an object or multiple object 
with <i>Shift</i> key pressed.
The buttons <i>rect</i> and <i>oval</i> allows the user to draw rectangles 
and ovals.
The two colored buttons represent the color of the object and its border.
The status bar notifies the user of the action he is currently doing.</p> 

<center>
	<a href="images/detransdraw/pc_DTD_drawing.png">
		<img src="images/detransdraw/pc_DTD_drawing.png" width="80%">
	</a>
</center>

<p> If the user is in selection mode, he is able to select either rectangles or 
ovals.
A selected object appears with nine dots at each coins and center of coins.</p> 

<center>
	<a href="images/detransdraw/pc_DTD_selecting.png">
		<img src="images/detransdraw/pc_DTD_selecting.png" width="80%">
	</a>
</center>

<p> As it appears in the following screenshots, the dots may be filled 
in black or red.
The colour depends on the status of the lock for the object.
Here, the user on the left try to select the cyan rectangle 
which is already selected by the user of the right window.
When an object is selected, the node try to lock it.
While trying to get the lock, the dots are in red meaning that the lock 
may not be accepted.
The user on the left will see the object unselected and back 
to the original position as soon as the lock is refused.
The user on the right has got the lock and the dots are black.</p> 

<center>
	<a href="images/detransdraw/pc_DTD_lock.png">
		<img src="images/detransdraw/pc_DTD_lock.png" width="100%">
	</a>
</center>

<h2>How to install and run DeTransDraw</h2>

<p>Requirements : <a href="http://www.mozart-oz.org/download/view.cgi?action=default&version=1.4.0">Mozart 1.4.0</a></p>

<p>Installation : Download <a href="http://beernet.info.ucl.ac.be/store/DeTransDraw-oz1.4.zip"> DeTransDraw binaries</a>
and extract it.</p>

<p>Run in real mode : Each user should execute DT.exe to get the manager window.
If there are more than ten users, one of the user may save a ticket and 
send it to other users which will load it.
A ring of nodes without drawing features may be created with the Bootstrap binary with option <i>dss</i>.</p>

<p>Run in simulation mode : First create the ring with Bootstrap binary with option <i>sim</i>.
Each user can join the ring loading a ticket of this ring or connect with this command : 
<br/> ./DT.exe sim URL <br/>
Where <i>URL</i> is the location of a ticket of this ring. 
</p>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

