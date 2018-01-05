{include file="poste_head.tpl" titre_page="Chiros"}
<style>{literal}.ui-front {z-index:10000;}{/literal}</style>
{literal}<style>.chiros_commentaire_invis { display:none;}</style>{/literal}
{if $u->acces_chiros}
<input type="hidden" name="id_espace" value="" id="id_espace"/>
<div style="display: none;">
    <div id="bobs-chiro-observations" title="Observations"></div>
    <div id="bobs-chiro-iface"></div>
    <div  id="bobs-chiro-new-date" title="Ajouter une date">
	<p class="directive">Date</p>
	<p class="valeur"><input style="z-index:20050; position:relative;" type="text" name="date_sortie" id="date_sortie"/></p>
	<p class="directive">Commentaire</p>
	<textarea id="sortie-commentaire" name="commentaire" cols="30" rows="5"></textarea>
    </div>
    <div title="Sites" id="chiro_l_site"></div>
    <div title="Liste des gîtes" id="chiro_l_cav"> </div>
    <div title="Observations, visites" id="chiro_l_inf"> </div>
    <div title="Propriétés d'un gîte" id="chiro_l_pcav"></div>
    <div title="Saisie données" id="chiro_i_saisie"></div>
    <div title="Ajout d'un commentaire" id="chiro_ajout_commentaire">
    	<form id="f_chiro_ajout_commentaire">
		Commentaire :<br/>
		<textarea cols="40" rows="4" name="commentaire" id="f_chiro_ajoute_commentaire_commentaire"></textarea>
		<input type="hidden" name="id" id="f_chiro_ajoute_commentaire_id_espace"/>
	</form>
    </div>
</div>
<table width="100%">
    <tr>
	<td valign="top" width="100%">
	    <h1 style="margin: 2px;">Prospections chiroptères</h1>
	    <small>
		<span style="background-color: #87edde">&nbsp;&nbsp;&nbsp;&nbsp;</span> Points anciens ou autre
		<span style="background-color: #190fde">&nbsp;&nbsp;&nbsp;&nbsp;</span> Obs -2 ans
		<span style="background-color: #e87900">&nbsp;&nbsp;&nbsp;&nbsp;</span> Au calendrier
		<span style="background-color: #f0e800">&nbsp;&nbsp;&nbsp;&nbsp;</span> A faire
		<span style="background-color: #1fd700">&nbsp;&nbsp;&nbsp;&nbsp;</span> Fait
		<span style="background-color: #000000">&nbsp;&nbsp;&nbsp;&nbsp;</span> Ne pas faire
	    </small>
	    <div id="map2" style="width: 100%; height: 500px;" gmaps="{$gmapon}"></div>
	</td>
    </tr>
</table>
<div>
{include file="chiros_outils.tpl"}
<div class="bobs-demi">
	<div class="bobs-demi-titre">Carte</div>
	<div class="bobs-demi-interieur">
	    <ul>
		<li>
		    <a href="javascript:chiro_ouvrir_fenetres();">Ouvrir les fenêtres d'infos</a>
		</li>
		<li>
		    <a href="javascript:chiro_ajouter_une_cavitee();">Ajouter un gîte</a>
		</li>
		{if $u->acces_qg_ok() or $u->id_utilisateur==2093}
			<a href="?t=chiro_export_lcav">Télécharger la liste des gîtes</a>
		{/if}
		<li>
		    <div id="chiro_mode"></div>
		</li>
	    </ul>
	    <hr/>
	    <b>Rechercher un point par son nom</b><br/>
	    Nom : <input type="text" id="s_chiro_nom_i" size="6"/>
	    <input type="button" value="Rechercher" id="s_chiro_nom_b"/>
	    <div style="padding: 5px; background-color:#eee; display:none;" id="s_chiro_nom_r"></div>
	</div>
</div>
<div style="clear:both;"></div>
<script type="text/javascript">
var observateur_session_id = "{$u->id_utilisateur}";
var observateur_session_nom = "{$u->nom} {$u->prenom}";
{literal}
var chiro_zoom_min = 10;
var observateurs = new Array();

J('#date_sortie').datepicker();

J('#s_chiro_nom_b').click(function () {
	var div = J('#s_chiro_nom_r');
	div.show();
	div.html('recherche en cours');
	var s = J('#s_chiro_nom_i').val();
	var r = chiro_chercher_point(s);
	if (r.err == undefined) {
		div.html('Point <b>'+r.ref+'</b> trouvé<br/>');
		div.append('id_espace : <b>#'+r.id_espace+'</b><br/>');
		div.append('lat: <b>'+r.y+'</b> lon: <b>'+r.x+'</b><br/>');
		div.append('<a href="javascript:chiro_zoom_pt('+r.x+','+r.y+');">Placer la carte sur ce point</a><br/>');
	} else {
		div.html("<font color=red>"+r.message+"</font>");
	}
});

function chiro_ouvre_commentaire_espace(id_espace) {
	J('#commentaires_'+id_espace).toggle();
}

function chiro_ouvre_commentaire_espace_editeur(id_espace) {
	J('#f_chiro_ajoute_commentaire_id_espace').val(id_espace);
	J('#chiro_ajout_commentaire').dialog({width: 400, height: 300, buttons: {
		Ajouter: function () {
			var args = J('#f_chiro_ajout_commentaire').serialize();
			J(this).dialog('close');
    			J('#chiro_l_site').load("?t=chiro_espace_detail&ajouter_commentaire=1&"+args);
		}
	}});
}

function chiro_zoom_pt(x,y) {
	var pt = new OpenLayers.LonLat(x,y);
    	pt.transform(m.displayProjection, m.projection);
	log(pt);
	m.moveTo(pt, 17);
}

function chiro_chercher_point(ref_point) {
	var xhr = J.ajax({url: '?'+J.param({t:'chiros_recherche_espace', 'ref_point':ref_point}), async: false});
	var data = J.parseJSON(xhr.responseText);
	log(data);
	return data;
}

function chiro_observateur_aff_liste() {
    var str = '';
    for (var i=0; i<observateurs.length; i++) {
	str = str + ' <a onclick="javascript:chiro_observateur_retire('+observateurs[i].id+');" href="javascript:;">';
	str = str + observateurs[i].nom + '</a>';
    }
    J('#saisie_liste_observateurs').html(str);
}

function chiro_observateur_ajoute(id_utilisateur, nom) {
    for (var i=0; i<observateurs.length; i++) {
	if (id_utilisateur == observateurs[i].id) {
	    log('déjà présent');
	    return false;
	}
    }
    observateurs.push({nom: nom, id: id_utilisateur});
    chiro_observateur_aff_liste();
    return true;
}

function chiro_observateur_retire(id_utilisateur) {
    var o2 = new Array();
    var t;
    while ((t = observateurs.shift())) {
	if (t.id != id_utilisateur)
	    o2.push(t);
    }
    observateurs = o2;
    chiro_observateur_aff_liste();
}

function chiro_ouvrir_saisie(id_cavite) {
    var i = J('#chiro_i_saisie');
    i.html('Chargement du formulaire...');
    i.dialog({height: 500, width: 600, buttons:{
	    'Annuler': function () { 
		J('#chiro_i_saisie').dialog('close');
	    },
	    'Enregistrer': function () {
		if (chiro_envoyer_donnees()) {
		    J('#chiro_i_saisie').dialog('close');
		}
	    }
    }});
    i.load('?t=chiro_saisie&id='+id_cavite, function () {
	// executé après le chargement de la fenêtre de saisie
	if (observateurs.length == 0)
	    chiro_observateur_ajoute(observateur_session_id, observateur_session_nom);

	J('#saisie_recherche_nom').autocomplete({
	    source: '?t=observateur_autocomplete2',
	    select: function (event, ui) {
		chiro_observateur_ajoute(ui.item.id, ui.item.label);
		log(event.target);
		event.target.value = '';
		// stop la propagation de l'évènement
		return false;
	    }
	});
	
	J('#saisie_date_observation').datepicker();
	
	chiro_observateur_aff_liste()
    });
}


function chiro_envoyer_donnees() {
    var f = J('#f_chiro_envoi_donnees');
    var url = f.serialize();
    
    if (observateurs.length == 0) {
	alert('Vous avez oublié les observateurs');
	return false;
    }
    var d = J('#saisie_date_observation').val();
    if (d.length <= 8) {
	alert('Vérifier la date');
	return false;
    }
    for (var i=0; i<observateurs.length; i++) {
	url = url + '&' + 'u'+i+'='+observateurs[i].id;
    }
    url = '?t=chiro_saisie_enregistre&'+url;
    var id_espace = J('#saisie_id_espace').val();
    J('#f_chiro_envoi_donnees').load(url, function () {
	chiro_affiche_espace_detail(id_espace);
    });
    J('#chiro_i_saisie').dialog({buttons: {
	Fermer: function () {	    
	    J('#chiro_i_saisie').dialog('close');
	}}
    });
    return false;
}

function chiro_ouvrir_fenetres() {
    J('#chiro_l_cav').dialog({height: 250, width: 250, position: [250,0]});
    J('#chiro_l_site').dialog({height: 250, width: 250, position: [550,0]});
    J('#chiro_l_inf').dialog({height: 250, width: 250, position: [850,0]});
}

function chiro_ajouter_prospection(id_espace) {
    J('#chiro_l_site').html('<img src=icones/load.gif>');
    J('#chiro_l_site').load('?t=chiro_espace_detail&ajouter_prospection=1&id='+id_espace);
    chiro_cavites();
}

function chiro_retirer_prospection(id_espace) {
    J('#chiro_l_site').html('<img src=icones/load.gif>');
    J('#chiro_l_site').load('?t=chiro_espace_detail&retirer_prospection=1&id='+id_espace);
    chiro_cavites();
}

function chiro_form_new_date(id_espace) {    
    J('#id_espace').val(id_espace);
    J('#bobs-chiro-new-date').dialog({zIndex:1500, buttons: {"Enregistrer": chiro_form_new_date_submit}});
}

function chiro_participer(id_espace, id_date) {
    J('#chiro_l_inf').html('<img src="icones/load.gif">');
    J('#chiro_l_inf').load('?t=chiro_espace_detail2&act=participer&id='+id_espace+'&id_date='+id_date);
}

function chiro_annuler(id_espace, id_date) {
    J('#chiro_l_inf').html('<img src=icones/load.gif>');
    J('#chiro_l_inf').load('?t=chiro_espace_detail2&act=annuler&id='+id_espace+'&id_date='+id_date);
}

function chiro_form_new_date_submit() {
    var id_espace = J('#id_espace').val();
    var date_sortie = J('#date_sortie').val();
    var commentaire = J('#sortie-commentaire').serialize();
    var args_date = '&id_espace='+id_espace+'&date_sortie='+date_sortie+'&act=ajoute_date&'+commentaire;
    J('#chiro_l_inf').html('<img src=icones/load.gif>');
    J('#chiro_l_inf').load('?t=chiro_espace_detail2&id='+id_espace+args_date);
    J('#bobs-chiro-new-date').dialog('close');

}

function chiro_voir_point(p) {
	log('chiro_voir_point: '+p);
	var ok_trouve = false;
	for (var i=0; i<lv.features.length; i++) {
		if (lv.features[i].data.nom == p) {
			ok_trouve = true;
			break;
		}
	}
	if (!ok_trouve) {
		log('chiro_voir_point: point pas trouvé');
		return;
	}
	ctrl_s.unselectAll();
	ctrl_s.select(lv.features[i]);
}

function chiro_cavites() {
	var extent = m.getExtent();
	extent.transform(m.projection, m.displayProjection);
	J.ajax({
		url: '?t=json&a=espace_chiros_in&ax='+extent.left+'&bx='+extent.right+'&ay='+extent.bottom+'&by='+extent.top,
		success: function (r,txtStatus,xhr) {
			var taille_paquet = 30;
			var n = 0;
			var args_status = '';
			var geojson_format = new OpenLayers.Format.GeoJSON({
				'internalProjection': new OpenLayers.Projection("EPSG:900913"),
				'externalProjection': new OpenLayers.Projection("EPSG:4326")
			});
			var features = geojson_format.read(r);
			lv.removeFeatures(lv.features);
			lv.addFeatures(features);
			var featuresok = [];
			txt = '';
			for (var i=0; i<features.length; i++) {
				var id_espace;
				txt += '<a href="javascript:chiro_voir_point(\''+features[i].data.nom+'\');">'+features[i].data.nom+'</a><br>';
				id_espace = features[i].data.id_espace;
				args_status += '&e'+id_espace+'='+id_espace;
				n++;
			}
			J('#chiro_l_cav').html(txt);
		}		
	});
}

function chiro_zoom_level(map) {
    zoom = m.getZoom();
    J('#chiro_l_cav').html('');
    J('#chiro_l_site').html('');
    J('#chiro_l_inf').html('');
    if (chiro_zoom_min <= zoom) {
        J('#chiro_l_inf').html("Niveau de zoom : "+zoom);
	chiro_cavites();
    } else {
	J('#chiro_l_inf').html('<font color="red">Zoommez plus pour voir les gîtes</font>');
    }
}

function chiro_select_feature(feature) {   
    chiro_affiche_espace_detail(feature.data.id_espace)
}

function chiro_affiche_espace_detail(id_espace) {
    J('#chiro_l_inf').html('<img src=icones/load.gif>');
    J('#chiro_l_site').html('<img src=icones/load.gif>');
    J('#chiro_l_inf').load('?t=chiro_espace_detail2&id='+id_espace);
    J('#chiro_l_site').load('?t=chiro_espace_detail&id='+id_espace);
}

function chiro_creation_cavite_evt(evt) {
    var cav = evt.feature;
    var pt = cav.geometry.transform(m.projection, m.displayProjection);
    chiro_mode_selection();
    log('nouveau point x = '+ pt.x);
    log('nouveau point y = '+ pt.y);
    J.ajax({
	url:"?t=chiros_enregistre_point&x="+pt.x+"&y="+pt.y,
	async:false,
	success: function (data) {
	    chiro_ouvre_w_propriete(data);
	}
    });
}

function chiro_w_propriete_ferme() {
    J('#chiro_l_pcav').dialog('close');
}

function chiro_w_propriete_sauve() {
    var id_espace = J('#chiro_l_pcav').attr('id_espace');
    log('sauvegarde espace_chiro #'+id_espace);
    var args = J('#f_espace_chiro_'+id_espace).serialize();
    xhr = J.ajax({async:false, url:'?t=chiro_espace_sauve&'+args});
    if (xhr.responseText != 'OK') {
	J('#chiro_l_pcav').html(xhr.responseText);
    } else {
	J('#chiro_l_pcav').dialog('close');
    }
    chiro_affiche_espace_detail(id_espace);
    chiro_cavites();
}

function chiro_ouvre_w_propriete(id_espace) {
    J('#chiro_l_pcav').dialog({buttons: {
	    "Enregistrer": chiro_w_propriete_sauve,
	    "Annuler": chiro_w_propriete_ferme
	}});
    J('#chiro_l_pcav').attr('id_espace', id_espace);
    J('#chiro_l_pcav').html('<img src=icones/load.gif>');
    J('#chiro_l_pcav').load('?t=chiro_espace_edit&id='+id_espace);
}

function chiro_ajouter_une_cavitee() {
    ctrl_s.deactivate();
    ctrl_a.activate();
    J('#chiro_mode').html('Mode création de point');
}

function chiro_mode_selection() {
    ctrl_s.activate();
    ctrl_a.deactivate();
    J('#chiro_mode').html('Mode sélection');
}

function chiro_init() {
	style = new OpenLayers.Style(
	    {
		pointRadius: 5,
		strokeWidth: 1
	    },
	    {rules:[
		    new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
			    type: OpenLayers.Filter.Comparison.EQUAL_TO,
			    property: "classe",
			    value: "inconnu"
			    }),
			symbolizer: {fillColor: "#87edde", strokeColor: "#aaedde"}
		    }),
		    new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
			    type: OpenLayers.Filter.Comparison.EQUAL_TO,
			    property: "classe",
			    value: "prevue"
			    }),
			symbolizer: {fillColor: "#e87900", strokeColor: "#e8af00"}
		    }),
		    new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
			    type: OpenLayers.Filter.Comparison.EQUAL_TO,
			    property: "classe",
			    value: "fait"
			    }),
			symbolizer: {fillColor: "#1fd700", strokeColor: "#1fd700"}
		    }),
		    new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
			    type: OpenLayers.Filter.Comparison.EQUAL_TO,
			    property: "classe",
			    value: "moins2"
			    }),
			symbolizer: {fillColor: "#190fde", strokeColor: "#ffffff"}
		    }),
		    new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
			    type: OpenLayers.Filter.Comparison.EQUAL_TO,
			    property: "classe",
			    value: "a_prospecter"
			    }),
			symbolizer: {fillColor: "#f0e800", strokeColor: "#f0fa00"}
		    }),
		    new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
			    type: OpenLayers.Filter.Comparison.EQUAL_TO,
			    property: "classe",
			    value: null
			    }),
			symbolizer: {fillColor: "#ff0000", strokeColor: "#ff0000"}
		    }),
		    new OpenLayers.Rule({
			filter: new OpenLayers.Filter.Comparison({
			    type: OpenLayers.Filter.Comparison.EQUAL_TO,
			    property: "classe",
			    value: "comble"
			    }),
			symbolizer: {fillColor: "#000000", strokeColor: "#ffffff"}
		    })
		]
	    }
	);

	m = carte_inserer(document.getElementById('map2'));
	m.events.register("moveend", null, chiro_zoom_level);

	lv = new OpenLayers.Layer.Vector("Points", {styleMap: new OpenLayers.StyleMap({'default': style})});
	m.addLayer(lv);

	// Control selection
	ctrl_s = new OpenLayers.Control.SelectFeature(lv);
	ctrl_s.onSelect = chiro_select_feature;
	ctrl_s.multiple = false;
	m.addControl(ctrl_s);

	// Control ajout pt
	ctrl_a = new OpenLayers.Control.DrawFeature(lv, OpenLayers.Handler.Point);
	m.addControl(ctrl_a);
	ctrl_a.events.register("featureadded", null, chiro_creation_cavite_evt);

	chiro_mode_selection();
	chiro_ouvrir_fenetres();
	{/literal}
	{if $x}
	    var pt = new OpenLayers.LonLat({$x},{$y});
	{else}
	    var pt = new OpenLayers.LonLat(2.80151, 49.69606);
	{/if}
	pt.transform(m.displayProjection, m.projection);
	var z = {if $z}{$z}{else}8{/if};
	m.setCenter(pt, z);
}
var ctrl_s;
var ctrl_a;
var m;
var lv;
var style;
J(document).ready(chiro_init);
</script>
{else}
<div class="bobs-commtr">
Cet espace est réservé aux participants des prospections hivernales. Si vous
devez avoir accès à cette partie du site faites en la demande auprès du
coordinateur ou des permaments.
</div>
{/if}
{include file="poste_foot.tpl"}
