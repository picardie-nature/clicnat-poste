{include file="poste_head.tpl" titre_page="NAV" usemap="true" usedatatable="true"}
{literal}
<style>
td { font-size: 12px; }
</style>
{/literal}
<div id="carte" style="width:100%; height:400px;"></div>
<div id="legende"></div>
<div id="carte-outils">
	<a class="b" id="reset" href="javascript:;">Remettre à zéro la sélection</a>
	<a class="b" id="modsel" href="javascript:;">Mode sélection</a>
	<a class="b" id="moddepl" href="javascript:;">Déplacement</a>
	<a class="b" id="aff" href="javascript:;">Voir données sélectionnées</a>
	<a class="b" id="coulesp" href="javascript:;">Coul/Esp</a>
	<a class="b" href="?t=selection&id={$s->id_selection}">Tab.</a>
</div>
<div id="selection">
<table id="t" class="display" cellpadding="0" cellspacing="0">
	<thead>
	<tr>
		<th>Citation</th>
		<th>Date</th>
		<th>Eff.</th>
		<th>Espèce</th>
		<th>Localisation</th>
		<th>Observateurs</th>
		<th>Codes comportements</th>
	</tr>
	</thead>
	<tbody>
	</tbody>
</table>
</div>
{literal}
<script>


var m = carte_inserer(document.getElementById('carte'));

var stylemap = new OpenLayers.StyleMap({'default':{
		    strokeColor: "#000000",
		    strokeOpacity: 1,
		    strokeWidth: 1,
		    fillColor: "#ff0000",
                    fillOpacity: 0.5,
                    pointRadius: 6
}});

function layer_legende_diff_esp(lv) {
	J('#legende').html('');
	var rules = new Array();
	var couleurs = ['#FFFF00','#FFFFFF','#00F5FF','#FF6347','#00EE76','#6959CD','#CD6839','#27408B','#EE0000','#7D26CD','#9AFF9A',
			'#C0FF3E','#FFDEAD','#FFF68F','#ADFF2F','#ADFF2F','#DEB887','#FF7F24','#DC143C'];
	var especes_faites = new Array();
	for (var i=0; i<lv.features.length; i++) {
		var id_espece = lv.features[i].data.id_espece;
		var idx = especes_faites.indexOf(id_espece);
		if (especes_faites.indexOf(lv.features[i].data.id_espece) < 0) {
			var couleur = couleurs[especes_faites.length%couleurs.length];
			rules.push(new OpenLayers.Rule({
				filter: new OpenLayers.Filter.Comparison({
					type: OpenLayers.Filter.Comparison.EQUAL_TO,
					property: "id_espece",
					value: id_espece
				}),
				symbolizer: {
					fillColor: couleur,
					strokeColor: couleur
				}
			}));
			especes_faites.push(lv.features[i].data.id_espece);
			J('#legende').append("<span style='background-color:"+couleur+"'>&nbsp;&nbsp;</span> "+lv.features[i].data.espece+" ");
		}
	}
	return new OpenLayers.Style({pointRadius: 6, strokeWidth: 1, fillOpacity: 1}, {rules: rules});
}

function layer_wfs(id_selection) {
	var lv  = new OpenLayers.Layer.Vector('Données', {
		styleMap: stylemap,
		strategies: [new OpenLayers.Strategy.BBOX()],
		projection: m.displayProjection,
		protocol: new OpenLayers.Protocol.WFS({
			url: "?t=selection_wfs",
			featureType: "selection_"+id_selection,
			featureNS: "http://www.clicnat.org/citation"
		})
	});
	return lv;
}

function voir() {
	var v_in;
	for (var i=0; i<lv.selectedFeatures.length; i++) {
		if (i == 0) {
			v_in = lv.selectedFeatures[i].data.id_citation;
		} else {
			v_in = v_in + ',' + lv.selectedFeatures[i].data.id_citation;
		}
	}
	dt.dataTableSettings[0].sAjaxSource = dt_url_base + '&in=' + v_in;
	dt.fnDraw();
}

{/literal}
var pt = new OpenLayers.LonLat({$xorg}, {$yorg});
var zoom = {$zorg};
var id_selection={$s->id_selection};
var lv = layer_wfs({$s->id_selection});
{literal}
m.addLayers([lv]);
pt.transform(m.displayProjection, m.projection);
m.setCenter(pt, zoom);
var ctrl = new OpenLayers.Control.SelectFeature(lv, {
	multiple: true,
	box: true
});
m.addControls([ctrl]);
ctrl.activate();
J('.b').button();
J('#reset').click(function () { 
	ctrl.unselectAll();
	dt.dataTableSettings[0].sAjaxSource = dt_url_base;
	dt.fnDraw();
});
J('#modsel').click(function () { ctrl.activate(); });
J('#moddepl').click(function () { ctrl.deactivate(); });
J('#aff').click(function () { voir(); });

var legende = 'simple';

J('#coulesp').click(function () {
	if (legende == 'coulesp') {
		var stylemap = new OpenLayers.StyleMap({'default':{
		    strokeColor: "#000000",
		    strokeOpacity: 1,
		    strokeWidth: 1,
		    fillColor: "#ff0000",
                    fillOpacity: 0.5,
                    pointRadius: 6
		}});
		lv.styleMap = stylemap;
		legende = 'simple';
		J('#legende').html('');
	} else {
		var news = layer_legende_diff_esp(lv);
		lv.styleMap.styles['default'] = news;
		legende = 'coulesp';
	}
	lv.redraw();
});
var dt_url_base = "?t=selection_datatable&sel="+id_selection;
var dt = J('#t').dataTable({
	"oLanguage": datatable_fr(),
	"bProcessing": true,
	"bServerSide": true,
	"sAjaxSource": dt_url_base
});

{/literal}
</script>
{include file="poste_foot.tpl"}
