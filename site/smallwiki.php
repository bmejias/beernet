<?php
require("functions.php");

makeHeader( "Small Wiki: a fully decentralized transactional wiki",
			"Small Wiki",
			"Small Wiki: a fully decentralized transactional wiki");

menu("smallwiki");
?>

<div id="maincontent">

<h2></h2>

<p> This is the result of a student assignment of a course our research group 
gives on distributed applications. The goal is to implement a prototype of a 
decentralized version of the <em>Wikipedia</em>. It is inspired on the 
Wikipedia version implemented with <a 
href="http://code.google.com/p/scalaris/">Scalaris</a>, which is also a 
distributed transactional key-value store. </p>

<h2>Screenshots</h2>

<p> The following screenshot is taken from the work of students Quentin Pirmez 
and Laurent Pierson, called WikipediOz. The figure shows how the GUI works. In 
the example, each of two users is modifying two paragraphs on the same 
article. One of the paragraph has a conflict, and therefore, only one of the 
commits succeeds.  </p>

<p>
<center>
	<a href="images/smallwiki/wikipedioz.png">
		<img src="images/smallwiki/wikipedioz.png" width="100%">
	</a>
</center>
</p>

<h2>Architecture</h2>

<p> To store data in a DHT, the information has to be stored as items with a
key-value pair. A paragraph in an article was the granularity used to organize
the information of the wiki. Articles where stored as a list of paragraphs.
Using articles as the minimal granularity would have not been convenient
because users never update more than one article at the time. Therefore, the
transactional layer would have been used to update only an item at the time,
being useful only for managing replica consistency. Furthermore, such
granularity would not allow concurrent user to work on the same article.
The following figure depicts how using paragraphs as the minimal
granularity can be useful to allow concurrent users updating the same article.
On the figure, both users get a copy of an article composed by three
paragraphs. Each paragraph has its own version, marked as timestamps (ts).
User <em>A</em> modifies paragraph 1 and 3, while user <em>B</em> modifies 
paragraph 2. When user <em>A</em> commits her changes, the transactional layer 
guarantees that both paragraph will be updated, or none of them will. This 
property is particularly interesting if we consider that the article could be 
source code of a program instead. Allowing only one change could introduce an 
error in the program. Continuing with the example, since modifications of 
users <em>A</em> and  <em>B</em> do not conflict, both transactions commit 
successfully. Consequently, if user <em>B</em> would have also modified either 
paragraph 1 or 3, only one of the commits would have succeeded. It is up to 
the application to decide how resolve the conflict. </p>

<p>
<center>
	<a href="images/smallwiki/wiki-update-ok.png">
		<img src="images/smallwiki/wiki-update-ok.png" width="100%">
	</a>
</center>
</p>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>

