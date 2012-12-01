<?php

session_start();

if (empty($_SESSION['count'])) {
 $_SESSION['count'] = 1;
} else {
 $_SESSION['count']++;
 if ($_SESSION['count'] > 3) {
	 session_destroy();
 }
}
?>

<html>
<body>
<p>
Hello visitor, you have seen this page <?php echo $_SESSION['count']; ?> times.
</p>

<p>
To continue, <a href="test.php?<?php echo htmlspecialchars(SID); ?>">click
here</a>.
</p>
</body>
</html>
