// indexOf existe pas sur IE
if (!Array.indexOf) {
	Array.prototype.indexOf = function(obj) {
		for (var i=0; i<this.length; i++) {
			if (this[i]==obj) {
				return i;
			}
		}
		return -1;
	}
}

// code valable uniquement pour l'interface de saisie
OpenLayers.Control.UpdateFormulaire = OpenLayers.Class(OpenLayers.Control, {                
	defaultHandlerOptions: {
		single: true,
		double: false,
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
	    if(m.getZoom() >= 14) {
		var pt = e.object.getLonLatFromViewPortPx(e.xy);
		pt.transform(e.object.projection, e.object.displayProjection);
		document.fcreation.x.value = pt.lon;
		document.fcreation.y.value = pt.lat;
		J('#latitude').val(pt.lat);
		J('#longitude').val(pt.lon);
		document.fcreation.id_espace.value = null;
		document.fcreation.table_espace.value = null;
		saisie_set_marqueur_pos(m, lm);
		J('#ptsel').load('?'+J.param({
			t:'json',
			a:'point_info',
			wkt:'POINT('+pt.lon+' '+pt.lat+')'
		}));
	    } else {
		alert('Pas assez précis, zoomez plus');
	    }
	}
});

function carte_ajout_click(map) {
	var k = new OpenLayers.Control.UpdateFormulaire();
	map.addControl(k);
	k.activate();
}

function saisie_set_marqueur_pos(carte,layer) {
	var p = new OpenLayers.LonLat(document.fcreation.x.value, document.fcreation.y.value);
	for (var i=0; i<layer.markers.length; i++)
		layer.removeMarker(layer.markers[i]);
	p.transform(carte.displayProjection, carte.projection);
	layer_marqueur_ajouter_icone(layer, p, 'icones/panoramic.png', 32, 37);
	return p;
}

// debut du valable partout
function carte_ajout_layer_marqueurs(map,titre) {
	var markers = new OpenLayers.Layer.Markers(titre);
	map.addLayer(markers);
	return markers;
}

function carte_ajout_layer_vecteurs(map, titre) {
	var vecteur = new OpenLayers.Layer.Vector(titre);
	map.addLayer(vecteur);
	return vecteur;
}

function carte_ajout_layer_wfs(map, id_liste, titre, mention, style) {
	var lv  = new OpenLayers.Layer.Vector(titre, {
		styleMap: style,
		strategies: [new OpenLayers.Strategy.BBOX()],
		projection: m.displayProjection,
		protocol: new OpenLayers.Protocol.WFS({
			url: "?t=liste_espace_carte_wfs",
			featureType: "liste_espace_"+id_liste,
			featureNS: "http://www.clicnat.org/espace"
		}),
		attribution: mention
	});
	map.addLayer(lv);
	return lv;
}

function layer_marqueur_ajouter_icone(layer, point, image, width, height) {
	var size = new OpenLayers.Size(width, height);
	var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
	var icon = new OpenLayers.Icon(image, size, offset);
	var marqueur = new OpenLayers.Marker(point, icon);
	layer.addMarker(marqueur);
}

function mapproxy_layer(titre, layername, attribution) {
	return new OpenLayers.Layer.TMS(titre, 'http://gpic.web-fr.org/mapproxy/tms/', {
		layername: layername,
		type: 'png',
		tileSize: new OpenLayers.Size(256, 256),
		sphericalMercator:true,
		attribution: attribution 
	});
}


function carte_inserer(imap) {
	var options = {
		projection: new OpenLayers.Projection('EPSG:900913'),
		displayProjection: new OpenLayers.Projection('EPSG:4326'),
		units: "m",
		maxResolution: 78271.516964,
		numZoomLevels: 19,
		maxExtent: new OpenLayers.Bounds(-20037508.3428, -20037508.3428, 20037508.3428,20037508.3428)
	};
	var id = imap.id;
	imap = new OpenLayers.Map(imap.id, options);
	imap.addControl(new OpenLayers.Control.LayerSwitcher());
	var layers = [];
	var ghyb, gphy;
	if (J('#'+id).attr('gmaps') != 'off') {
		var ghyb = new OpenLayers.Layer.Google("Google Hybride", {type: google.maps.MapTypeId.HYBRID});
		var gphy = new OpenLayers.Layer.Google("Google Physique", {type: google.maps.MapTypeId.TERRAIN});
		layers.push(ghyb);
		layers.push(gphy);
	}


	layers.push(mapproxy_layer("Picardie composite (GéoPicardie IGN)", "picardie_composite_EPSG900913",'<a href="http://www.picardie.fr/GeoPicardie">Géopicardie</a> <a href="http://www.ign.fr/">IGN</a>'));
	layers.push(mapproxy_layer("Routes (Openstreemap)", "basemaps_google_EPSG900913",'<a href="http://www.openstreetmap.org">OpenStreetMap</a>'));
	layers.push(mapproxy_layer("Scan 25", "scan25_EPSG900913",'&copy; IGN via <a href="http://www.picardie.fr/GeoPicardie">Géopicardie</a>'));
	layers.push(mapproxy_layer("OpenStreetMap", "osm_geopicardie_EPSG900913", "&copy; <a href='http://www.openstreetmap.org'>Openstreetmap</a> et ses contributeurs"));


	imap.addLayers(layers);
	if (ghyb != undefined)
		ghyb.mapObject.setTilt(0);
	if (gphy != undefined)
		gphy.mapObject.setTilt(0);

	return imap;
}

function marqueur_existe_et_unique(layer) {
	return layer.markers.length == 1;
}

function marqueur_est_visible(layer) {	
	if (marqueur_existe_et_unique(layer)) {
		var marqueur = layer.markers[0];
		return layer.map.getExtent().containsLonLat(marqueur.lonlat, true);
	}
	return false;
}



