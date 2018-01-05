{include file="poste_head.tpl" titre_page="Passage points noirs" usemap=true}
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
Légende : <a href="javascript:;" id="a_coul_espace">Une couleur par identifiant</a>
<div id="sel">
	<h2>Sélectionné</h2>
	Numéro d'espace : <span id="sel_id_espace">aucun</span><br/>
	Nom : <span id="sel_nom">-</span><br/>
	Référence : <span id="sel_reference">-</span><br/>
	Type : <span id="sel_classe">-</span><br/>
	<div id="formulaire">
		<form id="fextraction" method="post" action="?t=journal&act=condition_enreg">
			<input type="hidden" name="classe" value="bobs_ext_c_poly"/>
			<input type="hidden" name="id_espace" id="f_id_espace"/>
			<input type="hidden" name="table_point" value="espace_point"/>
			<input type="hidden" name="table_poly" value="espace_polygon">
			<input type="submit" value="Utiliser comme critère d'extraction sur les observations"/>
			(fonctionne uniquement sur les observations associées avec un point)<br/>
		</form>
	</div>
</div>
<script>
	var passages_liste = {$passages->id_liste_espace};
	var passages_titre = "{$passages->nom}";
	var passages_mention = "{$passages->mention}";
	var pointsnoirs_liste = {$pointsnoirs->id_liste_espace};
	var pointsnoirs_titre = "{$pointsnoirs->nom}";
	var pointsnoirs_mention = "{$pointsnoirs->mention}";
{literal}
	var stylemap_a = new OpenLayers.StyleMap({'default':{
			    strokeColor: "#ff0000",
			    strokeOpacity: 1,
			    strokeWidth: 3,
			    fillColor: "#ff0000",
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
	function layer_wfs(titre, id_liste, stylemap) {
		var lv  = new OpenLayers.Layer.Vector(titre, {
			styleMap: stylemap,
			strategies: [new OpenLayers.Strategy.BBOX()],
			projection: m.displayProjection,
			protocol: new OpenLayers.Protocol.WFS({
				url: "?t=liste_espace_carte_wfs",
				featureType: "liste_espace_"+id_liste,
				featureNS: "http://www.clicnat.org/espace"
			})
		});
		return lv;
	}

	var lv_a = carte_ajout_layer_wfs(m,passages_liste,passages_titre,passages_mention,stylemap_a);
	var lv_b = carte_ajout_layer_wfs(m,pointsnoirs_liste,pointsnoirs_titre,pointsnoirs_mention,stylemap_b);

	var pt = new OpenLayers.LonLat(2.80151, 49.69606);
	pt.transform(m.displayProjection, m.projection);
	m.setCenter(pt, 8);

	J('#a_coul_espace').click(function () {
		var news = layer_legende_diff_espace(lv);
		lv.styleMap.styles['default'] = news;
		lv.redraw();
	});

	function layer_legende_diff_espace(lv) {
		J('#legende').html('');
		var rules = new Array();
		var couleurs = ['#FFFF00','#FFFFFF','#00F5FF','#FF6347','#00EE76','#6959CD','#CD6839','#27408B','#EE0000','#7D26CD','#9AFF9A',
				'#C0FF3E','#FFDEAD','#FFF68F','#ADFF2F','#ADFF2F','#DEB887','#FF7F24','#DC143C'];
		var espaces_faits = new Array();
		for (var i=0; i<lv.features.length; i++) {
			var id_espace = lv.features[i].data.id_espace;
			var idx = espaces_faits.indexOf(id_espace);
			if (espaces_faits.indexOf(lv.features[i].data.id_espace) < 0) {
				var couleur = couleurs[espaces_faits.length%couleurs.length];
				rules.push(new OpenLayers.Rule({
					filter: new OpenLayers.Filter.Comparison({
						type: OpenLayers.Filter.Comparison.EQUAL_TO,
						property: "id_espace",
						value: id_espace
					}),
					symbolizer: {
						fillColor: couleur,
						strokeColor: couleur
					}
				}));
				espaces_faits.push(lv.features[i].data.id_espace);
				J('#legende').append("<span style='background-color:"+couleur+"'>&nbsp;&nbsp;</span> "+lv.features[i].data.espace+" ");
			}
		}
		return new OpenLayers.Style({pointRadius: 6, strokeWidth: 1, fillOpacity: 1}, {rules: rules});
	}

	var ctrl = new OpenLayers.Control.SelectFeature(lv_b, {
		multiple: false,
		box: false
	});
	m.addControls([ctrl]);

	ctrl.events.register("featurehighlighted", null, function () { 
		var f = lv_b.selectedFeatures[0];
		J('#sel_id_espace').html(f.data.id_espace);
		J('#sel_nom').html(f.data.nom);
		J('#sel_reference').html(f.data.reference);
		J('#sel_classe').html(f.data.classe);
		if (f.data.classe == 'espace_polygon') {
			J('#f_id_espace').val(f.data.id_espace);
			J('#formulaire').show();
		} else {
			J('#formulaire').hide();
		}

	});

	ctrl.events.register("featureunhighlighted", null, function () {
		J('#sel_id_espace').html('aucun');
		J('#sel_nom').html('-');
		J('#sel_reference').html('-');
		J('#sel_classe').html('-');
		J('#formulaire').hide();

	});
	ctrl.activate();
{/literal}
</script>
{include file="poste_foot.tpl"}
