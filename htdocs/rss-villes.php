<?php
require_once("/etc/baseobs/config.php");
require_once(DB_INC_PHP);
require_once(OBS_DIR."element.php");
require_once(OBS_DIR."rss.php");

$rss = new bobs_rss_especes_villes($db);
header("Content-Type: application/xml; charset=UTF-8");
echo $rss;
?>