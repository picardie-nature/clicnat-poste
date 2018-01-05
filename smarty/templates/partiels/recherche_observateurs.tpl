{literal}
<style>
.boite_dialogue h1 {
	font-size: 14px;
}
.boite_dialogue {
	position:fixed;
	top: 50%;
	left:50%;
	width: 800px;
	margin-left:-400px;
	margin-top:-300px;
	z-index:2042;
	background-color:white;
	border-color: #ccc;
	border-style: solid;
	border-width: 3px;
	display:none;
	padding: 10px;
}
.ele_recherche_observateur {
	font-size: 12px;
	padding: 3px;
	cursor: pointer;
}
.ele_recherche_observateur:hover {
	background-color: #ccc;
}
</style>
<script>
function Observateur(id,nom) {
	this.id = id;
	this.nom = nom;
}

function BoiteRechercheObservateurs(id_liste) {
	this.liste = new Array(); // liste des observateurs
	this.currentXHR = null; // requête en cours
	this.id_liste = id_liste; // liste html a mettre a jour après

	this.charge_liste_precedente = function () {
		var url = '?t=recherche_utilisateur_restaure_resultat';
		xhr = J.ajax({url: url, async: false});
		var data = J.parseJSON(xhr.responseText);
		for (var i=0; i<data.length; i++) {
			this.ajoute_observateur(data[i]);
		}
	}

	this.charge_liste_initiale = function () {
		var liste = J('#'+this.id_liste+' li');
		for (var i=0; i<liste.length; i++) {
			var observateur = new Observateur(liste[i].id, J(liste[i]).html());
			this.ajoute_observateur(observateur);
		}
	}

	this.modifie_liste_initiale = function () {
		var liste = J('#'+this.id_liste);
		var backup_groupe = '';
		liste.html('');
		for (var i=0; i<this.liste.length; i++) {
			liste.append('<li id="'+this.liste[i].id+'" id_utilisateur="'+this.liste[i].id+'">'+this.liste[i].nom+'</li>');
			if (i>0) backup_groupe = backup_groupe +',';
			backup_groupe = backup_groupe+this.liste[i].id;
		}
		J.ajax({url:'?t=recherche_utilisateur_sauve_resultat&ids='+backup_groupe, async: true});
		J(document).trigger('sauvegarde');
	}
	
	this.ajoute_observateur = function (obj) {
		for (var i=0;i<this.liste.length; i++) {
			if (this.liste[i].id == obj.id) {
				return false;
			}
		}
		this.liste.push(obj);
		J('#z_rech_obs_3 .cacher_moi').hide();
		J('#z_rech_obs_3').append('<div class="ele_recherche_observateur" style="background-color:white;" id="ru'+obj.id+'">'+obj.nom+'</div>');

		// le sélecteur #z_rech_obs_3 #ruID ne fonctionne pas sur IE7
		// mais cette boucle fonctionne
		var newe = J('#z_rech_obs_3 > div');
		if (newe) {
			for (var i=0; i<newe.length; i++) {
				if (newe[i].id == 'ru'+obj.id) {
					log(newe[i].id);
					J(newe[i]).draggable({
						revert: true,
						containment: '#z_recherche_observateurs',
						scroll: false,
						appendTo: '#z_recherche_observateurs',
						helper: 'clone'
					});
					break;
				} 	
			}
		};
		return true;
	}

	this.retire_observateur = function (id) {
		var t2 = Array();
		var n_dep = this.liste.length;
		for (var i=0;i<this.liste.length; i++) {
			if (this.liste[i].id != id) {
				t2.push(this.liste[i]);
			}
		}
		this.liste = t2;

		// le sélecteur #z_rech_obs_3 #ruID ne fonctionne pas sur IE7
		// mais cette boucle fonctionne
		var elems = J('#z_rech_obs_3 > div');
		if (elems) {
			for (var i=0; i<elems.length; i++) {
				if (elems[i].id == 'ru'+id) {
					J(elems[i]).remove();
					break;
				}
			}
		}
		return (this.liste.length < n_dep);
	}

	this.query = function (s) {
		if (s.length > 2) {
			// abandonne la requête précédente au besoin
			if (this.currentXHR) {
				// http://www.w3.org/TR/XMLHttpRequest/#the-xmlhttprequest-interface
				// au dessous de 4 la requête n'est pas terminée
				if (this.currentXHR.readyState < 4) {
					this.currentXHR.abort();
				}
			}
			var url = 'index.php?'+J.param({term: s, t: 'observateur_autocomplete2'});
			J('#z_rech_obs_2').html('recherche en cours');
			this.currentXHR = J.ajax({url: url, async: true, complete: function (xhr,txt) {
				var data = J.parseJSON(xhr.responseText);
				J('#z_rech_obs_2').html('');
				for (var i=0; i < data.length; i++) {
					// 
					J('#z_rech_obs_2').append('<div class="ele_recherche_observateur" style="background-color:white;" id="ru'+data[i].id+'">'+data[i].label+'</div>');
				}
				J('.ele_recherche_observateur').draggable({
					revert:true,
					containment:'#z_recherche_observateurs',
					scroll:false, 
					appendTo:'#z_recherche_observateurs',
					helper: 'clone'
				});
			}});
		}
	}

	// création des zones de dépose
	var z_liste = J('#z_rech_obs_3');
	var z_drop = J('#z_rech_obs_4');
	z_liste.html('');
	z_liste.data('obj', this);
	z_drop.data('obj', this);
	z_liste.droppable({
		drop: function (e, ui) {
			if (!e.srcElement) e.srcElement = e.originalTarget;
			if (!e.srcElement) e.srcElement = e.target;
			console.log(e);
			var obs = new Observateur(e.srcElement.id.replace(/^ru/,''), J(e.srcElement).html());
			var boite = J(this).data('obj');
			boite.ajoute_observateur(obs);
			J(e.srcElement).remove();
			if (!J.browser.msie)
				J(this).effect('highlight');
		}
	});
	z_drop.droppable({
		drop: function (e, ui) {
			log('depose');
			if (!e.srcElement) e.srcElement = e.originalTarget;
			if (!e.srcElement) e.srcElement = e.target;
			if (!J.browser.msie)
				J(this).effect('highlight');
			var boite = J(this).data('obj');
			var id = e.srcElement.id.replace(/^ru/,'');
			if (!boite.retire_observateur(id)) {
				log('observateur pas retiré...');
				log(e.srcElement);
			}
			J(e.srcElement).remove(); //supprime le clone
			log('fin depose');
		}
	});

	// chargement de la liste des observateurs proches
	var url = 'index.php?'+J.param({t: 'observateurs_proche'});
	J('#z_rech_obs_1').html('recherche en cours');
	xhr = J.ajax({url: url, async: false});
	var data = J.parseJSON(xhr.responseText);
	J('#z_rech_obs_1').html('');
	for (var i=0; i < data.length; i++) {
		J('#z_rech_obs_1').append('<div class="ele_recherche_observateur" style="background-color:white;" id="ru'+data[i].id+'">'+data[i].label+'</div>');
	}
	J('.ele_recherche_observateur').draggable({
		revert:true,
		containment:'#z_recherche_observateurs',
		scroll:false,
		appendTo:'#z_recherche_observateurs',
		helper: 'clone'}
	);

	// active bouton annuler
	J('#z_recherche_observateurs_fermer').unbind('click');
	J('#z_recherche_observateurs_fermer').click(
		function () {
			J('#z_recherche_observateurs').hide();
		}
	);

	// active bouton valider
	J('#z_recherche_observateurs_valider').data('obj', this);
	J('#z_recherche_observateurs_valider').unbind('click');
	J('#z_recherche_observateurs_valider').click(
		function (e) {
			var boite = J(this).data('obj');
			boite.modifie_liste_initiale();
			J('#z_recherche_observateurs').hide();
		}
	);

	// active bouton precedent
	J('#z_recherche_observateurs_precedents').data('obj', this);
	J('#z_recherche_observateurs_precedents').unbind('click');
	J('#z_recherche_observateurs_precedents').click(
		function (e) {
			var boite = J(this).data('obj');
			boite.charge_liste_precedente();
		}
	);

	// active la recherche sur la zone de saisie
	J('#z_rech_obs_2').html(''); // efface les résultats d'une précédente recherche
	var champ_saisie = J('#z_recherche_observateurs_in');
	champ_saisie.data('obj', this);
	champ_saisie.unbind('keyup');
	champ_saisie.keyup(
		function (e) {
			var brecherche = J(e.currentTarget).data('obj');
			brecherche.query(e.currentTarget.value);
		}
	);
	champ_saisie.val(''); // vide le champ au cas où il ne serai pas vide	
	
	// ouvre la "fenêtre"
	this.charge_liste_initiale();

	J('#z_recherche_observateurs').show();
	champ_saisie.focus();
}
</script>
{/literal}

<div class="boite_dialogue" id="z_recherche_observateurs">
	<h1>Constituer une liste d'observateurs</h1>
	<div style="width:250px; height:400px;float:left;">
		Derniers observateurs associés
		<div id="z_rech_obs_1"></div>
	</div>
	<div style="width:250px; height:400px;float:left;">
		Rechercher : <input type="text" id="z_recherche_observateurs_in"/>
		<div id="z_rech_obs_2" style="height:380px; width:250px; overflow:auto;">
		</div>
	</div>
	<div style="width:250px; height:400px;float:left;">
		Dans la liste
		<div id="z_rech_obs_3" style="height:300px; overflow:auto; border-style:solid; border-width:1px;">
			<div class="cacher_moi" style="padding:40px; padding-top:60px; text-align:center; font-size: 22px; color: #bbb;">
				<i>déposer ici les noms des observateurs</i>
			</div>
		</div>
		<div id="z_rech_obs_4" style="margin-top: 5px; padding-top: 5px; height:60px; overflow:auto; border-style:solid; border-width:1px;">
			<div style="z-index:-1; text-align:center; font-size: 18px; color: #bbb;">
				<i>déposer ici <br/>les observateurs a retirer</i>
			</div>
		</div>

	</div>
	<div style="clear:both;"></div>
	<div style="float:left;"><a href="javascript:;" id="z_recherche_observateurs_precedents">Charger la liste précédente</a></div>
	<div style="text-align:right;">
		<a href="javascript:;" id="z_recherche_observateurs_fermer">Annuler</a>
		<a href="javascript:;" id="z_recherche_observateurs_valider">Valider</a>
	</div>
	<div style="clear:both;"></div>
</div>
