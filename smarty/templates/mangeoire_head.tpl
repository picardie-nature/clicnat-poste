<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr">
<head>
	<title>{$titre_page} - Clicnat la mangeoire</title>
	<link href="css/site_v2_commun.css" media="all" rel="stylesheet" type="text/css"/>
	<link href="css/site_mangeoire.css" media="all" rel="stylesheet" type="text/css"/>
	<link href="http://deco.picardie-nature.org/jquery/css/redmond/jquery-ui-1.8.2.custom.css" media="all" rel="stylesheet" type="text/css" />
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
</head>
<body>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script> 
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
<script src="http://deco.picardie-nature.org/jquery/js/jquery.ui.datepicker-fr.js" language="javascript"></script>
<script language="javascript">var J = jQuery.noConflict();</script>
{if $usemap}
<script src="//cdnjs.cloudflare.com/ajax/libs/openlayers/2.13.1/OpenLayers.js"></script>
<script src="https://maps.googleapis.com/maps/api/js?key={$google_key}&sensor=false"></script>
<script src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js" language="javascript"></script>
<script src="js/carte.js?a=b" language="javascript"></script>
{/if}

<div id="globcont" style="min-width: 1000px;">

	<div class="bloc-haut" style="min-width: 1000px;">
		<div id="banniere">
			<div id="banniere2" class="banniere">
				<ul>
					<li ><a href="?t=accueil" title="vers le portail de saisie">&lt;&lt;</a></li>
					<li ><a href="?t=mangeoire_accueil">Accueil</a></li>
				</ul>
			</div>
		</div>

	</div>
	<div class="pn_main">

