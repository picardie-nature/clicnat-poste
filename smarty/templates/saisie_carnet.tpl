{include file="poste_head.tpl" titre_page="Saisie - Carnet"}
{include file="partiels/recherche_observateurs.tpl"}
{include file="partiels/recherche_tag.tpl"}
{literal}
<style>
	#cartouche, #citations {
		background-color: black;
		color: white;
		font-size: 12px;
	}

	#citations {
		background-color: #444;
		min-height: 750px;
	}
	.cartouche-bloc {
		float:left;
		padding: 10px;
	}
	.observateur, #observateur_btn_modifier, #liste_observateurs li {
		float:left;
		padding: 5px;
		margin: 5px;
		background-color: #ccc;
		color: black;
	}
	#observateur_btn_modifier {
		cursor: pointer;
	}

	#liste_observateurs {
		list-style-type: none;

	}

	#observateur_btn_modifier {
		background-color: white;
	}

	.c {
		float: left;
		text-align: center;
	}
	.c_espece { width: 20%; }
	.c_effectif { width: 15%; }
	.c_comportement { width: 32%; text-align:left; }
	.c_commentaire { width: 32%; }


	.citation {
		clear: both;
		padding-bottom: 10px;
	}
	.tag {
		display: inline-block;
		float: none;
		background-color: #ccc;
		color: black;
		cursor: pointer;
		padding: 1px;
		margin: 5px;
		clear: left;
	}

	.tag_utilise {
		background-color: rgb(100,200,100);
	}
	.tag:hover {
		background-color:white;
	}
</style>
<script>
function clicnat_get_obj(data) {
	var xhr = J.ajax({url: '?'+J.param(data), async:false});
	var obj = J.parseJSON(xhr.responseText);
	if (obj.err != undefined) {
		alert(obj.message);
		return undefined;
	}
	return obj;
}

function clicnat_date_str(date_str) {
	var date = new Date(date_str);
	return date.toLocaleDateString();
}

function Observation(id_observation) {
	var data = {t:'json', a:'observation', id: id_observation};
	var obj = clicnat_get_obj(data);
	
	this.id_observation = obj.id_observation;
	this.id_utilisateur = obj.id_utilisateur;
	this.date_observation = obj.date_observation;
	this.heure_observation = obj.heure_observation;
	this.duree_observation = obj.duree_observation;
	this.brouillard = obj.brouillard;
	this.localisation = obj.localisation;
	this.observateurs = obj.observateurs;
	this.citations_ids = obj.citations_ids;
	
	this.citations = undefined;
	this.citations_load = false;

	this.get_citations = function () {
		this.citations = new Array();
		for (var i=0; i<this.citations_ids.length; i++) {
			data = {t:'json', a:'citation', id:this.citations_ids[i]};
			this.citations.push(clicnat_get_obj(data));
		}
		this.citations_load = true;
		return this.citations;
	}
}

function Tag(id_tag) {
	var data = {t:'json', a:'tag', id: id_tag};
	var obj = clicnat_get_obj(data);
	this.id_tag = obj.id_tag;
	this.parent_id = obj.parent_id;
	this.lib = obj.lib;
	this.ref = obj.ref;
	this.a_chaine = obj.a_chaine;
	this.a_entier = obj.a_entier;
	this.categorie_simple = obj.categorie_simple;
}

function Carnet(id_observation, active_debug) {
	this.debug = function (msg) {
		if (this.enable_debug)
			log('Carnet: '+msg);
	}

	this.chargement = function (id_observation) {
		this.debug('début chargement observation '+id_observation);
		this.observation = new Observation(id_observation);
		log(this.observation);
		J('#id_observation').html(this.observation.id_observation);
		var d_str = clicnat_date_str(this.observation.date_observation);
		J('#date_observation').html(d_str);
		J('#localisation').html(this.observation.localisation);
		J('#heure').html(this.observation.heure_observation);
		J('#duree').html(this.observation.duree_observation);

		this.observateurs_clear();
		for (var i=0; i<this.observation.observateurs.length; i++) {
			this.observateur_ajoute(this.observation.observateurs[i]);
		}

		this.citations_clear();
		this.tags = Array();

		var citations = this.observation.get_citations();
		for (var i=0;i<citations.length;i++) {
			this.citation_ajoute(citations[i]);
			
			var doit_ajouter;
			for (var j=0; j<citations[i].tags.length; j++) {
				doit_ajouter=true;
				for (var k=0; k<this.tags.length; k++) {
					if (this.tags[k].id_tag == citations[i].tags[j].id_tag) {
						doit_ajouter=false;;
						break;
					}
				}
				if (doit_ajouter) {
					this.tags.push(citations[i].tags[j]);
				}
			}
		}
		for (var i=0;i<citations.length;i++) {
			this.affiche_citations_tags(citations[i].id_citation);
		}
	}

	this.citation_a_tag = function (citation, id_tag) {
		for (var i=0;i<citation.tags.length;i++) {
			if (citation.tags[i].id_tag == id_tag)
				return true;
		}
		return false;
	}

	this.affiche_citations_tags = function (id) {
		var divs_citation = J('#citations > .citation');
		var div = false;
		for (var i=0; i<divs_citation.length; i++) {
			if (J(divs_citation[i]).data('citation').id_citation == id) {
				div = J(divs_citation[i]);
			}
		}
		if (div) {
			var div_tag = J(div.children('.c_comportement')[0]);
			div_tag.html('');
			for (var i=0; i<this.tags.length; i++) {
				dtag = document.createElement('div');
				jdtag = J(dtag);
				jdtag.html(this.tags[i].lib.replace(/ /g,'&nbsp;'));
				jdtag.addClass('tag');
				if (this.citation_a_tag(J(div).data('citation'), this.tags[i].id_tag)) {
					jdtag.addClass('tag_utilise');
				}
				div_tag.append(dtag);
			}
		}
	}

	this.observateurs_clear = function () {
		J('#observateurs li').remove();
	}

	this.observateurs_sauve = function () {
		var obs = J('#observateurs li');
		var data = {observateurs:'',id:this.observation.id_observation, t:'json', a:'observation_set_liste_observateurs'};
		for (var i=0; i<obs.length; i++) {
			if (data.observateurs.length > 0)
				data.observateurs += ',';
			data.observateurs += obs[i].id;
		}
		log(data);
		r = clicnat_get_obj(data);
		log(r);
	}

	this.observateur_ajoute = function (u) {
		var div = document.createElement('li');
		var jdiv = J(div);
		//jdiv.data('utilisateur',u);
		jdiv.attr('id', u.id_utilisateur);
		jdiv.html(u.nom+' '+u.prenom);
		//jdiv.addClass('observateur');
		J('#liste_observateurs').prepend(jdiv);
	}

	this.citations_clear = function () {
		J('#citations > .citation').remove();
	}

	this.citation_ajoute = function (citation) {
		var div = document.createElement('div');
		var jdiv = J(div);
		jdiv.addClass('citation');
		jdiv.data('citation', citation);

		var div_esp = document.createElement('div');
		var jdiv_esp = J(div_esp);
		jdiv_esp.addClass('c');
		jdiv_esp.addClass('c_espece');
		jdiv_esp.html(citation.nom);

		var div_eff = document.createElement('div');
		var jdiv_eff = J(div_eff);
		jdiv_eff.addClass('c');
		jdiv_eff.addClass('c_effectif');
		jdiv_eff.html('x');

		var div_comp = document.createElement('div');
		var jdiv_comp = J(div_comp);
		jdiv_comp.addClass('c');
		jdiv_comp.addClass('c_comportement');
		jdiv_comp.html('...');

		jdiv.append(div_esp);
		jdiv.append(div_eff);
		jdiv.append(div_comp);

		jdiv.append('<div style="clear:both;"></div>');
		J('#citations').append(div);
	}

	this.enable_debug = active_debug;
	this.chargement(id_observation);

	// activation bouton modifier liste observateur
	J('#observateur_btn_modifier').click(function () {
		new BoiteRechercheObservateurs('liste_observateurs');
	});

	// raccourcis clavier
	J(document).keyup(
		function (e) {
			if (ctrl) {
				switch (e.which) {
					case 79: // ctrl et o
						new BoiteRechercheObservateurs('liste_observateurs');
						break;
					case 84: // ctrl et t
						new BoiteRechercheTag(cback_recherche_tag);
						break;
					case 82: // ctrl et r
						var c = J(document).data('carnet');
						c.chargement(c.observation.id_observation);
						break;
					default:
						log(e.which);
				}
			}
			ctrl = e.which == 17;
		}
	);

	// test evenement
	J(document).data('carnet', this);
	J(document).bind("sauvegarde", function () {
		log('sauvegarde...');
		J(document).data('carnet').observateurs_sauve();
	});

}
function cback_recherche_tag(e) {
	log('tag done '+e);
	var carnet = J(document).data('carnet');
	var doit_inserer = true;
	for (var i=0;i<carnet.tags.length;i++) {
		if (carnet.tags[i].id_tag == e) {
			doit_inserer = false;
			break;
		}
	}
	if (doit_inserer) {
		var data = {t:'json', a:'tag', id:e};
		carnet.tags.push(new Tag(clicnat_get_obj(data)));
		carnet.citations_clear();
		var citations = carnet.observation.get_citations();
		for (var i=0;i<citations.length;i++) { 
			carnet.citation_ajoute(citations[i]);
		}
		for (var i=0;i<citations.length;i++) {
			carnet.affiche_citations_tags(citations[i].id_citation);
		}
	}
}

var ctrl = false;
var carnet = null;

J(document).ready(function () {
	carnet = new Carnet({/literal}{$obs->id_observation}{literal}, true);
});

</script>
{/literal}
<div id="cartouche">
	<div class="cartouche-bloc">
		Observation<br/>
		<span id="id_observation">&nbsp;</span>
	</div>
	<div class="cartouche-bloc">
		Date<br/>
		<span id="date_observation"></span>
	</div>
	<div class="cartouche-bloc">
		Heure<br/>
		<span id="heure"></span>
	</div>

	<div class="cartouche-bloc">
		Durée<br/>
		<span id="duree"></span>
	</div>
	<div class="cartouche-bloc">
		Localisation<br/>
		<span id="localisation"></span>
	</div>

	<hr style="clear:both;"/>

	<div class="cartouche-bloc">
		Observateurs
	</div>
	
	<div id="observateurs">
		<ul id="liste_observateurs"></ul>
		<div id="observateur_btn_modifier">Modifier</div>
	</div>
	<div style="clear:both;"></div>
</div>

<div id="citations">
	<div class="c_titre">
		<div class="c_espece c">Nom de l'espèce</div>
		<div class="c_effectif c">Effectif</div>
		<div class="c_comportement c">Comportement</div>
		<div class="c_commentaire c">Commentaire</div>
		<div style="clear:both;"></div>
	</div>
	<div class="citation" id="citation_1">
		<div class="c_espece c">Moineau kldfjkld</div>
		<div class="c_effectif c">LKDJFLKDJF</div>
		<div class="c_comportement c">
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
			<div class="tag">en vol</div>
		</div>
		<div class="c_commentaire c">Commentaire</div>
		<div style="clear:both;"></div>
	</div>
	<div style="clear:both;"></div>
</div>
{include file="poste_foot.tpl"}
