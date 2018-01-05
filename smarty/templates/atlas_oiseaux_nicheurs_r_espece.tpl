{include file="poste_head.tpl" usedatatable=true usemap=true titre_page="$espece - C.AONFM"}
{literal}
<style>
	.wkt {display: none;}
{/literal}
{foreach from=$t_possible item=t}
	.e{$t} 
		{literal}{{/literal}
		color: {$c_possible}; 
		{literal}}{/literal}
{/foreach}
{foreach from=$t_probable item=t}
	.e{$t} 
		{literal}{{/literal}
		color: {$c_probable}; 
		{literal}}{/literal}
{/foreach}
{foreach from=$t_certain item=t}
	.e{$t} 
		{literal}{{/literal}
		color: {$c_certain}; 
		{literal}}{/literal}
{/foreach}
{literal}
.e591 {
	background-color: red;
	color: white;
}
{/literal}
</style>
<h1>Détail carré <a href="?t=atlas_oiseaux_nicheurs_r_carre&id_espace={$carre.id_espace}">{$carre.nom}</a> pour {$espece}</h1>
{foreach from=$msgs item=m}<div class="info">{$m}</div>{/foreach}
<div id="map" style="height:300px; width:100%;"></div>
<table id="t" class="display" cellpadding="0" cellspacing="0">
	<thead>
	<tr>
		<th>Citation</th>
		<th>Date</th>
		<th>Eff.</th>
		<th>Commune</th>
		<th>Loc.</th>
		<th>Observateurs</th>
		<th>Codes comportements</th>
	</tr>
	</thead>
	<tbody>
{foreach from=$selection_carre->get_citations() item=cit}
	{assign var=observation value=$cit->get_observation()}
	{assign var=espace value=$observation->get_espace()}
	{if $cit->id_espece eq $id_espece}
	<tr>
		<td><a href="?t=citation&id={$cit->id_citation}">{$cit->id_citation}</a></td>
		<td>{$observation->date_observation}</td>
		<td>
			{if $cit->nb > 0}{$cit->nb}{/if}
			{if $cit->nb < 0}Prospection négative{/if}
		</td>
		<td>
			{if $espace->get_table() eq 'espace_point'}
				{$espace->get_commune()}
				<div class="wkt" id="wkt_p_{$cit->id_citation}" title="{$cit->id_citation}">{$espace->get_geom()}</div>
			{/if}
		</td>
		<td><a href="javascript:saisie_set_marqueur_pos(m,marqueurs,{$espace->get_x()},{$espace->get_y()});">voir</a></td>
		<td>{$observation->get_observateurs_str()}</td>
		<td>
			{foreach from=$cit->get_tags() item=tag}
				{if $tag.id_tag ne 579}
					<span class="e{$tag.id_tag} e{$tag.ref}">{$tag.lib}</span>
				{/if}
			{/foreach}
		</td>
	</tr>
	{/if}
{/foreach}
	</tbody>
</table>
<script>
	{literal}

	function saisie_set_marqueur_pos(carte,layer,x,y) {
		var p = new OpenLayers.LonLat(x,y);
		for (var i=0; i<layer.markers.length; i++)
			layer.removeMarker(layer.markers[i]);
		p.transform(carte.displayProjection, carte.projection);
		layer_marqueur_ajouter_icone(layer, p, '/poste/icones/panoramic.png', 32, 37);
		carte.setCenter(p, 14);
	}

	carte = document.getElementById('map');
	var m = carte_inserer(carte);
	var pt = new OpenLayers.LonLat(2.80151, 49.69606);
	pt.transform(m.displayProjection, m.projection);
	m.setCenter(pt, 8);
	var marqueurs = carte_ajout_layer_marqueurs(m, 'marqueur');
	log('ok');

	var lv2 = new OpenLayers.Layer.Vector('tous les points');
	var rwkt = new OpenLayers.Format.WKT();
	var points = J('.wkt');
	log(points.length+" a traiter");
	var features = new Array();
	for (var i=0; i<points.length; i++) {
		var p = rwkt.read(points[i].innerHTML);
		p.data = {id_citation: points[i].title};
		p.geometry.transform(m.displayProjection, m.projection);
		features.push(p);
	}
	log(features.length+' a ajouter');
	lv2.addFeatures(features);
	m.addLayer(lv2);
	b = lv2.getDataExtent();
	m.zoomToExtent(b);

	var ctrl = new OpenLayers.Control.SelectFeature(lv2, {
		onSelect: function (e) { 
			dt.fnFilter(e.data.id_citation);
		},
		onUnselect: function (e) {
			dt.fnFilter('');
		}
	});
	m.addControl(ctrl);
	ctrl.activate();

	var dt = J('#t').dataTable({oLanguage: datatable_fr()});
	{/literal}
</script>
<div style="clear:both;"></div>
Code couleur : <font color="{$c_possible}">nicheur possible</font>, <font color="{$c_probable}">probable</font>, <font color="{$c_certain}">certain</font>.
{include file="poste_foot.tpl"}
