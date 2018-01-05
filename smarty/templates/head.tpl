<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr">
{assign var="url_deco" value="http://deco.picardie-nature.org"}
<head>
        <title>{$title|default:"Poste d'observations - Picardie Nature"}</title>
        <meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
	<link href="http://deco.picardie-nature.org/pix/style.css" media="all" rel="stylesheet" type="text/css" />
	<link href="http://deco.picardie-nature.org/jquery/css/redmond/jquery-ui-1.8.2.custom.css" media="all" rel="stylesheet" type="text/css" />
	<link href="http://deco.picardie-nature.org/pix/bobs.css" media="all" rel="stylesheet" type="text/css" />
	<link href="css/site.css" media="all" rel="stylesheet" type="text/css" />
</head>
<body>
	<script src="http://deco.picardie-nature.org/prototype/prototype.js" language="javascript"></script>
	<script src="http://deco.picardie-nature.org/scriptaculous/effects.js" language="javascript"></script>
	<script src="http://deco.picardie-nature.org/scriptaculous/controls.js" language="javascript"></script>
	{if $usemap}
	    <script src="//cdnjs.cloudflare.com/ajax/libs/openlayers/2.12/OpenLayers.js"></script>
	    <script src="https://maps.googleapis.com/maps/api/js?key={$google_key}&sensor=false"></script>
	    <script src="http://deco.picardie-nature.org/proj4js/lib/proj4js-compressed.js" language="javascript"></script>
	    <script src="js/carte.js" language="javascript"></script>
	{/if}
	<script src="http://deco.picardie-nature.org/jquery/js/jquery-1.7.1.min.js" language="javascript"></script>
	<script src="http://deco.picardie-nature.org/jquery/js/jquery-ui-1.8.2.custom.min.js" language="javascript"></script>
	<script src="http://deco.picardie-nature.org/jquery/js/jquery.ui.datepicker-fr.js" language="javascript"></script>
	<script src="http://deco.picardie-nature.org/jquery/jstree/jquery.tree.js" language="javascript"></script>
	<script src="http://deco.picardie-nature.org/jquery/jstree/plugins/jquery.tree.checkbox.js" language="javascript"></script>
	{if $usejqplot}
	    <!--[if IE]><script language="javascript" type="text/javascript" src="excanvas.js"></script><![endif]-->
	    <script language="javascript" type="text/javascript" src="http://deco.picardie-nature.org/jquery/jqplot/jquery.jqplot.min.js"></script>
	    <link rel="stylesheet" type="text/css" href="http://deco.picardie-nature.org/jquery/jqplot/jquery.jqplot.css" />
	{/if}
	{if $useplusone}
		{literal}<script type="text/javascript" src="https://apis.google.com/js/plusone.js">{lang: 'fr'}</script>{/literal}
	{/if}
	<style>
	{literal}
	.bobs-table {
		font-size: 12px;
		background-color: #fafafa;
	}
	.bobs-table th {
		border: 1px solid #d90019;
		background-color: #d90019;
		color: white;
	}
	.bobs-table table {
		border-collapse: collapse;
	}

	.bobs-table td {
		border: 1px solid #808080;
	}

	.bobs-table tr:hover {
		background-color: #D90019;
		color: white;
	}
	.bobs-table tr:hover a {
		color: white;
	}
	.bobs-demi {
		height: 250px;
		max-height: 250px;
		width:49%;
		float:left;
		background-color:white;
		margin: 0.125%;
		border-style:solid;
		border-color: #d90019;
		border-width: 2px;
	}
	.bobs-demi-titre, .bobs-entier-titre {
		background-color: #d90019;
		color: white;
		height: 30px;
		font-size: 16px;
		font-weight: bold;
		padding-left: 2px;
		padding-right: 2px;
	}
	.bobs-demi-interieur, .bobs-entier-interieur {
		height: 220px;
		max-height: 220px;
		font-size: 12px;
		padding-left: 4px;
		padding-right: 4px;
		overflow: auto;
	}
	.bobs-entier {
		width:98.5%;
		margin: 0.125%;
		float:left;
		background-color:white;
		margin:3px;
		border-style:solid;
		border-color: #d90019;
		border-width:2px;
		height:250px;
	}
	{/literal}
	</style>
	<script>
	
	{literal}
	var J = jQuery.noConflict();

	function log(msg) {
		try {
			if (console.firebug)
				console.info(msg);
		} catch (e) {
			return false;
		}
	}

	function dialog_vignette(div_id, obs_id)
	{
		$(div_id+'-img').src='icones/load.gif';
		$(div_id+'-img').src='?t=obs_vignette&id='+obs_id;
		J('#'+div_id).dialog({title: "Observation #"+obs_id,width: 500,height: 400});
	}
	
	log('firebug ok');
	{/literal}
	</script>
	<!--[if IE]>
	<style>
		{literal}
		.hoverscroll {
			display: inline;
		}
		{/literal}
	</style>
	<![endif]-->
	<div id="globcont">
	<div class="bloc-haut">
		<div id="b-haut-1cont">
		<div id="b-haut-1">
		<div id="b-haut-1in">
			<div id="b-haut-logo">
				<img src="http://deco.picardie-nature.org/pix/logo_top.png"/>
			</div>
			<div id="b-haut-pancartes">
				<img src="http://deco.picardie-nature.org/pix/pancartes_accueil.png"/>
			</div>
		</div>
		</div>
		</div>
		<div id="b-haut-2">&nbsp;</div>

	</div><!-- /bloc-haut -->
	{if $auth_ok}
	<div id="oreille_gauche" class="oreille">
		<h1>Observatoire</h1>
		<img src="http://deco.picardie-nature.org/pix/titre_observatoire.png"/>
		<ul>
			<li><a href="?t=accueil">Accueil</a></li>
			<li><a href="?t=mapage">Mon compte</a></li>
			<li><a href="?t=saisie">Saisir mes observations</a> </li>
			<li><a href="?t=journal">Consulter les observations</a></li>
			<li><a href="?t=selections">Sélections</a> </li>
			<li><a href="?t=especes">Liste des espèces</a></li>
			{if $u->membre_reseau('av')}
				<h1>Avifaune</h1>
				<li><a href="?t=atlas_hivernant">Atlas oiseaux hivernants</a></li>
				<li><a href="?t=atlas_oiseaux_nicheurs">Atlas oiseaux nicheurs</a></li>
			{/if}
			{if $u->membre_reseau('cs')}
				<h1>Chiros</h1>
				{if $u->acces_chiros}
					<li><a href="?t=chiros">Prospections Chiros</a></li>
				{/if}
			{/if}
			{if $u->structure()}
			<h1>Structures</h1>
			<li><a href="?t=structure_referentiel_espece">Référentiel espèce</a></li>
			{/if}
			<li><a href="?t=accueil&fermer=1">Fermer</a></li>
		</ul>
	</div>
	{/if}
	<div class="pn_main" style="min-height:600px; ">
