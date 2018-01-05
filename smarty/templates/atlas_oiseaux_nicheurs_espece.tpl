{include file="poste_head.tpl" titre_page="AONFM - $espece"}
{literal}
<style>
	.bobs-nicheur-possible {
		color: {/literal}{$c_possible}{literal};
	}
	.bobs-nicheur-probable {
		color: {/literal}{$c_probable}{literal};
	}
	.bobs-nicheur-certain {
		color: {/literal}{$c_certain}{literal};
	}
	.bobs-nicheur- {
		color: #793939;
		text-decoration: line-through;
	}
</style>
{/literal}
<h1>Atlas oiseaux nicheurs pour <i>{$espece}</i></h1>
{if $pas_membre}
	Pour consulter l'atlas des oiseaux nicheurs vous devez être membre du réseau avifaune.
{else}
<p>légende : 
	<span class="bobs-nicheur-possible">nicheur possible</span>,
	<span class="bobs-nicheur-probable">nicheur probable</span>,
	<span class="bobs-nicheur-certain">nicheur certain</span>
	[
	<a href="?t=atlas_oiseaux_nicheurs">Carte générale de l'atlas oiseaux nicheurs</a> -
	<a href="?t=espece_detail&id={$espece->id_espece}">Fiche espèce</a>]
</p>
<div style="display:none;">
	<div id="dlg-carre"></div>
</div>
<div id="carte" style="width:100%; height:600px;"></div>
<table>
<tr>
	<td width="50%" valign="top">
	<b>Dates d'observations du premier et dernier chanteur par an</b>
	<div class="bobs-table">
		<table>
		<tr>
			<th>Année</th>
			<th>Première date</th>
			<th>Dernière date</th>
		</tr>
		{foreach from=$espece->bornes_chanteurs() item=borne}
		<tr>
			<td>{$borne.annee}</td>
			<td>{$borne.premiere_date|date_format:"%d-%m-%Y"}</td>
			<td>{$borne.derniere_date|date_format:"%d-%m-%Y"}</td>
		</tr>	
		{/foreach}
		</table>
	</div>
	</td>
	<td valign="top">	
	<b>Bornes théoriques pour nidification possible</b>
	{assign var=bornes value=$espece->bornes_moyenne_chanteurs()}
	<ul>
		<li>Début : {$bornes.moy_premiere_date|string_format:"%d"}<sup>ème</sup> jour de l'année</li>
		<li>Fin : {$bornes.moy_derniere_date|string_format:"%d"}<sup>ème</sup> jour de l'année</li>
	</ul>
	<img src="?t=graphique_citations_chanteurs&id={$espece->id_espece}"/>
	</td>
	
</tr>
</table>
<script>
//{literal}
var m = carte_inserer(document.getElementById('carte'));

var stylemap =	new OpenLayers.StyleMap(
			{'default':
				{
    				strokeColor: "#000000",
    				strokeOpacity: 1,
    				strokeWidth: 1,
    				fillColor: "${couleur}",
    				fillOpacity: 0.5,
    				pointRadius: 6,
    				pointerEvents: "visiblePainted",
    				label: "${getLabel}",
    				fontWeight: 'bold'
				}
			}
	);

var lv  = new OpenLayers.Layer.Vector('Carrés Atlas', {styleMap: stylemap});
var f_out = new OpenLayers.Format.WKT();

function ouvre_carre(c)
{
    J('#dlg-carre').dialog({width:600, height:400, title: c});
    J('#dlg-carre').html('chargement données carré '+c);
    J('#dlg-carre').load('?t=info_carre_atlas&voir_nicheur=1&carre='+c);
}

function espace_selection(evt) 
{
	log(evt);
    var c = evt.feature.attributes.nom;
    ouvre_carre(c);
}

function get_label(feature) {
    if(feature.layer.map.getZoom() >= 10) {
		return feature.attributes.nom;
    }
    return '';
}

var pt = new OpenLayers.LonLat(2.80151, 49.69606);
pt.transform(m.displayProjection, m.projection);
m.setCenter(pt, 8);
var the_features = new Array();
function ajout(wkt,nom,statut) {
	var feature = f_out.read(wkt);
	if (!feature) log(wkt);
	
	feature.geometry.transform(m.displayProjection, m.projection);
	c = '#ffffff';
	switch (statut) {
		case 'certain': 
			c = '{/literal}{$c_certain}{literal}';
			break;
		case 'possible':
			c = '{/literal}{$c_possible}{literal}';
			break;
		case 'probable':
			c = '{/literal}{$c_probable}{literal}';
			break;
	}
	feature.attributes = {nom: nom, statut: statut, couleur: c, getLabel: get_label};
	the_features.push(feature);
}
//{/literal}
{foreach from=$carres item=c}
	ajout('{$c.carre->wkt}','{$c.carre->nom}', '{$c.statut}');
{/foreach}
lv.addFeatures(the_features);
m.addLayer(lv);
//{literal}
var ctrl_select = new OpenLayers.Control.SelectFeature([lv], {});
ctrl_select.events.register('featurehighlighted', null, espace_selection);
m.addControl(ctrl_select);
ctrl_select.activate();
J('#dlg-accueil').dialog({width:600, height:400, buttons: {'Fermer': function () { J('#dlg-accueil').dialog('close'); }}});
//{/literal}
</script>
{/if}
{include file="poste_foot.tpl"}
