{include file="poste_head.tpl" usemap="true" titre_page="Ma localisation"}
<h1>Ma localisation</h1>
<p>Zoomez sur votre lieu d'habitation (maison) et cliquez sur la carte. Cliquez ensuite sur le bouton enregistrer qui vient d'apparaître.</p>
<div id="zone_validation" style="display:none;">
	<form method="post" action="?t=malocalisation">
		<input type="hidden" name="lat" id="n_y"/>
		<input type="hidden" name="lon" id="n_x"/>
		<input type="submit" value="Enregistrer ma localisation"/>
	</form>
</div>
<div id="map" style="border-style: none; height: 500px; width:100%;"></div>
</form>
<script language="javascript">
{literal}
function mangeoire_set_marqueur_pos(carte,layer,p) {
    for (var i=0; i<layer.markers.length; i++)
        layer.removeMarker(layer.markers[i]);
    layer_marqueur_ajouter_icone(layer, p, 'icones/panoramic.png', 32, 37);
    return p;
}	

OpenLayers.Control.PointageLoc = OpenLayers.Class(OpenLayers.Control, {                
	defaultHandlerOptions: {
		single: true,
		double: true,
		pixelTolerance:false,
		stopSingle: false,
		stopDouble: false
	},

	initialize: function(options) {
		this.handlerOptions = OpenLayers.Util.extend({}, this.defaultHandlerOptions);
		OpenLayers.Control.prototype.initialize.apply(this, arguments); 
		this.handler = new OpenLayers.Handler.Click(this, {click: this.trigger}, this.handlerOptions);
	}, 

	trigger: function(e) {
	    if (m.getZoom() >= 14) {
		var pt = e.object.getLonLatFromViewPortPx(e.xy);
		mangeoire_set_marqueur_pos(m, lm, pt);
		p = pt.clone();
		p.transform(e.object.projection, e.object.displayProjection);
		J('#zone_validation').show();
		J('#n_x').val(p.lon);
		J('#n_y').val(p.lat);
	    } else {
		alert('Pas assez précis, zoomez plus');
	    }
	}
});
var m = carte_inserer(document.getElementById('map'));
var c = new OpenLayers.Control.PointageLoc();
var lm = carte_ajout_layer_marqueurs(m, 'Marqueurs');
m.addLayers([lm]);
m.addControl(c);
c.activate();
{/literal}
var pt = new OpenLayers.LonLat({$xorg}, {$yorg});
pt.transform(m.displayProjection, m.projection);
m.setCenter(pt, {$zorg});
</script>

{include file="poste_foot.tpl"}
