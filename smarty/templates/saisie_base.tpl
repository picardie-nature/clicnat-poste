{include file="poste_head.tpl" titre_page="Saisie"}
{include file="partiels/recherche_tag.tpl"}
<!--
<script src="http://deco.picardie-nature.org/prototype/prototype.js" language="javascript"></script>
<script src="http://deco.picardie-nature.org/scriptaculous/effects.js" language="javascript"></script>
<script src="http://deco.picardie-nature.org/scriptaculous/controls.js" language="javascript"></script>
-->
<style>
	{literal}
		.informal {
			font-size: smaller;
		}
		#bobs-nouveau-commentaire {
			width: 100%;
			height: 100%;
		}
		.bobs-commtr-obs {
			padding: 10px;
			font-size: 12px;
			margin: 2px;
			background-color: white;
		}
		.hidden {
			display: none !important;
			visibility: hidden !important;
		}
	{/literal}
</style>
{include file="partiels/choix_structures.tpl" structures=$s}
{include file="partiels/choix_protocoles.tpl" protocoles=$p}
<div>
	<h1 style="display:inline;">Observation</h1>
	<span>#{$observation->id_observation}</span>
	<div style="float:right;">	    
	    <a style="float:right;" id="valobs">Envoyer l'observation</a>
	    <a style="float:right;" id="supprobs">Supprimer</a>
	    <a style="float:right;" id="duplobs">Cloner</a>
	    <a style="float:right;" id="cstruct">Structures</a>
	    <a style="float:right;" id="cproto">Protocole</a>
	</div>
	<table width="100%">
		<tr>
			<td valign="top" width="50%">
				<p class="directive">Commune(s)</p>
				<p class="valeur">
					{assign var='espace' value=$observation->get_espace()}
					{foreach from=$espace->get_communes() item=com}
						{$com->nom}
					{/foreach}
				</p>
				<p class="directive">Date d'observation</p>
				<p class="valeur">{$observation->date_obs_tstamp|date_format:"%d-%m-%Y"}</p>
				<p class="directive">Heure d'observation</p>
				<p class="valeur" id="bobs-sb-heure-obs">{$observation->heure_observation}</p>
				<p class="directive">Durée d'observation</p>
				<p class="valeur" id="bobs-sb-duree-obs">{$observation->duree_observation}</p>
				<span id="bobs-sb-hd-btn">Précisions horaires</span>
				<span id="bobs-comtr-add-btn">Ajouter un commentaire</span>
				<div id="bobs-commentaires"></div>
				<div class="hidden">
					<div title="Ajouter un commentaire"  id="bobs-ajout-commentaire">
						<textarea id="bobs-nouveau-commentaire"></textarea>
					</div>
				</div>
			</td>
			<td valign="top" width="50%">
				<h2 style="margin:0px;">Observateurs</h2>
				<ul id="bobs-liste-observateurs" class="bobs-liste">
					{include file='saisie_citation_observ.tpl' var=$observation}
				</ul>
				<input type="text" id="bobs-observateur-nom" name="nom" size="20" placeholder="ajouter un observateur"/>
			</td>
		</tr>
		<tr>
			<td colspan="2" valign="top">
				<h2 style="margin:0px;">Nouvelle citation</h2>
				<input type="text" name="espece" id="espece" size="50" placeholder="ajouter une espèce"/>
				{if $install == "picnat"}
				<a href="http://www.picardie-nature.org/spip.php?article1448" target="_blank">
					en savoir plus sur les espèces disponibles à la saisie
				</a>
				{/if}
				<br/>
				<small>Entrez les noms des espèces que vous avez observées</small>
				<span id="statut_recherche_esp"></span>
				<span id="recherche_en_cours">recherche en cours</span>
			</td>
		</tr>
	</table>

	<h2 style="margin:0px;">Citations</h2>

	<ul id="bobs-saisie-citations">
		{foreach from=$observation->get_citations_ids() item=id}
			{assign var='citation' value=$observation->get_citation($id)}
			<li>{include file="saisie_citation.tpl" citation=$citation}</li>
		{/foreach}
	</ul>
</div>
<div style="display:none;">
	<div id="divedit" title="Éditer une citation">
		<div id="divedit_contenu"></div>
	</div>
	<div id="bobs-sb-dialog-so" title="Supprimer l'observation">
		<p>
			Vous allez supprimer l'observation et ses citations 
			associées.
		</p>
	</div>
	<div id="bobs-sb-dialog-hd" title="Heure et durée d'observation">
	    <form id="bobs-sb-dialog-hd-f" onSubmit="javascript:return false;">
		<input type="hidden" name="oid" value="{$observation->id_observation}"/>
		<p class="directive">Heure d'observation H-M-S</p>
		<p class="valeur">
		    {assign var=h value=$observation->get_heure()}
		    {if $h}
			{assign var=vh value=$h->get_h()}
			{assign var=vm value=$h->get_m()}
			{assign var=vs value=$h->get_s()}
		    {/if}
		    <input id="bobs-sb-dialog-hd-h-h" type="text" style="text-align:center;" name="h_h" size="2" maxlength="2" value="{$vh}"/>h
		    <input id="bobs-sb-dialog-hd-h-m" type="text" style="text-align:center;" name="h_m" size="2" maxlength="2" value="{$vm}"/>m
		    <input type="text" name="h_s" size="2" maxlength="2" style="text-align:center;" value="{$vs}"/>s
		</p>
		<p id="bobs-slider-h-h"></p>
		<p id="bobs-slider-h-m"></p>
		<p class="directive">Durée d'observation H-M-S</p>
		<p class="valeur">
		    {assign var=h value=$observation->get_duree()}
		    {if $h}
			{assign var=vh value=$h->get_h()}
			{assign var=vm value=$h->get_m()}
			{assign var=vs value=$h->get_s()}
		    {/if}
		    <input id="bobs-sb-dialog-hd-d-h" type="text" name="d_h" size="2" maxlength="2" style="text-align:center;" value="{$vh}"/>h
		    <input id="bobs-sb-dialog-hd-d-m" type="text" name="d_m" size="2" maxlength="2" style="text-align:center;" value="{$vm}"/>m
		    <input type="text" name="d_s" size="2" maxlength="2" style="text-align:center;" style="text-align:center;"/>s
		</p>
		<p id="bobs-slider-d-h"></p>
		<p id="bobs-slider-d-m"></p>
	    </form>
	</div>
	 <div id="bobs-dupl-diag" title="Dupliquer cette observation">
		<small>Une nouvelle observation sera créée pour ce même lieu, avec les mêmes
		observateurs et les mêmes espèces. Il vous reste a indiquer la date
		et a compléter les effectifs et codes comportement.</small>

		<p class="directive">Nouvelle date :</p>
		<input type="text" size="10" id="bobs-dupl-date"/>
		<input type="hidden" id="bobs-dupl-obs" value="{$observation->id_observation}"/>
	 </div>
	 <div id="bobs-cit-upload" title="Joindre un document">
		<form  enctype="multipart/form-data" method="post" action="?t=citation_attache_doc">
			<input type="hidden" name="id" id="upload-id-citation"/>
			<input type="hidden" name="url_retour" id="upload-url-retour" value=""/>
			<input type="hidden" name="MAX_FILE_SIZE" value="30000000" />
			Joindre ce fichier : <input name="f" type="file" />
			<input type="submit" value="Envoyer"/>
		</form>
		<h3>Images en attente</h3>
		{foreach from=$u->inbox_docs() item=d}
			{assign var=doc value=$d.doc}
			{if $doc->get_type() eq "image"} 
			<form method="post" action="?t=citation_attache_doc_inbox">
				<img src="?t=img&id={$doc->get_doc_id()}&w=280">
				<input type="hidden" name="id" class="input_id_citation" value="{$doc->get_type()}">
				<input type="hidden" name="doc_id" value="{$doc->get_doc_id()}">
				<input type="hidden" name="url_retour" class="input_url_retour" value="">
				<input type="submit" value="ajouter la photo ci-dessus">
			</form>
			{/if}
		{foreachelse}
			Pas de photo en attente
		{/foreach}
	 </div>
</div>
<script language="javascript">
		var id_observation = {$observation->id_observation};
		var affiche_expert = "";
		{if $u->expert}affiche_expert="&affiche_expert=1";{/if}
//{literal}
		function actualiser_commentaires() {
			J('#bobs-commentaires').load('?'+J.param({t:'json',a:'observation_commentaires',id_observation:id_observation}));
		}

		function rechercher_code_comportement_cback(id_tag) {
			var citation = J('#cid').val();
			var url = '?t=json&a=ajouter_tag_citation&cid='+citation+'&tid='+id_tag;
			J.ajax({ url: url, success: function (data, textStatus, jqXHR) {maj_liste_code_comportement();} });
		}

		function retirer_code_comportement_editeur(id_tag) {
			var citation = J('#cid').val();
			var url = '?t=json&a=supprimer_tag_citation&cid='+citation+'&tid='+id_tag;
			J.ajax({ url: url, success: function (data, textStatus, jqXHR) {maj_liste_code_comportement();} });
		}

		// met a jour la liste des codes comportements utilisé dans l'éditeur
		function maj_liste_code_comportement() {
			var citation = J('#cid').val();
			J("#cc_z_statut").load('?t=saisie_citation_editeur_tags&id='+citation);
		}

		function rechercher_code_comportement() {
			var b = new BoiteRechercheTag(rechercher_code_comportement_cback);
			var z = J('[role="dialog"]').css('z-index');
			J('#'+b.div_id).css('z-index',z+1);
		}

		function ajouter_photo(id_citation,id_observation) {
			J('#upload-id-citation').val(id_citation);
			J('.input_id_citation').val(id_citation);
			J('.input_url_retour').val('?t=saisie_base&id='+id_observation);
			J('#upload-url-retour').val('?t=saisie_base&id='+id_observation);
			J('#bobs-cit-upload').dialog();
		}
		
		function obs_cloner() {
			if (J('#bobs-dupl-date').val().length == 10) {
				document.location.href='?t=saisie_dupliquer&date='+J('#bobs-dupl-date').val()+'&id='+J('#bobs-dupl-obs').val();
			} else {
				alert('date invalide')
			}
		}
	    
		function diag_obs_cloner() {
			J('#bobs-dupl-date').datepicker();
			J('#bobs-dupl-diag').dialog({buttons: {"Dupliquer": obs_cloner}});
		}

		{/literal}
		var btn_id_observation = {$observation->id_observation};
		var btn_masque = '{$masque}';
		{literal}
		J('#supprobs').button();
		J('#supprobs').click(function () { supprimer_observation(btn_id_observation); });
		J('#valobs').button();
		J('#valobs').click(function () { valider_observation(btn_id_observation, btn_masque); });
		J('#duplobs').button();
		J('#duplobs').click(function () { diag_obs_cloner();});
		J('#bobs-sb-hd-btn').button();
		J('#bobs-sb-hd-btn').click(function () { dialog_heure_duree(); });
		
		// Bouton ajouter un commentaire
		J('#bobs-comtr-add-btn').button();
		J('#bobs-comtr-add-btn').click(function () { 
			J('#bobs-ajout-commentaire').dialog({
				buttons: {
					"Ajouter": function () {
						var commentaire = J('#bobs-nouveau-commentaire').val();
						J('#bobs-commentaires').load('?'+J.param({
							t:'json',
							a:'observation_commentaires',
							id_observation:id_observation,
							ajouter_commentaire: commentaire
						}));
					},
					"Annuler": function () {
						J(this).dialog('close');
					}
				},
				modal: true
			});
		});

		J('#cstruct').button();
		J('#cstruct').click(function () { new BoiteChoixStructure(); });
		J('#cproto').button();
		J('#cproto').click(function () { new BoiteChoixProtocole(); });

		J('#divedit').dialog({
			autoOpen: false,
			minWidth: 500,
			width: 500,
			buttons: { 
				"Supprimer": function() {
					if (confirm("Confirmer la suppression")) {
						var id_citation = J('#cid').val();
						supprimer_citation(id_citation);
						//J($('citation'+id_citation).parentNode).slideUp();
						J(this).dialog('close');
					}
				},
				"Enregistrer": function() {
					var id_citation = J('#cid').val();
					if (!enregistre_formulaire_eff_age_sex()) {
						return false;
					}
					enregistre_formulaire_commentaire();
					enregistre_formulaire_enquete(id_citation);
					J(this).dialog('close'); 
					J('#citation'+id_citation).parent().html("actualisation...").load('?t=saisie_citation&cid='+id_citation+'&oid={/literal}{$observation->id_observation}{literal}');
				}
			}
		});
		J('#recherche_en_cours').hide();

		function dialog_heure_duree() {
		    log('ouvre boite heure duree');
		    J('#bobs-sb-dialog-hd').dialog({
			modal: true,
			async: false,
			buttons: {
			    "Enregistrer": function() {
				enregistre_heure_duree();
				J(this).dialog('close');
			    },
			    "Annuler": function() {
				J(this).dialog('close');
			    }
			}});
		    J('#bobs-slider-h-h').slider({
			min: 0,
			max: 23,
			range: "min",
			slide: function(event, ui) {
			    J('#bobs-sb-dialog-hd-h-h').val(ui.value);
			}
		    });
		    J('#bobs-slider-h-m').slider({
			min: 0,
			max: 59,
			step: 5,
			range: "min",
			slide: function(event, ui) {
			    var r = ui.value;
			    if (r > 59) r = 59;
			    J('#bobs-sb-dialog-hd-h-m').val(r);
			}
		    });
		    J('#bobs-slider-d-h').slider({
			min: 0,
			max: 23,
			range: "min",
			slide: function(event, ui) {
			    J('#bobs-sb-dialog-hd-d-h').val(ui.value);
			}
		    });
		    J('#bobs-slider-d-m').slider({
			min: 0,
			max: 59,
			range: "min",
			step: 5,
			slide: function(event, ui) {
			    var r = ui.value;
			    if (r > 59) r = 59;
			    J('#bobs-sb-dialog-hd-d-m').val(ui.value);
			}
		    });
		}

		function enregistre_heure_duree() {
		    log("enregistre heure et durée de l'observation");
		    var s = J('#bobs-sb-dialog-hd-f').serialize();
		    J.ajax({
			url: '?t=json&a=observation_heure_duree&'+s,
			success: function (data, texte, req) {
			    if (data.match(/^OK/)) {
				document.location.href = '?t=saisie_base&id={/literal}{$observation->id_observation}{literal}';
			    } else {
				alert('Erreur');
			    }
			}
		    });
		}

		function enregistre_formulaire_eff_age_sex() {
			log("enregistre la premiere partie du formulaire");
			var s = J('#bobs-saisie-ed-f-p1').serialize();
			var eff = J('#effectif').val();
			if ( eff == 0 || eff == '') { // avertissement effectif vide ou = 0
				if (!J('#nb_min').val().length > 0) // test s'il y a une fourchette
					if (!confirm("Vous n'avez pas saisi d'effectif, valider quand même ?"))
						return false;
			}
			J.ajax({
				async: false,
				url:'?t=json&a=citation_formulaire_part1&'+s,
				success: function (data,texte,req) { 
					if (data.match(/^\d+/))
						J('#bobs-saisie-ed-f-p').html("enregistrement terminé");
					else
						J('#bobs-saisie-ed-f-p').html("erreur d'enregistrement !");
				},
				error: function (req,text,err) { 
					J('#bobs-saisie-ed-f-p').html(err); 
					return false;
				}
			});
			return true;
		}

		function enregistre_formulaire_commentaire() {
			log("enregistre la partie commentaire du formulaire");
			var s = J('#bobs-saisie-ed-c-p1').serialize();
			J.ajax({
				url:'?t=json&a=citation_formulaire_commentaire&'+s,
				success: function (data,texte,req) { 
					if (data.match(/^\d+/))
						J('#bobs-saisie-ed-c-p').html("enregistrement terminé");
					else
						J('#bobs-saisie-ed-c-p').html("erreur d'enregistrement !");
				},
				async: false,
				error: function (req,text,err) { J('#bobs-saisie-ed-c-p').html(err); }
			});
		}

		function enregistre_formulaire_enquete(id_citation) {
			var div_enquete = J('#clicnat_enquete');
			var divs_valeurs = J('#clicnat_enquete > div.valeur');
			var params = {};
			params['id_citation'] = id_citation;
			params['id_enquete'] = div_enquete.attr('id_enquete');
			params['version'] = div_enquete.attr('version');
			for (var i=0; i<divs_valeurs.length; i++) {
				var div = J(divs_valeurs[i]);
				var enfants = div.children();
				for (var j=0; j<enfants.length; j++) {
					var e = J(enfants[j]);
					if (e.attr('name')) {
						if (e.attr('type') == 'checkbox') {
							if (e.is(':checked')) params[e.attr('name')] = 1;
							else params[e.attr('name')] = 0;
						} else {
							params[e.attr('name')] = e.val();
						}
					}
				}
			}
			params['t'] = 'json';
			params['a'] = 'citation_formulaire_enquete';
			J.ajax({
				url:'?'+J.param(params),
				success: function (data,texte,req) { 
					if (!data.match(/^\d+/))
						alert('problème enregistrement données enquête');
				},
				async: false,
				error: function (req,text,err) { J('#bobs-saisie-ed-c-p').html(err); }
			});
		}

		function enregistre_citation_tag(citation,tag,elem) {
			log('enregistre citation tag '+citation+' / '+tag+' / '+elem.checked);
			var url;
			if (elem.checked)
				url = '?t=json&a=ajouter_tag_citation&cid='+citation+'&tid='+tag;
			else
				url = '?t=json&a=supprimer_tag_citation&cid='+citation+'&tid='+tag;

			J.ajax({ url: url });
		}

		function editer(id) {
			log('editer '+id);
			effectif_a_enregistrer = false;
			J('#divedit').dialog({width: 600, height: 600});
			J('#divedit').dialog('open');
			J('#divedit_contenu').html('Chargement en cours');
			J('#divedit_contenu').load('?t=saisie_citation_editeur&id='+id, function () {
				J('#bobs-saisie-ed-acc').accordion();
				maj_liste_code_comportement();
			});
		}

		function charge_citation(id_citation) {
			J.ajax({
				url: '?'+J.param({
					t: 'saisie_citation',
					cid: id_citation,
					oid: '{/literal}{$observation->id_observation}{literal}'
				}),
				success: function (data, txtStatus, xhr) {
					var nouvelle_citation = J("<li>");
					nouvelle_citation.html(data);
					J('#bobs-saisie-citations').append(nouvelle_citation);
				}
			});
		}

		function supprimer_citation_cb(evt) {
			var id = 'cf'+parseInt(evt.responseText);
			var tforms = document.getElementsByTagName("form");
			for (var i=0; i<tforms.length; i++) {
				if (tforms[i].name == id) {
					log('supprimer formulaire pour '+id);
					tforms[i].parentNode.hide();
					tforms[i].parentNode.removeChild(tforms[i]);
					break;
				}
			}
		}

		function supprimer_citation(id_citation) {
			J.ajax({
				url: '?'+J.param({
					t: 'json',
					a: 'supprimer_citation',
					cid: id_citation
				}),
				success: function (data, txtStatus, xhr) {
					var c = J('#citation'+id_citation).parent();
					c.hide();
					c.detach();
				}
			});
		}
		
		function supprimer_observation(id_observation) {
			diag = J('#bobs-sb-dialog-so');
			diag.attr('id_observation', id_observation);
			diag.dialog({
				modal: true,
				buttons: {
					'Supprimer': function () { 
						J.ajax({
							url: '?'+J.param({
								t: 'json',
								a: 'supprimer_observation',
								oid: J(this).attr('id_observation')
							}),
							success: function (data, txtStatus, xhr) {
								document.location.href = '?t=saisie';
							}
						});
					},
					'Annuler': function() {
						J(this).dialog('close');
					}
				}
			});
		}

		function valider_observation(id_observation, masque) {
			log('valider_observation '+id_observation);
			if (confirm("Envoyer votre observation pour validation"))
			J.ajax({
				async: false,
				url:'?t=json&a=observation_valider&oid='+id_observation,
				success: function (data,texte,req) { 
					if (data.match(/^OK/)) {
						document.location.href = '?t='+masque;
					} else {
						alert('Erreur validation impossible');
					}
				},
				error: function (req,text,err) { J('#bobs-saisie-ed-f-p').html(err); }
			});
		}
 

		function supprimer_observateur(id_utilisateur) {
			if (confirm("Supprimer l'observateur de cette liste")) {
				J.ajax({
					url: '?'+J.param({
						t: 'json',
						a: 'observation_supprime_observateur',
						id: id_observation,
						id_observateur: id_utilisateur
					}),
					dataType: 'json',
					success: function (data, textStatus, xhr) {
						if (data.err) {
							alert("Ne peut pas retirer l'utilisateur");
						} else {
							afficher_liste_observateurs(data.observateurs);
						}
					}
				});
			}
		}

		function afficher_liste_observateurs(observateurs) {
			var liste = J('#bobs-liste-observateurs');
			liste.html("");
			J.each(observateurs, function (n,u) {
				var a = document.createElement("a");
				var li = document.createElement("li");
				a.href = "javascript:supprimer_observateur("+u.id_utilisateur+");";
				a.appendChild(document.createTextNode(u.nom+" "+u.prenom));
				li.appendChild(a);
				liste.append(li);
			});
		}

		J('#espece').autocomplete({
			source: '?t=autocomplete_espece'+affiche_expert,
			select: function (event,ui) {
				J.ajax({
					url: '?t=json&a=creer_citation&id='+ui.item.value+'&oid={/literal}{$observation->id_observation}{literal}',
					success: function (data, txtStatus, xhr) {
						if (!data.match(/^\d+/)) {
							alert(r.responseText);
							return;
						}
						charge_citation(data);
						editer(data);
						J('#statut_recherche_esp').html('.');
						J('#espece').val('');
					}
				});
				J(this).val('');
				return false;
			}
		}).data("ui-autocomplete")._renderItem = function (ul,item) {
			return J("<li>").append("<a>"+item.label+"</a>").appendTo(ul);
		};

		J('#bobs-observateur-nom').autocomplete({
			source: '?t=observateur_autocomplete2',
			select: function (event,ui) {
				J(this).val('');
				J.ajax({
					url: '?'+J.param({
						t: 'json',
						a: 'observation_ajoute_observateur',
						id: id_observation,
						id_observateur: ui.item.id
					}),
					dataType: 'json',
					success: function (data, textStatus, xhr) {
						if (data.err) {
							alert('Erreur ajout observateur, peut être déjà présent dans la liste');
						} else {
							afficher_liste_observateurs(data.observateurs);
						}
					}
				});
				event.target.value = '';
				return false;
			}
		});

		actualiser_commentaires();
	{/literal}
</script>

<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
