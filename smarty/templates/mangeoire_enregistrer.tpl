{include file="mangeoire_head.tpl" titre_page="Nouvelle mangeoire"}
<br/>
<div class="desc">
	<h1>Enregistrer une nouvelle mangeoire</h1>
	<div id="">
		Pour enregistrer la localisation de votre mangeoire cliquer
		sur la carte après avoir zoomé sur l'endroit où elle se trouve.
	</div>
</div>
<div id="zone_validation" class="desc pas_visible">
	<h1>Enregistrement de la mangeoire</h1>
	<div>
		<form id="f" action="index.php">
			Précisez un nom pour votre mangeoire :<br/>
			<input type="hidden" name="t" value="mangeoire_enregistre_point"/>
			<input type="hidden" name="x" id="n_x" value=""/>
			<input type="hidden" name="y" id="n_y" value=""/>
			<input type="text" name="nom" id="nom"/>
			<input type="submit" value="Enregistrer votre mangeoire"/>
		</form>
	</div>
</div>
<div id="map" style="border-style: none; height: 500px; width:100%;"></div>
<script language="javascript">
{literal}
function mangeoire_set_marqueur_pos(carte,layer,p) {
    for (var i=0; i<layer.markers.length; i++)
        layer.removeMarker(layer.markers[i]);
    layer_marqueur_ajouter_icone(layer, p, 'icones/panoramic.png', 32, 37);
    return p;
}	

OpenLayers.Control.PointeMangeoire = OpenLayers.Class(OpenLayers.Control, {                
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
{/literal}
var m = carte_inserer(document.getElementById('map'));
var c = new OpenLayers.Control.PointeMangeoire();
var lm = carte_ajout_layer_marqueurs(m, 'Marqueurs');
m.addLayers([lm]);
m.addControl(c);
c.activate();
var pt = new OpenLayers.LonLat(2.80151, 49.69606);
pt.transform(m.displayProjection, m.projection);
m.setCenter(pt, 8);
</script>
{include file="mangeoire_foot.tpl"}
