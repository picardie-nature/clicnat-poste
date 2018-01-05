{include file="poste_head.tpl" titre_page="Saisie"}
<form method="post" action="?t=saisie_creation_obs" name="fcreation" id="fcreation">
	<input type="hidden" name="date"/>
	<input type="hidden" name="x"/>
	<input type="hidden" name="y"/>
	<input type="hidden" name="id_espace"/>
	<input type="hidden" name="table_espace"/>
	<input type="hidden" name="zoom"/>
</form>
<table width="100%">
	<tr>
		<td valign="top" class="oreille">
			<h1>Recherche commune</h1>
			<div class="valeur">
				<input type="text" name="srch_commune" id="srch_commune"/><br/>
				<small>indiquez ici le nom d'une commune pour la localiser sur la carte</small>
			</div>
			<div id="srch_commune_choix" class="autocomplete"></div>

			<h1>Coordonnées</h1>
			<div class="valeur">
				<small>ici s'affichent les coordonnées du point affiché sur la carte</small>
				<div class="directive">Position - Latitude</div>
				<div class="valeur"> <input type="text" id="latitude"/> </div>
				<div class="directive">Position - Longitude</div>
				<div class="valeur"> <input type="text" id="longitude"/> </div>
			</div>
			<h1>Point sélectionné</h1>
			<div id="ptsel" class="valeur">
				<small>ici s'affiche le nom de la commune à qui appartient le territoire où se trouve le point de la carte</small>
			</div>
			<h1>Date des observations</h1>
			<div class="valeur">
				<small>indiquez ici la date de vos observations</small>
				<div class="valeur" >
					<input maxlength="10" size="10" type="text" id="date" value="{$date_derniere_saisie}" style="z-index: 9000; position: relative;"/>
					<input type="button" value="Créer l'observation" onclick="javascript:collecte();"/>
				</div>
			</div>
		</td>
		<td valign="top"  width="85%">
			<div id="map1" style="width:100%; height:500px;"></div>
			<input type="button" value="Mesure" onclick="javascript:mesure_demarrer();"/>
			<a href="?t=v2_saisie">Tester la version avec le géoportail (attention en développement)</a>
		</td>
	</tr>
</table>
<div>
	<h1>Observations en cours de saisie</h1>
	<div id="observations_en_cours">
		En cours de chargement
	</div>
	<small>Cliquez sur la date pour modifier, valider ou supprimer une observation</small>
</div>

{literal}
<div id="dialog_saisie" title="Erreur de création observation"> </div>
<div id="bobs-mesure" title="Mesure"></div>
<script language="javascript">
	
	var m;
	var lv;
	var lc;
	var pt;
	var z;
	var mesure;

	function saisie_init() {
		// initialisation de la carte
		m = carte_inserer(document.getElementById('map1'));
		carte_ajout_click(m);
		lm = carte_ajout_layer_marqueurs(m, 'Marqueurs');
		lv = carte_ajout_layer_vecteurs(m, 'Points');
		lc = carte_ajout_layer_vecteurs(m, 'Commune');
		{/literal}
		{if $x}
			pt = new OpenLayers.LonLat({$x},{$y});
		{else}
			pt = new OpenLayers.LonLat({$xorg}, {$yorg});
		{/if}
		{literal}
		pt.transform(m.displayProjection, m.projection);
		var z = {/literal}{if $z}{$z}{else}{$zorg}{/if}{literal};

		m.setCenter(pt, z);
		mesure = mesure_ajouter_outils(m);
		maj_en_cours_de_saisie();
		J('#date').datepicker();
		J('#dialog_saisie').dialog({autoOpen: false, dialogClass: 'alert', modal: true});

	}

	J(document).ready(saisie_init);

	// recherche des communes
	function selection_commune_affichage(o) {
		lc.removeFeatures(lc.features);
		var geojson_format = new OpenLayers.Format.GeoJSON({
			'internalProjection': lc.map.projection,
			'externalProjection': lc.map.displayProjection
		});
		features = geojson_format.read(o.responseJSON);
		features[0].style = {
		    fillOpacity: 0,
		    strokeWidth: 4,
		    strokeOpacity: 1,
		    strokeDashstyle: 'longdash',
		    strokeColor: '#ff0000'
		};
		lc.addFeatures(features);
		lc.map.zoomToExtent(lc.getDataExtent());
	}

	J('#srch_commune').autocomplete({
		source: '?t=autocomplete_commune',
		select: function (event,ui) {
			var id_espace = ui.item.value;
			J('#srch_commune').val('');
			new J.ajax({
				url: '?'+J.param({
					t: 'commune_gml',
					id: id_espace,
					dataType: 'xml'
				}),
				success: function (data, s, xhr) {
					lc.removeFeatures(lc.features);
					var format = new OpenLayers.Format.GML({
						'internalProjection': lc.map.projection,
						'externalProjection': lc.map.displayProjection
					});
					var feature = format.parseFeature(data);
					feature.style = {
					    fillOpacity: 0,
					    strokeWidth: 4,
					    strokeOpacity: 1,
					    strokeDashstyle: 'longdash',
					    strokeColor: '#ff0000'
					};
					lc.addFeatures(feature);
					lc.map.zoomToExtent(lc.getDataExtent());
				}
			});
			return false;
		}
	});
	
	function collecte() {
		if (!marqueur_existe_et_unique(lm)) {
			J('#dialog_saisie').html("Vous devez d'abord placer un point sur la carte");
			J('#dialog_saisie').dialog('open');
			return;
		}

		if (!marqueur_est_visible(lm)) {
			J('#dialog_saisie').html("Le point doit être visible sur la carte");
			J('#dialog_saisie').dialog('open');
			return;
		}

		if (J('#date').val().length != 10) {
			J('#dialog_saisie').html("Le champ date doit avoir une longueur de 10 caractères (année sur 4 chiffres)");
			J('#dialog_saisie').dialog('open');
			return;
		}

		document.fcreation.date.value = J('#date').val();
		document.fcreation.zoom.value = m.getZoom();

		var url = '?t=json&a=creation_observation&' + J('#fcreation').serialize();
		J.ajax({
			url: url,
			success: function (data, textStatus, xhr) {
				data = J.trim(data);
				if (data.match(/^\d+/)) {
					document.location.href = '?t=saisie_base&id='+data;
					return;
				} else {
					var message = "Erreur inconnue "+data;
					if (data.match(/^DATE_VIDE/i)) {
						message = "Pour créer une observation vous devez fournir une date";
					} else if (data.match(/^NOPOINT/i)) {
						message = "Cliquez sur la carte pour indiquer le lieu de l'observation";
					} 	
				}
				J('#dialog_saisie').dialog('open');
			}
		});
	}

	function placer_point_observation(oid) {
		J.ajax({
			url: '?'+J.param({
				t: 'json',
				a: 'observation_x_y',
				oid: oid
			}),
			dataType: 'json',
			success: function (data,responseTxt,xhr) {
				document.fcreation.x.value = data.x;
				document.fcreation.y.value = data.y;
				document.fcreation.id_espace.value = data.id_espace;
				document.fcreation.table_espace.value = data.id_espace;
				J('#longitude').val(data.x);
				J('#latitude').val(data.y);
				var pt = saisie_set_marqueur_pos(m,lm);
				m.setCenter(pt);
				J('#ptsel').html('<img src="icones/load.gif" />');
				J('#ptsel').load('?'+J.param({
					t: 'json',
					a: 'point_info',
					wkt: 'POINT('+data.x+' '+data.y+')'
				}));
			}
		});
	}

	function maj_en_cours_de_saisie() {
		J('#observations_en_cours').load('?t=saisie_obs_brouillard');
	}

	function mesure_ajouter_outils(carte) {
	    var outil = new OpenLayers.Control.Measure(OpenLayers.Handler.Path, {persist: true, geodesic: true});
	    
	    outil.events.register('measure', null, mesure_affiche);
	    outil.events.register('measurepartial', null, mesure_affiche);
	    carte.addControl(outil)
	    
	    return outil;
	}

	function mesure_affiche(event) {	    
	    var unite = event.units;
	    var mesure = event.measure;
	    J('#bobs-mesure').html(mesure.toFixed(3)+" "+unite);
	}

	function mesure_demarrer() {
	    J('#bobs-mesure').dialog({buttons: {Fermer: function () {J(this).dialog('close');}}, beforeClose: mesure_terminer, position: [10,10]});
	    mesure.activate();
	}

	function mesure_terminer() {
	    mesure.deactivate();
	}
	
</script>
{/literal}
{include file="poste_foot.tpl"}
