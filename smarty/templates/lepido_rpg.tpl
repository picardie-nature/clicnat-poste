{include file="poste_head.tpl" titre_page="Beta Lepido / RPG" usemap=true usedatatable=true}
{literal}
<style>
	#formulaire { display: none; }
	.olControlAttribution {
		background-color: white;
		padding: 2px;
	}
</style>
{/literal}
<div id="carte" style="width:100%; height:400px;"> </div>
<table id="tab_dates" class="display" cellpadding="0" cellspacing="0">
	<thead>
	<tr>
		<th>Date</th>
		<th>Participants</th>
		<th>Lieu</th>
	</thead>
	<tbody>
	</tbody>
</table>
<script>
{literal}
var tab_dates;
var markers;
J(document).ready(function () {
	
	var stylemap_a = new OpenLayers.StyleMap({'default':{
			    strokeColor: "#aaff00",
			    strokeOpacity: 1,
			    strokeWidth: 1,
			    fillColor: "#aaff00",
			    fillOpacity: 0.5,
			    pointRadius: 6
	}});
	var stylemap_b = new OpenLayers.StyleMap({'default':{
			    strokeColor: "#00ff00",
			    strokeOpacity: 1,
			    strokeWidth: 3,
			    fillColor: "#00ff00",
			    fillOpacity: 0.5,
			    pointRadius: 6
	}});

	var m = carte_inserer(document.getElementById('carte'));

	var l_route = new OpenLayers.Layer.WMS("Routes", "http://maps.picardie-nature.org/wms.php?k=picnat", {
		layers:"routes_OSM_gmap",
		transparent:true
	});

	var l_rpg = new OpenLayers.Layer.WMS("RPG 2010 - Lépido", "http://maps.picardie-nature.org/wms.php?k=picnat", {
		layers:"rpg_2010_gmap",
		transparent:true
	});
	m.addLayers([l_rpg,l_route]);

	markers = new OpenLayers.Layer.Markers("Marqueurs");
	
	m.addLayers([markers]);

	var pt = new OpenLayers.LonLat(2.80151, 49.69606);
	pt.transform(m.displayProjection, m.projection);
	m.events.register('click', m, function (e) {
		 var lonlat = m.getLonLatFromViewPortPx(e.xy);
		 var p_lonlat = lonlat.clone();
		 p_lonlat.transform(m.getProjectionObject(), m.displayProjection);
		 var w = new OpenLayers.Popup("aaa", lonlat, new OpenLayers.Size(320,200), "interrogation en cours...", true);
		 m.addPopup(w);
		 var args = J.param({t: 'lepido_rpg_geocode', x: p_lonlat.lon, y: p_lonlat.lat});
		 J(w.contentDiv).load('?'+args);
	});
	m.setCenter(pt, 8);

	tab_dates = J('#tab_dates').dataTable({
		oLanguage: datatable_fr(),
		bProcessing: true,
		bSort: false,
		bFilter: false,
		bServerSide: true,
		sAjaxSource: "?t=lepido_rpg_dates",
		fnDrawCallback: function( oSettings ) {
			markers.clearMarkers();
			J('.icone_carte').each(function (n,img) {
				var i = J(img);
				var size = new OpenLayers.Size(img.width,img.height);
				var offset = new OpenLayers.Pixel(-(img.width/2), -(img.height));
				var icon = new OpenLayers.Icon(i.attr('src'), size, offset);
				var lonlat = new OpenLayers.LonLat(i.attr('x'), i.attr('y'));
				lonlat.transform(markers.map.displayProjection, markers.map.projection);
				var marker = new OpenLayers.Marker(lonlat, icon);
				markers.addMarker(marker);
			});
		}
	});
});

function lepido_nouvelle_date(espace,id_espace,tag) {
	var b = new BoiteChoixDateNew(espace,id_espace,tag);
	b.init_cback(function () { tab_dates.fnDraw(false); });
}

function lepido_rpg_edit_date(id) {
	var b = new BoiteChoixDateEdit(id);
	b.init_cback(function () { tab_dates.fnDraw(false); });
}

function lepido_rpg_annul_date(id) {
	if (confirm('Supprimer la date ?')) {
		J.ajax({url: '?'+J.param({t:'json',a:'calendrier_annuler_date',id_date:id}), async: false});
		tab_dates.fnDraw(false);
	}
}
{/literal}
</script>
{include file="partiels/choix_date_calendrier.tpl"}
{include file="poste_foot.tpl"}
