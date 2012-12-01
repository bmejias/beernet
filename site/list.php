<?
// Here there is a collection of util functions

// +++++++++++++++++++++++++++++++++
//  WORKING WITH LIST (A LA SCHEME)
// +++++++++++++++++++++++++++++++++

function cons($aCar, $aCdr) {
  return array($aCar, $aCdr);
}

function car($aList) {
  return $aList[0];
}

function cdr($aList) {
  return $aList[1];
}

//utils for lists
function reverseList($aList, $acc) {
  if ($aList == 'nil') { return $acc; }
  return reverseList(cdr($aList), cons(car($aList), $acc));
}

function appendLists($list1, $list2) {
  if ($list1 == 'nil') { return $list2; }
  return cons( car($list1), appendLists( cdr($list1), $list2));
}

function insertReverseList($aList, $aElement) {
	if ($aList == 'nil') {
		return cons($aElement, 'nil');
	}
	$head = car($aList);
	if ($aElement > $head) {
		return cons($aElement, $aList);
	}
	return cons($head, insertReverseList(cdr($aList), $aElement));
}

?>
