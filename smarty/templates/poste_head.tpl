<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr">
<head>
	<title>{$titre_page} - Clicnat</title>
	<link rel="stylesheet" href="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/themes/redmond/jquery-ui.css" />
	<link href="css/site_v2_commun.css" media="all" rel="stylesheet" type="text/css"/>
	<link href="css/site_poste.css" media="all" rel="stylesheet" type="text/css"/>
	<link href="css/morris.css" media="all" rel="stylesheet" type="text/css"/>

	<link href="https://ssl.picardie-nature.org/statique/OpenLayers-2.13.1/theme/default/style.css" type="text/css" rel="stylesheet"/>
	<link href="https://ssl.picardie-nature.org/statique/OpenLayers-2.13.1/theme/default/google.css" type="text/css" rel="stylesheet"/>
	{if $install == "gonm"}
	<link href="css/site_poste_gonm.css" media="all" rel="stylesheet" type="text/css"/>
	{/if}
	{if $usedatatable}
	<link href="http://deco.picardie-nature.org/datatables/media/css/demo_table.css" media="all" rel="stylesheet" type="text/css"/>
	{/if}
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta http-equiv="X-UA-Compatible" content="IE=7" />
</head>
<body>
{if $usemap}
<!-- <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=true&v=3.5&key={$google_key}"></script>-->
<script src="https://maps.google.com/maps/api/js?v=3.5&amp;sensor=false"></script>
<script src="https://ssl.picardie-nature.org/statique/OpenLayers-2.master/OpenLayers.js"></script>
<script src="js/proj4.js" language="javascript"></script>
<script src="js/carte.js?a=b" language="javascript"></script>
{/if}
<script src="js/utils.js" language="javascript"></script>
<script src="//ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js"></script>
<script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.10.4/jquery-ui.min.js"></script>
<script src="http://deco.picardie-nature.org/jquery/js/jquery.ui.datepicker-fr.js" language="javascript"></script>
{if $usejqplot}
    <!--[if IE]><script language="javascript" type="text/javascript" src="excanvas.js"></script><![endif]-->
    <script language="javascript" type="text/javascript" src="http://deco.picardie-nature.org/jquery/jqplot/jquery.jqplot.min.js"></script>
    <link rel="stylesheet" type="text/css" href="http://deco.picardie-nature.org/jquery/jqplot/jquery.jqplot.css" />
{/if}
{if $useplusone}
	{literal}<script type="text/javascript" src="https://apis.google.com/js/plusone.js">{lang: 'fr'}</script>{/literal}
{/if}
{if $usedatatable}
<script src="http://deco.picardie-nature.org/datatables/jquery.dataTables.min.js" language="javascript"></script>
<script src="http://deco.picardie-nature.org/datatables/fr.js" language="javascript"></script>
{/if}
<script>

{literal}
var J = jQuery.noConflict();

function log(msg) {
	try {
		if (console)
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
{literal}
<style>

	div#banniere2 {
		padding-left:0px;
		padding-top: 155px;
	}
	.banniere ul{
		display:inline;
		margin: 0px;
		padding-left:0px;
	}
	li.nbanniere_li {
		display:inline;
	}
	li.nbanniere_li > a {
		background-color: white;
		padding: 7px;
		opacity: 0.6;
	}

	div.bloc_menu:hover {
		background-color: #eaffea;
	}
	div.bloc_menu {
		float: left;
		width: 125px;
		height: 125px;
		margin: 5px;
		padding: 5px;
		background-color: white;
		border: solid 1px black;
	}
	.bloc_menu p {
		padding: 0px;
		margin: 0px;
		font-size: 12px;
	}
	div.panneau_menu {
		height: 200px;
		background-color: white;
		display:none;
		border-width: 5px;
		border-color:rgb(198,229,72);
		border-style: solid;
		border-top-style: none;
		z-index: 2500;
		position: absolute;
		width:970px;
		padding:10px;
	}
	.menu_saisie img { display:none; }

	a.menu_saisie:hover > img {
		position: absolute;
		top: 10px;
		right:5px;
		display:block;
	}
</style>
{/literal}
<div id="globcont" style="min-width: 1000px;">
	<div class="bloc-haut" style="min-width: 1000px;">
		<div id="banniere">
			<div id="banniere2" class="banniere2">
				<ul>
				{if $u}
				<li class="nbanniere_li">
					<a class="panneau_btn" id_panneau="panneau_menu_1" href="javascript:;">Mon compte</a>
				</li>
				<li class="nbanniere_li">
					<a class="panneau_btn" id_panneau="panneau_menu_2" href="javascript:;">Saisie</a>
				</li>
				<li class="nbanniere_li">
					<a class="panneau_btn" id_panneau="panneau_menu_3" href="javascript:;">Recherche</a>
				</li>
				<li class="nbanniere_li">
					<div class="panneau_menu">Je suis là</div>
				</li>
				<li class="nbanniere_li">
					<a href="?t=accueil&fermer=1">Fermer</a>
					<div class="panneau_menu">Je suis là</div>
				</li>
				{/if}
				</ul>
				<!-- div vide nécessaire pour IE -->
				<div></div>
				<div class="panneau_menu" id="panneau_menu_1">
					<div class="bloc_menu">
						<a href="?t=accueil">Page d'accueil</a>
						<p>Revenir sur la page d'accueil</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=mapage">Modifier mes informations</a>
						<p>Modifier mon mot de passe, email...</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=taches">Taches</a>
						<p>Taches programmées (extraction, traitements ...)</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=fichiers">Fichiers</a>
						<p>C'est ici que sont enregistrés les documents produits pour vous</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=especes">Liste des espèces</a>
						<p>Consulter la liste des espèces accessible à la saisie</p>
					</div>
					{if $u->peut_ajouter_espece}
					<div class="bloc_menu">
						<a href="?t=espece_ajout_mnhn">Ajouter des espèces</a>
						<p>Ajouter des espèces au référentiel de Clicnat depuis celui du MNHN</p>
					</div>
					{/if}
				</div>
				<div class="panneau_menu" id="panneau_menu_2">
					Choisir un mode de saisie :<br/>
					<a class="menu_saisie" href="?t=saisie">
						Saisie sur fonds Google Maps
						<img src="image/saisie_google.jpg"/>
					</a><br/>
					<a class="menu_saisie" href="?t=v2_saisie">
						Saisie sur fonds IGN du Géoportail
						<img src="image/saisie_geoportail.jpg"/>
					</a><br/>
					{if $install == "picnat"}
					<a class="menu_saisie" href="?t=mangeoire_accueil">
						<img src="image/saisie_mangeoire.jpg"/>
						Mangeoire
					</a>
					{/if}
				</div>
				<div class="panneau_menu" id="panneau_menu_3">
					<div class="bloc_menu">
						<a href="?t=journal">Nouvelle extraction</a>
						<p>Créer une nouvelle extraction à partir de critères de recherche</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=selections">Mes sélections de données</a>
						<p>Résultats d'extractions précédentes</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=listes_especes">Listes d'espèces</a>
						<p>Créer ici des listes que vous pourrez utiliser dans vos extractions</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=listes_espaces">Listes de lieux</a>
						<p>Utilisée pour créer des cartes, cette interface n'a pas encore d'application pour tous</p>
					</div>
					<div class="bloc_menu">
						<a href="?t=flux">Flux d'observations</a>
						<p>Consulter rapidement les observations</p>
					</div>
				</div>
			</div>
		</div>
	</div>
	<script>
	{literal}
	function menu_click(e) {
		var a = J(e.currentTarget);
		var p = J('#'+a.attr('id_panneau'));
		if (p.is(':visible')) {
			// ferme tous les panneaux
			J('.panneau_menu').hide();
		} else {
			// ferme tous les panneaux et ouvre
			J('.panneau_menu').hide();
			J('#'+a.attr('id_panneau')).show();
		}
	}
	function menu_over(e) {
		if (e.type == 'mouseenter') {
			var a = J(e.currentTarget);
			J('.panneau_menu').hide();
			J('#'+a.attr('id_panneau')).show();
		}
	}
	function panneau_out(e) {
		if (e.type == 'mouseleave') {
			J('.panneau_menu').hide();
		}
	}
	J('.panneau_btn').hover(function (e) { menu_over(e) });
	J('.panneau_btn').click(function (e) { menu_click(e) });
	J('.panneau_menu').hover(function (e) { panneau_out(e) });
	{/literal}
	</script>
	<div class="pn_main">
	{foreach from=$bobs_msgs item=bobs_m}
		<div style="background-color:white; padding:3px; border-bottom:2px;"><i>Info</i> {$bobs_m}</div>
	{/foreach}
