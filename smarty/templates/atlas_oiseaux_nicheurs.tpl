{include file=poste_head.tpl titre_page="Atlas oiseaux nicheurs"}
<h1>Atlas des oiseaux nicheurs</h1>
{if $pas_membre}
	Pour consulter l'atlas des oiseaux nicheurs vous devez être membre du réseau avifaune.
{else}
<div style="display:none">
	<div id="dlg-carre"></div>	
</div>
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
<div id="carte" style="width:100%; height:600px;"></div>
<script>
//{literal}
var m = carte_inserer(document.getElementById('carte'));

var stylemap = new OpenLayers.StyleMap({'default':{
		    strokeColor: "#000000",
		    strokeOpacity: 1,
		    strokeWidth: 1,
		    fillColor: "${couleur}",
                    fillOpacity: 0.5,
                    pointRadius: 6,
                    pointerEvents: "visiblePainted",
                    label : "${n}",
		    fontWeight: 'bold'
		}}
		);


var lv  = new OpenLayers.Layer.Vector('Carrés Atlas',{styleMap: stylemap});
var f_out = new OpenLayers.Format.WKT();

function ouvre_carre(c) {
    J('#dlg-carre').dialog({width:600, height:400, title: c});
    J('#dlg-carre').html('chargement données carré '+c);
    J('#dlg-carre').load('?t=info_carre_atlas&voir_nicheur=1&carre='+c);
}

function espace_selection(evt) {
	log(evt);
    var c = evt.feature.attributes.nom;
    ouvre_carre(c);
}

var pt = new OpenLayers.LonLat(2.80151, 49.69606);
pt.transform(m.displayProjection, m.projection);
m.setCenter(pt, 8);
var the_features = new Array();
function ajout(wkt,nom,n) {
	var feature = f_out.read(wkt);
	if (!feature) log(wkt);
	feature.geometry.transform(m.displayProjection, m.projection);
	if (n >= 70) c = '#ffaaaa';
	else if (n >= 35) c = '#aaaaaa';
	else if (n >= 10) c = '#66aaaa';
	else if (n > 0) c = '#22aaaa';
	else c = '#aaaaff';
	feature.attributes = {nom: nom, n: n, couleur: c};
	the_features.push(feature);
}
//{/literal}
var compte;

{foreach from=$carres item=c}
	{assign var=n value=0}
	{if $compte[$c.nom]>0}
		{assign var=n value=$compte[$c.nom]}
	{/if}
	ajout('{$c.wkt}','{$c.nom}',{$n});
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
{include file=poste_foot.tpl}
