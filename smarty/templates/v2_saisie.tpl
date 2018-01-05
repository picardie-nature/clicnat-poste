{include file="poste_head.tpl" titre_page="Saisie (Géoportail)"}
<style>
	/* {literal} */
	#bobs-v2-saisie-map {
		margin-left:20%;
		width: 80%;
		height:600px;
	}
	
	#bobs-v2-saisie-cadre-gauche {
		width: 19%;
		float: left;
	}
	
	#bobs-v2-saisie-cadre-gauche h1 {
		font-size: 14px;
	}
	
	.ui-widget {
		font-size: 1em;
	}

	.ui-dialog-content {
		font-size: 0.8em;
	}

	.pas_visible {
		display: none;
	}

	.tb {
		margin-bottom: 4px;
	}

	.btn-ctrl {
		border-style:solid;
		border-width: 1px;
		border-color: #afafaf;
		background-color: #bbbbff;
		margin: 5px;
		padding: 3px;
		cursor: pointer;
	}

	.btn-ctrl-inactif {
		background-color: #ffbbbb;
	}
	.btn-ctrl-actif {
		background-color: #bbffbb;
	}

	/* {/literal} */
</style>
<script src="http://api.ign.fr/geoportail/api/js/2.0/GeoportalExtended.js" charset="utf-8"></script>
<script>
	// {literal}
	try {
		console.log('plop');
	} catch (e) {
		function FixConsole() {
			this.log = function (txt) {
				return;
			}
		}
		console = new FixConsole();
	}
	// {/literal}
</script>
<div>
	<div id="bobs-v2-saisie-cadre-gauche" class="ui-corner-all"> 
		<br/>
		<div id="tb-carte" class="ui-widget-content ui-corner-all pas_visible tb">
			<div class="ui-widget-header ui-corner-all">Carte</div>
			<button id="b-z-moins" title="Zoom moins"></button>
			<button id="b-z-init" title="Région"></button>
			<button id="b-z-plus" title="Zoom plus"></button>
			<button id="b-z-bascule" title="Bascule le fond de carte"></button>
		</div>
		<div id="tb-recherche" class="ui-widget-content ui-corner-all pas_visible tb">
			<div class="ui-widget-header ui-corner-all">Répertoire et villes</div>
			<button id="bt-r-repertoire" title="Répertoire"></button>
			<button id="bt-r-ville" title="Ville"></button>
			<button id="bt-r-coords" title="Saisir des coordonnées"></button>
		</div>
		<div id="tb-localisation" class="ui-widget-content ui-corner-all pas_visible tb">
			<div class="ui-widget-header ui-corner-all">Localisation</div>
			<div style="font-size:0.8em;">
				<div id="z-loc-info1"></div>
				<div id="z-loc-info2"></div>
			</div>
		</div>
		<div id="tb-controle" class="ui-widget-content ui-corner-all pas_visible tb">
			<div class="ui-widget-header ui-corner-all">Contrôles</div>
			<p id="ctrl-saisie-point" class="btn-ctrl">Mode saisie de points</p>
			<p id="ctrl-saisie-ligne" class="btn-ctrl">Mode saisie de lignes</p>
			<p id="ctrl-saisie-poly" class="btn-ctrl">Mode saisie de polygones</p>
		</div>
<!--
		<h1>Coordonnées</h1>
		<div id="bobs-v2-lon"></div>
		<div id="bobs-v2-lat"></div>
		<div id="bobs-v2-pt-commune"></div>
-->
<!--
		<a href="javascript:v2_saisie_creerObsDlg();">Créer une observation sur un point</a><br/>
		<a href="javascript:v2_saisie_ajouterPointRepertoireDlg();">Ajouter le point dans mon répertoire</a><br/>
		<a href="javascript:v2_saisie_ouvrirRepertoireDlg();">Ouvrir le répertoire</a><br/>
		<a href="javascript:v2_saisie_saisieCoordonneesDlg();">Saisir les coordonnées d'un point</a><br/>
-->		
		<h1>Communes</h1>
		<input type="text" id="v2_saisie_srch_commune"/>
	</div>		
	<div id="bobs-v2-saisie-map"></div>
</div>
<div style="display:none;">
	<div id="formulaire_creation">
		<form method="post" action="?t=saisie_creation_obs" name="fcreation" id="fcreation">
			<input type="hidden" name="date" value=""/>
			<input type="hidden" name="x" value=""/>
			<input type="hidden" name="y" value=""/>
			<input type="hidden" name="id_espace" value=""/>
			<input type="hidden" name="table_espace" value=""/>
			<input type="hidden" name="zoom"/>
		</form>	
	</div>
	<div id="zcommune"></div>
	<div id="dlg_envoi" title="Création d'une observation">
		Date de l'observation : <br/>
		<input type="text" id="dlg_envoi_date"/>
	</div>
	<div id="dlg_erreur" title="Attention"></div>
	<div id="dlg_choix_liste_espece" title="Passer à la liste des espèces">
		Passer à la saisie de la liste des espèces pour ce point ?<br/>
		Si vous répondez non, vous pouvez passer directement au pointage de l'observation suivante sans recharger cette page.
	</div>
	<div id="dlg_choix_nom_point" title="Enregistrer un point">
		Vous allez enregistrer une localisation dans votre répertoire, vous devez lui donner un nom. Attention, ce nom pourra
		être vu par d'autres utilisateurs et apparaître en divers endroits. Prenez soin de choisir quelque chose de compréhensible
		par tous.<br/><br/>
		Nom : <input type="text" id="rep_pt_nom" maxlength="45"/>
	</div>
	<div id="dlg_saisie_point" title="Saisie des coordonnées">
		<fieldset>
			<legend>Degrés - minutes - secondes</legend>
			Latitude : <br/>
			<input type="text" size="3" id="sp_lat_d"/>°
			<input type="text" size="3" id="sp_lat_m"/>'
			<input type="text" size="3" id="sp_lat_s"/>" N<br/>
			Longitude :<br/>
			<input type="text" size="3" id="sp_lon_d"/>°
			<input type="text" size="3" id="sp_lon_m"/>'
			<input type="text" size="3" id="sp_lon_s"/>" E<br/>
		</fieldset>
		<fieldset>
			<legend>Degrés décimaux</legend>
			Latitude : <br/>
			<input type="text" size="10" id="sp_lat_dd"/><br/>
			Longitude :<br/>
			<input type="text" size="10" id="sp_lon_dd"/><br/>
		</fieldset>
	</div>
	<div id="dlg_liste_repertoire" title="Répertoire de localisations">
	    Liste des localisations : 
		<a href="javascript:v2_saisie_repertoireOrdreAlpha();">par nom</a> -
		<a href="javascript:v2_saisie_repertoireOrdreHist();">par date</a>.
		<a href="javascript:v2_saisie_importGPX();">Import GPX</a>
		<div id="dlg_liste_repertoire_int"></div>
	</div>
	
</div>
<div id="z_wkt"></div>
<script type="text/javascript">
	//{literal}

	function Espace() {
		this.type = false;
		this.espace_table = false;
		this.id_espace = false;

		this.pt = false;
		this.geometry = false;

		this.fmtWkt = false;
		this.fmtGeoJson = false;
		
		this.wktLonLat = function (pt) {
			return 'POINT('+pt.lon+' '+pt.lat+')';
		}

		this.depuisDb = function (table_espace, id_espace) {
			log(table_espace);
			log('depuisDb table_espace='+table_espace+' id_espace='+id_espace);
			var q = {
				t: 'espace_get_geom',
				espace_table: table_espace,
				id_espace: id_espace
			};
			xhr = J.ajax({url:'?'+J.param(q), async: false});
			if (xhr.status == 200) {
				if (!this.fmtWkt)
					this.fmtWkt = new OpenLayers.Format.WKT();

				var feature = this.fmtWkt.read(xhr.responseText);
				switch (feature.geometry.CLASS_NAME) {
					case 'OpenLayers.Geometry.Point':
						this.type = 'point';
						this.pt = new OpenLayers.LonLat(feature.geometry.x, feature.geometry.y);
						break;
					case 'OpenLayers.Geometry.Polygon':
						this.type = 'polygone';
						this.geometry = feature.geometry;
						break;
					case 'OpenLayers.Geometry.LineString':
						this.type = 'ligne';
						this.geometry = feature.geometry;
						break;
					default:
						alert(feature.geometry.CLASS_NAME);
						break;
				}
				this.espace_table = table_espace;
				this.id_espace = id_espace;
			}
			log('chargement table '+this.espace_table+' espace '+this.id_espace);
		}

		this.pointDepuisLonLat = function (objLonLat) {
			this.type = 'point';
			this.espace_table = false;
			this.id_espace = false;
			this.pt = objLonLat.clone();
			this.pt.transform(iface.prj_ign, iface.prj_dest);
		}

		this.polygoneDepuisFeature = function (objFeature) {
			if (objFeature.geometry.CLASS_NAME == 'OpenLayers.Geometry.Polygon')
				this.type = 'polygone';
			else
				this.type = 'ligne';

			this.espace_table = false;
			this.id_espace = false;
			this.geometry = objFeature.geometry.clone();
			this.geometry.transform(iface.prj_ign, iface.prj_dest);
		}

		this.showInfo = function () {
			var za = J("#z-loc-info1");
			var zb = J("#z-loc-info2").empty();

			za.empty();
			zb.empty();

			if (this.type == 'point') {
				za.append('Type de localisation : <b>point</b><br/><br/>');
				za.append('Coordonnées : '+this.pt.toShortString()+'<br/>');
				za.append('<input type="button" onClick="javascript:iface.espace.dlgSauveRep();" value="Enr. répertoire"/>');
				za.append('<input type="button" onClick="javascript:iface.dlgDateObs();" value="Créer une obs"/>');
				var wkt = this.wktLonLat(this.pt);
				zb.html('<img src="icones/load.gif"/> recherche en cours... ');
				zb.load('?'+J.param({t:'json', a:'point_info', wkt:wkt}));
			} else if (this.type == 'polygone') {
				var c = this.geometry.clone();
				c.transform(iface.prj_dest, iface.prj_ign);
				/*var superficie = c.getArea();
				var unite = 'm<sup>2</sup> ou ca';
				var trop_grand = superficie > 150*1000

				if (superficie > 2000) {
					superficie/=100;
					unite='dam<sup>2</sup> ou a';
				}

				if (superficie > 10000) {
					superficie/=10000;
					unite='hm<sup>2</sup> ou ha';
				}

				superficie = parseInt(superficie*10)/10;*/
				za.append('Type de localisation : <b>surface</b><br/>');
				//za.append('Superficie : '+superficie+' '+unite+'<br/>');
				/*if (trop_grand) {
					za.append('<i>Trop grand pour être enregistré</i>');
				} else {*/
				za.append('<input type="button" onClick="javascript:iface.espace.dlgSauveRep();" value="Enr. répertoire"/>');
				za.append('<input type="button" onClick="javascript:iface.dlgDateObs();" value="Créer une obs"/>');
				/*}*/
			} else if (this.type == 'ligne') {
				za.append('Type de localisation : <b>Ligne</b><br/>');
				za.append('<input type="button" onClick="javascript:iface.espace.dlgSauveRep();" value="Enr. répertoire"/>');
				za.append('<input type="button" onClick="javascript:iface.dlgDateObs();" value="Créer une obs"/>');
			} else {
				log('showInfo : pas implémenté pour '+this.type);
			}
			J('#tb-localisation').show('slow');
		}

		this.showOnMap = function (iface,centre) {
			if (this.type == 'point') {
				var p = this.pt.clone();
				p.transform(iface.prj_dest, iface.prj_ign);
				iface.mapPlaceMarqueur(p,centre);
			} else if (this.type == 'polygone' || this.type == 'ligne') {
				var g = this.geometry.clone();
				g.transform(iface.prj_dest, iface.prj_ign);
				var feature = new OpenLayers.Feature.Vector(g);
				var lp = iface.layerPoly();
				lp.removeFeatures(lp.features);
				lp.addFeatures([feature]);
				var pt = feature.geometry.getBounds().getCenterLonLat();
				map = viewer.getMap();
				var zoom = map.getZoom();
				if (zoom < 13) zoom = 13;
				map.setCenter(pt, zoom);
			} else {
				log('showOnMap : pas implémenté pour '+this.type);
			}
		}

		this.saisieObs = function (date_obs) {
			log('saisieObs '+date_obs);
			var url = false;
			if (!this.espace_table) {
				// La localisation n'est pas enregistrée
				if (this.type == 'point') {
					url = '?'+J.param({x: this.pt.lon, y: this.pt.lat, scale: iface.mapScale(), 'date':date_obs, zoom:iface.mapZoom(), t:'json', a:'creation_observation'});
				} else if (this.type == 'polygone') {
					if (!this.fmtGeoJson)
						this.fmtGeoJson = new OpenLayers.Format.GeoJSON();
					var geojson = this.GeoJson.write(this.geometry, false);
					url = '?'+J.param({geojson: geojson, scale: iface.mapScale(), 'date': date_obs, zoom:iface.mapZoom(), t:'json', a:'creation_observation'});
				}
			} else {
				// Déja enregistré
				url = '?'+J.param({'date':date_obs, 'table_espace':this.espace_table, 'id_espace': this.id_espace, t:'json', a:'creation_observation'});
			}

			if (url == false) {
				alert('url de création non péparée');
				return;
			}

			J.ajax({
				url: url,
				success: function (resultat) {
					if (resultat.match(/^\d+/)) {
						document.location.href = '?t=saisie_base&id='+resultat;
					} else if (resultat.match(/^DATE_VIDE/i)) {
						v2_saisie_erreur("Il faut indiquer une date");
						return;
					} else if (resultat.match(/^NOPOINT/i)) {
						v2_saisie_erreur("Cliquez sur la carte pour indiquer le lieu de l'observation");
						return;
					} else {
						v2_saisie_erreur(resultat);
					}
				}
			});
		}

		this.sauveRep = function (nom) {
			if ((this.type == 'polygone') || (this.type == 'ligne')) {	
				if (!this.fmtGeoJson)
					this.fmtGeoJson = new OpenLayers.Format.GeoJSON();
				var geojson = this.fmtGeoJson.write(this.geometry, false);
				J.ajax({
					url: '?'+J.param({t:'repertoire_ajoute_'+this.type, nom: nom, geojson: geojson}),
					async: false
				});
			} else if (this.type == 'point') {
				J.ajax({
					url: '?'+J.param({t:'repertoire_ajoute_point', x: this.pt.lon, y: this.pt.lat, nom: nom}),
					async: false
				});
			}
		}

		this.dlgSauveRep = function () {
			J('#rep_pt_nom').val('');
			J('#dlg_choix_nom_point').dialog({
				modal:true,
				buttons: {
					Créer: function () { 
						iface.espace.sauveRep(J('#rep_pt_nom').val());
						J('#dlg_choix_nom_point').dialog('close'); 
					},
					Annuler: function () {
						J('#dlg_choix_nom_point').dialog('close'); 
					}
				}
			});
		}


	}

	function IfaceSaisie() {
		this.prj_ign = new OpenLayers.Projection('EPSG:3857');
		this.prj_dest = new OpenLayers.Projection('EPSG:4326');
		this.espace = false;

		this.ctrl_point = false;
		this.ctrl_poly = false;

		this.l_marker = false;
		this.l_vector = false;
		this.l_draw = false;
		
		this.ortho_visible = false;
		
		this.suspendre_trigger_ajout = false;

		this.map_coord_init = {
			zoom: 7,
			a_lon: 1.1526,
			a_lat: 50.4655,
			b_lon: 4.4595,
			b_lat: 48.80079,
			bounds: false
		};

		this.z_point = 13;

		this.mapScale = function () {
			var map = viewer.getMap();
			return map.getScale();
		}

		this.mapZoom = function () {
			var map = viewer.getMap();
			return map.getZoom();
		}


		this.mapZoomInitial = function () {
			//var map = viewer.getMap();
			var map = viewer.map;
			if (!this.map_coord_init.bounds) {
				this.map_coord_init.bounds = new OpenLayers.Bounds();
				this.map_coord_init.bounds.extend(new OpenLayers.LonLat(this.map_coord_init.a_lon, this.map_coord_init.a_lat));
				this.map_coord_init.bounds.extend(new OpenLayers.LonLat(this.map_coord_init.b_lon, this.map_coord_init.b_lat));
				this.map_coord_init.bounds.transform(this.prj_dest, this.prj_ign);
				log(this.map_coord_init.bounds);
			}
			map.zoomTo(this.map_coord_init.zoom);
			map.zoomToExtent(this.map_coord_init.bounds);
		}

		this.mapPlaceMarqueur = function (pt, centre) {
			log('mapPlaceMarqueur '+pt);
			var map = viewer.getMap();

			for (var i=map.layers.length-1; i>=0; i--) {
				if (map.layers[i].CLASS_NAME == 'OpenLayers.Layer.Markers') {
					var mark_image = 'icones/panoramic.png';
					for (var j=map.layers[i].markers.length-1; j>=0; j--) {
						if (map.layers[i].markers[j].icon.url = mark_image) {
							map.layers[i].removeMarker(map.layers[i].markers[j]);
						}
					}			
					var mark_size = new OpenLayers.Size(32,37);
					var mark_offset = new OpenLayers.Pixel(-(mark_size.w/2), -mark_size.h);
					var mark_icon = new OpenLayers.Icon(mark_image, mark_size, mark_offset);
					var mark = new OpenLayers.Marker(pt, mark_icon);
					map.layers[i].addMarker(mark);
					break;
				}
			}
			if (centre)
				map.setCenter(pt, this.z_point);
		}

		this.mapZoomPlus = function () {
			var map = viewer.getMap();
			map.zoomTo(map.zoom+1);
		}

		this.mapZoomMoins = function () {
			var map = viewer.getMap();
			map.zoomTo(map.zoom-1);
		}

		this.mapChangeFond = function () {
			var map = viewer.getMap();
			this.ortho_visible = !this.ortho_visible;
			for (var i=0; i<map.layers.length; i++) {
				if (map.layers[i].name == 'ORTHOIMAGERY.ORTHOPHOTOS') {
					map.layers[i].setVisibility(this.ortho_visible);
				} else if (map.layers[i].name == 'GEOGRAPHICALGRIDSYSTEMS.MAPS') {
					map.layers[i].setVisibility(!this.ortho_visible);
				}
			}
		}

		this.mapInit = function () {
			var map = viewer.getMap();
			OpenLayers.Control.SaisiePoint = OpenLayers.Class(OpenLayers.Control, {                
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
					m = viewer.getMap();
					var pt = e.object.getLonLatFromViewPortPx(e.xy);				
					if (m.getZoom() >= 13) {
						var pt = e.object.getLonLatFromViewPortPx(e.xy);
						var esp = new Espace();
						esp.pointDepuisLonLat(pt);
						iface.nouvelleLocalisation(esp, false);
					} else {
						// niveau de zoom insuffisant alors on zoom
						m.setCenter(pt, m.getZoom()+1);
					}
				}
			});

			this.ctrl_point = new OpenLayers.Control.SaisiePoint(); 

			this.__mapAddCtrl(map, this.ctrl_point, 'ctrl-saisie-point');
			this.ctrl_point.activate();
			var stylemap = new OpenLayers.StyleMap({'default':{
				strokeColor: "#00ff00",
				strokeOpacity: 1,
				strokeWidth: 3,
				fillColor: "#00ff00",
				fillOpacity: 0.5,
				pointRadius: 6
			}});	
			this.l_marker = new OpenLayers.Layer.Markers('m');
			this.l_vector = new OpenLayers.Layer.Vector('zcommune');
			this.l_draw = new OpenLayers.Layer.Vector('draw_poly', {styleMap: stylemap});

			map.addLayer(this.l_marker);
			map.addLayer(this.l_vector);
			map.addLayer(this.l_draw);

			this.l_draw.events.register('featureadded', null, function (obj) {
				if (!iface.suspendre_trigger_ajout) {
					var e = new Espace();
					e.polygoneDepuisFeature(obj.feature);
					iface.suspendre_trigger_ajout = true;
					iface.nouvelleLocalisation(e);
					iface.suspendre_trigger_ajout = false;
				}
					
			});
			this.ctrl_poly = new OpenLayers.Control.DrawFeature(this.l_draw, OpenLayers.Handler.Polygon); 
			this.ctrl_poly.events.register('featureadded', null, function (obj) {
				if (!iface.suspendre_trigger_ajout) {
					var f = obj.feature.clone()
					iface.l_draw.removeAllFeatures();
					iface.l_draw.addFeatures([f]);
				}
			});
			this.ctrl_ligne = new OpenLayers.Control.DrawFeature(this.l_draw, OpenLayers.Handler.Path); 
			this.ctrl_ligne.events.register('featureadded', null, function (obj) {
				if (!iface.suspendre_trigger_ajout) {
					var f = obj.feature.clone()
					iface.l_draw.removeAllFeatures();
					iface.l_draw.addFeatures([f]);
				}
			});

			this.__mapAddCtrl(map, this.ctrl_poly, 'ctrl-saisie-poly');
			this.__mapAddCtrl(map, this.ctrl_ligne, 'ctrl-saisie-ligne');

			this.__mapSelCtrl('ctrl-saisie-point');

			J('#ctrl-saisie-point').click(function() {
				iface.__mapSelCtrl('ctrl-saisie-point');
			});

			J('#ctrl-saisie-poly').click(function() {
				iface.__mapSelCtrl('ctrl-saisie-poly');
			});
			
			J('#ctrl-saisie-ligne').click(function() {
				iface.__mapSelCtrl('ctrl-saisie-ligne');
			});
		}

		this.__mapSelCtrl = function (ele) {
			if (this.ctrl_point != false)
				this.ctrl_point.deactivate();
			if (this.ctrl_poly != false)
				this.ctrl_poly.deactivate();
			if (this.ctrl_ligne != false)
				this.ctrl_ligne.deactivate();
			J('.btn-ctrl').removeClass('btn-ctrl-actif');
			J('.btn-ctrl').addClass('btn-ctrl-inactif');
			passe_au_vert = false;
			switch (ele) {
				case 'ctrl-saisie-point':
					this.ctrl_point.activate();
					passe_au_vert = true;
					break;
				case 'ctrl-saisie-poly':
					this.ctrl_poly.activate();
					passe_au_vert = true;
					for (var i=this.l_marker.markers.length; i>0; i--) 
						this.l_marker.removeMarker(this.l_marker.markers[i-1]);
					break;
				case 'ctrl-saisie-ligne':
					this.ctrl_ligne.activate();
					passe_au_vert = true;
					for (var i=this.l_marker.markers.length; i>0; i--) 
						this.l_marker.removeMarker(this.l_marker.markers[i-1]);
					break;
			}
			if (passe_au_vert)
				J('#'+ele).addClass('btn-ctrl-actif');
		}

		this.__mapAddCtrl = function (map, ctrl, ele) {
			// ctrl : objet OpenLayers.Control a ajouter
			// ele : id de la div a afficher
			// etat : bool vrai pour activer
			log(ele+' addctrl');
			var map = viewer.getMap();
			map.addControl(ctrl);
			J('#'+ele).addClass('btn-ctrl-inactif');
			log(ele+' classe');
		}

		this.__dialogueOuvre = function (ele_sel, ele_sel_int, width, height, url) {
			var e_int = J(ele_sel_int);
			e_int.html('<img src="icones/load.gif"/> chargement en cours');
			J(ele_sel).dialog({width:width, height:height});
			e_int.load(url);
		}

		this.repertoireOuverture = function () {
			this.__dialogueOuvre('#dlg_liste_repertoire', '#dlg_liste_repertoire_int', 600, 480, '?t=repertoire_liste');
		}

		this.repertoireUtilise = function (espace, id_espace) {
			log('repertoireUtilise espace='+espace+' id_espace='+id_espace);
			// on pourrait être tenter de faire ça
			//   this.espace.e = new Espace();
			// mais non ça ne fonctionne pas
			var e = new Espace();
			e.depuisDb(espace, id_espace);
			e.showInfo();
			this.suspendre_trigger_ajout = true;
			e.showOnMap(this, true);
			this.espace = e;
			this.suspendre_trigger_ajout = false;
		}

		this.repertoireSupprime = function(espace,id_espace) {
			var p = J.param({
				t: 'repertoire_supprime',
				espace_table: espace,
				id_espace: id_espace
			});
			J.ajax({url:'?'+p, async: false});
			this.repertoireOuverture();
		}

		this.nouvelleLocalisation = function (espace, zoomto) {
			this.espace = espace;
			this.espace.showInfo();
			this.espace.showOnMap(this,zoomto==true);
		}

		this.dlgDateObs = function () {
			if (iface.espace.type != 'point') {
				if (!iface.espace.id_espace) {
					alert("Vous devez passer par le répertoire pour les lignes et les polygones");
					iface.espace.dlgSauveRep();
					return;
				}
			}
			J('#dlg_envoi').dialog({
				modal: true,
				buttons: {
					'Créer': function () { 	
						var d = J('#dlg_envoi_date').val();
						iface.espace.saisieObs(d);
					}, 
					'Annuler': function () {
						J('#dlg_envoi').dialog('close'); 
					} 
				}
			});
		}

		this.layerPoly = function () {
			var map = viewer.getMap();
			for (var i=0; i<map.layers.length; i++) {
				if (map.layers[i].name == 'draw_poly') {
					return map.layers[i];
				}
			}
			return false;
		}

		// Toolbar de la carte
		J('#b-z-moins').button({ text:false, icons: { primary: "ui-icon-zoomout" }});
		J('#b-z-init').button({ text:false, icons: { primary: "ui-icon-arrow-4-diag" }});
		J('#b-z-plus').button({ text:false, icons: { primary: "ui-icon-zoomin" }});
		J('#b-z-bascule').button({ text:false, icons: { primary: "ui-icon-transferthick-e-w" }});
		J('#b-z-init').click(function () { iface.mapZoomInitial(); } );
		J('#b-z-moins').click(function () { iface.mapZoomMoins(); } );
		J('#b-z-plus').click(function () { iface.mapZoomPlus(); } );
		J('#b-z-bascule').click(function() { iface.mapChangeFond(); } );

		J('#bt-r-coords').button({ text:false, icons: { primary: "ui-icon-flag" }});
		J('#bt-r-coords').click(function() {  v2_saisie_saisieCoordonneesDlg(); } );
		J('#tb-carte').show();

		// Toolbar recherche et répertoire
		J('#bt-r-repertoire').button({ text:false, icons: { primary: "ui-icon-note" }});
		J('#bt-r-ville').button({ text:false, icons: { primary: "ui-icon-home" }});
		J('#bt-r-repertoire').click(function () { iface.repertoireOuverture(); });
		J('#tb-recherche').show();

		// Mode de saisie
		J('#tb-controle').show();
	}

	var VISU;
	var map_controles = {};
	var iface = '';
	var iv = null;
	var viewer;

	function init_saisie(apik,point) {		
		if (typeof(OpenLayers)=='undefined'              ||
  			typeof(Geoportal)=='undefined'               ||
			typeof(Geoportal.Viewer)=='undefined'        ||
			typeof(Geoportal.Viewer.Default)=='undefined') {
			setTimeout('init_saisie("'+apik+'");', 100);
			return;
	        }

		J('#dlg_envoi_date').datepicker({maxDate: 0});
			
		J('#v2_saisie_srch_commune').autocomplete({source: '?t=autocomplete_commune',
			select: function (event,ui) {
				v2_saisie_commune(ui.item.value);
				event.target.value = '';
				return false;	    
			}
		});
	
		iface = new IfaceSaisie();
		
		// init_lon et init_lat ne sont pas utilisées
		var init_lon = iface.map_coord_init.a_lon;
		var init_lat = iface.map_coord_init.a_lat;
		var zoom = false;
		if (point) {
			init_lon = point.x;
			init_lat = point.y;
			zoom = point_z;
		} else {
			point = new OpenLayers.LonLat(iface.map_coord_init.a_lon,iface.map_coord_init.a_lat);
		}
		iv = Geoportal.load("bobs-v2-saisie-map", [apik], {center:point,zoom:zoom},null,{
			onView: function () {
				viewer = iv.getViewer();
				var l_ortho;
				var l_scan;
				for (var i=0; i<viewer.map.layers.length; i++) {
					layer = viewer.map.layers[i];
					if (layer.name == 'ORTHOIMAGERY.ORTHOPHOTOS') {
						layer.setOpacity(1.0);
						l_ortho=i;
					} else if (layer.name == 'GEOGRAPHICALGRIDSYSTEMS.MAPS') {
						layer.setOpacity(1.0);
						l_scan=i;
					}
				}
				viewer.map.layers[l_scan].setVisibility(true);
				viewer.map.layers[l_ortho].setVisibility(false);
				if (!zoom) {
					iface.mapZoomInitial();
				} 
				iface.mapInit();
			}
		});
		return; 
	}

	function v2_saisie_commune(id_espace) {
		new J.ajax({
			url: '?'+J.param({
				t: 'commune_gml',
				id: id_espace,
				dataType: 'xml'
			}),
			success: function (data, s, xhr) {
				map = viewer.getMap();
				for (var i=map.layers.length-1; i>=0; i--) {
					if (map.layers[i].CLASS_NAME == 'OpenLayers.Layer.Vector') {
						if (map.layers[i].name != 'zcommune') {
							continue;
						}
						var layer = map.layers[i];
						layer.removeFeatures(layer.features);
						var format = new OpenLayers.Format.GML({
							'internalProjection': new OpenLayers.Projection('EPSG:3857'),
							'externalProjection': new OpenLayers.Projection('EPSG:4326')
						});
						var feature = format.parseFeature(data);
						feature.style = {
							fillOpacity: 0,
							strokeWidth: 4,
							strokeOpacity: 1,
							strokeDashstyle: 'longdash',
							strokeColor: '#ff0000'
						};
						layer.addFeatures(feature);
						console.log(feature);
						layer.map.zoomToExtent(layer.getDataExtent());
					}
				}
			}
		});
	}
	
	function v2_saisie_creerObs() {
		console.log("déprécié");
		document.fcreation.date.value = J('#dlg_envoi_date').val();
		
		J.ajax({
			url: '?t=json&a=creation_observation&'+J('#fcreation').serialize(),
			success: function (resultat) {
				if (resultat.match(/^\d+/)) {
					document.location.href='?t=saisie_base&id='+resultat;
				} else if (resultat.match(/^DATE_VIDE/i)) {					
					v2_saisie_erreur("Il faut indiquer une date");
					return;
				} else if (resultat.match(/^NOPOINT/i)) {
					v2_saisie_erreur("Cliquez sur la carte pour indiquer le lieu de l'observation");
					return;
				} else {
					v2_saisie_erreur(resultat);
				}
			}
		});		
	}
	
	function v2_saisie_erreur(message) {
		console.log("déprécié");
		J('#dlg_erreur').html(message);
		J('#dlg_erreur').dialog({modal:true,buttons: {Fermer: function () {	J('#dlg_erreur').dialog('close');}}});
	}
		
	function v2_saisie_creerObsDlg() {
		console.log("déprécié");
		map = viewer.getMap();
		document.fcreation.date.value = '';
		if (document.fcreation.x.value == '') {
			log('pas de x');
			if (document.fcreation.id_espace.value == '') {
				log('pas de id_espace');
				v2_saisie_erreur("Vous devez créer un point sur la carte. Pour ce faire vous devez cliquer sur la carte. Tant que vous n'avez pas atteind le bon niveau de zoom ce niveau change jusqu'à ce que une marque apparaisse pour indiquer la position de votre pointage. Vous pouvez également utiliser une localisation déjà enregistrée dans votre répertoire.");
				return;
			}
			log('id_espace ok');
		} else {
			log('x ok');
		}
		
		J('#dlg_envoi').dialog({
			modal: true,
			buttons: {
				'Créer': function () {
					v2_saisie_creerObs()
				},
				'Annuler': function () {
					J('#dlg_envoi').dialog('close');
				}
			}
		});
	}

	function v2_saisie_ajouterPointRepertoire() {
		console.log("déprécié");
		var x = document.fcreation.x.value;
		var y = document.fcreation.y.value;
		var nom = J('#rep_pt_nom').val();
		J.ajax({
			url: '?t=repertoire_ajoute_point&x='+x+'&y='+y+'&nom='+nom,
			success: function (data) {
				if (data != 'OK') {
					v2_saisie_erreur(data);
				}
				J('#dlg_choix_nom_point').dialog('close');
			}
		});
	}
	
	function v2_saisie_ajouterPointRepertoireDlg()
	{
		if (document.fcreation.x.value == '') {
			v2_saisie_erreur("Vous devez créer un point sur la carte. Pour ce faire vous devez cliquer sur la carte. Tant que vous n'avez pas atteind le bon niveau de zoom ce niveau change jusqu'à ce que une marque apparaisse pour indiquer la position de votre pointage");
			return;
		}
		J('#rep_pt_nom').val('');
		J('#dlg_choix_nom_point').dialog({
			modal:true,
			buttons: {
				Créer: function () { v2_saisie_ajouterPointRepertoire(); },
				Annuler: function () { J('#dlg_choix_nom_point').dialog('close'); }
			}
		});
		
	}

	function v2_saisie_saisieCoordonneesDlg() {
		J('#sp_lat_d').val('');
		J('#sp_lat_m').val('');
		J('#sp_lat_s').val('');
		
		J('#sp_lon_d').val('');
		J('#sp_lon_m').val('');
		J('#sp_lon_s').val('');

		J('#sp_lat_dd').val('');
		J('#sp_lon_dd').val('');
		
		J('#dlg_saisie_point').dialog({
			modal:true,
			buttons: {
				Placer: function () {
					var latitude_saisie;
					var longitude_saisie;
					
					var d = parseInt(J('#sp_lat_d').val());
					log(d);
					if (isNaN(d)) {
						// La latitude DMS n'est pas un chiffre
						var lat = parseFloat(J('#sp_lat_dd').val());
						if (isNaN(lat)) {
							// Pas mieux en base 10
							alert('Verifier votre saisie');
							return;
						} else {
							log('utilise DD');
							latitude_saisie = parseFloat(J('#sp_lat_dd').val());
							longitude_saisie = parseFloat(J('#sp_lon_dd').val());
						}						
					} else {
						log('utilise DMS');
						var d = parseInt(J('#sp_lat_d').val());
						var m = parseInt(J('#sp_lat_m').val());
						var s = parseInt(J('#sp_lat_s').val());
						if (isNaN(d)) d = 0;
						if (isNaN(m)) m = 0;
						if (isNaN(s)) s = 0;
						latitude_saisie = d+m/60+s/3600;
						d = parseInt(J('#sp_lon_d').val());
						m = parseInt(J('#sp_lon_m').val());
						s = parseInt(J('#sp_lon_s').val());
						if (isNaN(d)) d = 0;
						if (isNaN(m)) m = 0;
						if (isNaN(s)) s = 0;
						longitude_saisie = d+m/60+s/3600;
					}
					
					var prj_ign = new OpenLayers.Projection('EPSG:3857');
					var prj_src = new OpenLayers.Projection('EPSG:4326');
					
					pt = new OpenLayers.LonLat(longitude_saisie, latitude_saisie);
					pt.transform(prj_src, prj_ign);

					var point = new Espace();
					point.pointDepuisLonLat(pt);
					iface.nouvelleLocalisation(point, true);
				},
				Annuler: function () { J('#dlg_saisie_point').dialog('close'); }
			}
		});
	}

	function v2_saisie_setPointInfo(pt) {
		document.fcreation.x.value = pt.lon;
		document.fcreation.y.value = pt.lat;
		J('#bobs-v2-lon').html(pt.lon);
		J('#bobs-v2-lat').html(pt.lat);
		var wkt = 'POINT('+pt.lon+'%20'+pt.lat+')';
		J('#bobs-v2-pt-commune').load('?t=json&a=point_info&wkt='+wkt);
		document.fcreation.id_espace.value = null;
		document.fcreation.table_espace.value = null;
	}

	function v2_saisie_ouvrirRepertoireDlg() {
		J('#dlg_liste_repertoire_int').html('<img src="icones/load.gif"/> chargement en cours');
		J('#dlg_liste_repertoire').dialog({width:600, height:480});		
		J('#dlg_liste_repertoire_int').load('?t=repertoire_liste'); 
	}

	function v2_saisie_importGPX() {
		J('#dlg_liste_repertoire_int').html('<img src="icones/load.gif"/> chargement en cours');
		J('#dlg_liste_repertoire_int').load('?t=repertoire_import_gpx'); 
	}
	
	function v2_saisie_placerGPX(gpx_lat, gpx_lon) {
		var prj_ign = new OpenLayers.Projection('IGNF:GEOPORTALFXX');
		var prj_src = new OpenLayers.Projection('EPSG:4326');
		var pt = new OpenLayers.LonLat(gpx_lon, gpx_lat);
		v2_saisie_setPointInfo(pt);
		pt.transform(prj_src, prj_ign);
		v2_saisie_setMarqueurPos(pt);
		var zoom = map.getZoom();
		if (zoom < 13) zoom = 13;
		map.setCenter(pt, zoom);
	}
	
	//{/literal}
	var point = false;
	var point_z = 13;
	{if $x}
		point = new OpenLayers.LonLat({$x},{$y});
	{else}
		point = new OpenLayers.LonLat({$xorg},{$yorg});
		point_z = {$zorg};
	{/if}
	init_saisie('{$key}',point);	
	{if $ouvre_repertoire}
	v2_saisie_ouvrirRepertoireDlg();
	{/if}
</script>
{include file="poste_foot.tpl"}
