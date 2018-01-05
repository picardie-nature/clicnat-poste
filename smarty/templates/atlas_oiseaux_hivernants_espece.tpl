{include file=poste_head.tpl titre_page="Atlas hivernant"}
<div style="display:hidden;">
    <div id="dlg-carre"></div>
</div>
<h1>Atlas oiseaux hivernants 2009 - 2013</h1>
<h2>{$esp}</h2>
{if $pas_membre}
	Pour consulter l'atlas des oiseaux hivernants vous devez être membre du réseau avifaune.
{else}
{if $esp->classe == 'O'}	    
<div id="carte" border="1" style="width:100%; height:600px;"></div>
<h4>Liste des carrés occupé</h4>
<div align="center">
<table width="90%">
    <tr>
	<th>12-2009 - 01-2010</th>
	<th>12-2010 - 01-2011</th>
	<th>12-2011 - 01-2012</th>
	<th>12-2012 - 01-2013</th>
    </tr>
    <tr>
	<td valign="top" width="25%" valign="top">
	    {foreach from=$esp->get_carres_hivernant(2009) item=carre}
	    <a href="javascript:ouvre_carre('{$carre.nom}');">{$carre.nom}</a>
	    {foreachelse}
		Aucun carré
	    {/foreach}
	</td>
	<td valign="top" width="25%" valign="top">
	    {foreach from=$esp->get_carres_hivernant(2010) item=carre}
	    <a href="javascript:ouvre_carre('{$carre.nom}');">{$carre.nom}</a>
	    {foreachelse}
		Aucun carré
	    {/foreach}
	</td>
	<td valign="top" width="25%" valign="top">
	    {foreach from=$esp->get_carres_hivernant(2011) item=carre}
	    <a href="javascript:ouvre_carre('{$carre.nom}');">{$carre.nom}</a>
	    {foreachelse}
		Aucun carré
	    {/foreach}
	</td>
	<td valign="top" width="25%" valign="top">
	    {foreach from=$esp->get_carres_hivernant(2012) item=carre}
	    <a href="javascript:ouvre_carre('{$carre.nom}');">{$carre.nom}</a>
	    {foreachelse}
		Aucun carré
	    {/foreach}
	</td>

    </tr>
</table>
</div>
<h1>Oiseaux hivernants</h1>
{foreach from=$hivernants item=oiseau}
	<a href="?t=espece_detail&id={$oiseau.id_espece}">{$oiseau.nom_f}</a><br/>
{/foreach}

<script>
    //{literal}
var m = carte_inserer(document.getElementById('carte'));
var pt = new OpenLayers.LonLat(2.80151, 49.69606);
pt.transform(m.displayProjection, m.projection);

var stylemap = new OpenLayers.StyleMap({'default':{
		    strokeColor: "#000000",
		    strokeOpacity: 1,
		    strokeWidth: 1,
		    fillColor: "${couleur}",
                    fillOpacity: 0.5,
                    pointRadius: 6,
                    pointerEvents: "visiblePainted",
                    label : "${getLabel}",
		    fontWeight: 'bold'
		}}, 
		{context: {
		    getLabel: function(feature) {
			    if(feature.layer.map.getZoom() > 0) {
				return feature.attributes.name;
			    }
		    }
		}}
		);

var l2009 = new OpenLayers.Layer.Vector('Hivernant 12-2009 01-2010', {styleMap: stylemap});
var l2010 = new OpenLayers.Layer.Vector('Hivernant 12-2010 01-2011', {styleMap: stylemap});
var l2011 = new OpenLayers.Layer.Vector('Hivernant 12-2011 01-2012', {styleMap: stylemap});
var l2012 = new OpenLayers.Layer.Vector('Hivernant 12-2012 01-2013', {styleMap: stylemap});

m.addLayer(l2009);
m.addLayer(l2010);
m.addLayer(l2011);
m.addLayer(l2012);

function ouvre_carre(c)
{
    J('#dlg-carre').dialog({width:600, height:400, title: c});
    J('#dlg-carre').html('chargement données carré '+c);
    J('#dlg-carre').load('?t=info_carre_atlas&carre='+c);
}

function espace_selection(evt) 
{
    var c = evt.feature.attributes.name;
    ouvre_carre(c);
}

var ctrl_select = new OpenLayers.Control.SelectFeature([l2009,l2010,l2011,l2012], {});
ctrl_select.events.register('featurehighlighted', null, espace_selection);

m.addControl(ctrl_select);
ctrl_select.activate();
m.setCenter(pt, 8);

var f_out = new  OpenLayers.Format.WKT();

function get_label(feature) {
    if(feature.layer.map.getZoom() >= 10) {
	return feature.attributes.name;
    }
    return '';
}

function ajouter_feature(layer, data, nom, couleur) {
    var feature = f_out.read(data);
    feature.geometry.transform(m.displayProjection, m.projection);
    feature.attributes = {name: nom, getLabel: get_label, 'couleur':couleur};
    layer.addFeatures([feature]);
}
//{/literal}
{foreach from=$esp->get_carres_hivernant(2009) item=carre}
    ajouter_feature(l2009, '{$carre.wkt}', "{$carre.nom}", '#aeffae');
{/foreach}
{foreach from=$esp->get_carres_hivernant(2010) item=carre}
    ajouter_feature(l2010, '{$carre.wkt}', "{$carre.nom}", '#aeaeff');
{/foreach}
{foreach from=$esp->get_carres_hivernant(2011) item=carre}
    ajouter_feature(l2011, '{$carre.wkt}', "{$carre.nom}", '#ffaeae');
{/foreach}
{foreach from=$esp->get_carres_hivernant(2012) item=carre}
    ajouter_feature(l2012, '{$carre.wkt}', "{$carre.nom}", '#ffaeff');
{/foreach}
</script>
{else}
Ça ne peut fonctionner que pour les oiseaux.
{/if}
{/if}
{include file="poste_foot.tpl"}
