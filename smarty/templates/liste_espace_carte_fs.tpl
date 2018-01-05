<html>
	<head>
		<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	</head>
<body>
{literal}
<style>
	#formulaire {
		display: none; 
	}
	.olControlAttribution {
		background-color: white;
		padding: 2px;
	}
	#data {
		position: fixed;
		top: 0;
		left: 0;
		width: 15%;
		height: 100%;
	}
	#data_top {
		width:100%;
		height:50%;
		overflow:scroll;
	}
	#data_bottom {
		width: 100%;
		height: 50%;
		overflow:auto;
	}
	#map {
		position: fixed;
		top: 0;
		left:15%;
		width: 85%;
		height: 100%;
	}
	* {
		font-family: verdana,arial;
	}
	.container {
		padding: 2px;
	}
	li {
		cursor:pointer;
	}
	li:hover {
		background-color: yellow;
	}
</style>
{/literal}
<script src="http://deco.picardie-nature.org/jquery/js/jquery-1.7.1.min.js" language="javascript"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/proj4js/lib/proj4js-compressed.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/OpenLayers-2.12/OpenLayers.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/jquery-1.7.2.min.js"></script>
<script type="text/javascript" src="http://maps.picardie-nature.org/carto.js"></script>
<div id="map"> </div>
<div id="data">
	<div id="data_top">
		<div class="container">
			Légende : <a href="javascript:;" id="a_coul_espace">Une couleur par identifiant</a>
			<ul id="list"></ul>
		</div>
	</div>
	<div id="data_bottom" style="display:none;">
		<div class="container">
			<div id="attributs"></div>
			<h4>Commentaires</h4>
			<div id="commentaires"></div>
			<h4>Ajouter un commentaire</h4>
			<textarea style="width:100%; height: 5em;" type="text" id="nouveau_commentaire" placeholder="nouveau commentaire"></textarea>
			<button id="btn_nouveau_commentaire">enregistrer</button>
		</div>
	</div>
</div>
<script>
{literal}
	var J = jQuery.noConflict();
	function carte_ajout_layer_wfs(map, id_liste, titre, mention, style) {
		var lv  = new OpenLayers.Layer.Vector(titre, {
			styleMap: style,
			strategies: [new OpenLayers.Strategy.BBOX()],
			projection: m.map.displayProjection,
			protocol: new OpenLayers.Protocol.WFS({
				url: "?t=liste_espace_carte_wfs",
				featureType: "liste_espace_"+id_liste,
				featureNS: "http://www.clicnat.org/espace"
			}),
			attribution: mention
		});
		return lv;
	}
{/literal}
	var m = new Carto('map');
	console.log(m);
	var liste = {$l->id_liste_espace};
	var mention = "{$l->mention}";
	var titre = "{$l->nom}";
{literal}
	var stylemap = new OpenLayers.StyleMap({'default':{
			    strokeColor: "#000000",
			    strokeOpacity: 1,
			    strokeWidth: 1,
			    fillColor: "#ff0000",
			    fillOpacity: 0.5,
			    pointRadius: 6
	}});
	var lv = carte_ajout_layer_wfs(m,liste,titre,mention,stylemap);
	lv.events.register('featuresadded', null, function () {
		for (feature in this.features) {
			$('#list').append("<li id_espace="+this.features[feature].data.id_espace+" class=espace>"+this.features[feature].data.nom+"</li>");
		}
		J('.espace').click(function () {
			var e = J(this);
			var f;
			var feature = false;
			var layer = lv; 
			var id_espace = e.attr('id_espace');
			for (f in layer.features) {
				if (layer.features[f].data.id_espace == id_espace) {
					feature = layer.features[f];
				}
			}

			if (!feature) {
				alert("pas trouvé ?");
			}
			
			lv.map.zoomToExtent(feature.geometry.bounds, false);
		});
	});
	m.map.addLayer(lv);

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

	var ctrl = new OpenLayers.Control.SelectFeature(lv, {
		multiple: false,
		box: false
	});
	m.map.addControls([ctrl]);
	

	var selection = false;

	function afficher_commentaires(id_espace,table) {
		J.ajax({
			url: '?'+J.param({
				t: 'json',
				a: 'espace_commentaires',
				table: table,
				id_espace: id_espace
			}),
			success: function (data, textstatus, xhr) {
				var commentaires = J.parseJSON(data);
				J('#commentaires').html("");
				for (c in commentaires) {
					J('#commentaires').append("<div class=commentaire>");
					J('#commentaires').append("<pre>"+commentaires[c].commentaire+"</pre>");
					J('#commentaires').append("<small>par "+commentaires[c].utilisateur+"<br/>le "+commentaires[c].date_commentaire_fr+"</small>");
					J('#commentaires').append("<hr/></div>");
				}
			}
		});
	}

	J('#btn_nouveau_commentaire').click(function () {
		if (!selection) {
			alert("pas d'élément sélectionné");
		}
		var texte = J('#nouveau_commentaire').val();
		if (texte.length > 0) {
			var table = selection.data['classe'];
			var id_espace = selection.data['id_espace'];

			J.ajax({
				url: '?'+J.param({
					t: 'json',
					a: 'espace_ajouter_commentaire',
					table: table,
					id_espace: id_espace,
					commentaire: texte
				}),
				success: function (data, textstatus,xhr) {
					afficher_commentaires(id_espace,table);
					$('#nouveau_commentaire').val("");
				}
			});
		}

	});

	ctrl.events.register("featurehighlighted", null, function () { 
		var f = lv.selectedFeatures[0];
		selection =f;
		var attributs = $('#attributs');

		attributs.html("<table>");
		attributs.append("<tr><th>Attribut</th><th>Valeur</th></tr>");
		for (attr in f.data) {
			attributs.append("<tr><td>"+attr+"</td><td>"+f.data[attr]+"</td></tr>");
		}
		attributs.append("</table>");
		afficher_commentaires(f.data['id_espace'], f.data['classe']);
		J('#data_bottom').show();
	});

	ctrl.events.register("featureunhighlighted", null, function () {
		J('#data_bottom').hide();
		selection = false;
	});
	ctrl.activate();
{/literal}
</script>
</body>
</html>
