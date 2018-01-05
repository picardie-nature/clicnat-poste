{if $peut_voir}
	{assign var=espece value=$citation->get_espece()}
	{assign var=reseau value=$espece->get_reseau()}
	{assign var=observation value=$citation->get_observation()}
	{assign var=d_obs value=$observation->date_observation|date_format:"%A %e %B %Y"}
	{assign var='titre_page' value="Observation de $espece le $d_obs"}
	{if $u}
		{assign var=citation_modif_ok value=$citation->autorise_modification($u->id_utilisateur)}
	{else}
		{assign var=citation_modif_ok value=false}
	{/if}
{else}
	{assign var='titre_page' value='Pas visible'}
{/if}

{include file="poste_head.tpl" useplusone=true title=$titre_page}
{literal}
<style>
.modif {font-size: 12px;}
</style>
<script>
function bascule(a_cacher, a_ouvrir) {
	J('#'+a_cacher).hide();
	J('#'+a_ouvrir).show('blind');
}
function reuse(tbl_espace, id_espace) {
	J('#reuse_dobs').datepicker();
	J('#reuse_dobs').data('table_espace', tbl_espace);
	J('#reuse_dobs').data('id_espace', id_espace);
	J('#reuse_w_dobs').dialog({buttons: { 
		Envoyer:function () {
			var p = {
				t:'json',
				a:'creation_observation',
				'date':J('#reuse_dobs').val(),
				table_espace: J('#reuse_dobs').data('table_espace'),
				id_espace: J('#reuse_dobs').data('id_espace')
			};
			J('#reuse_dobs_info').html('création en cours...');
			xhr = J.ajax({url: '?'+J.param(p), async: false})
			if (xhr.responseText.match(/^\d+/)) {
				J('#reuse_dobs_info').html('<a style="color:blue;" href="?t=saisie_base&id='+xhr.responseText+'">Passer à la saisie de l\'inventaire</a>');
			} else {
				J('#reuse_dobs_info').html('erreur ...');
			}
		},
		Annuler:function () {J(this).dialog('close');}
	}});
}
{/literal}
</script>
{if $peut_voir}
{assign var=espace value=$observation->get_espace()}
<h1>
	<img src="http://obs.picardie-nature.org/image/30x30_g_{$espece->classe|lower}.png"/>
	<a href="?t=espece_detail&id={$espece->id_espece}">{$espece->nom_f} <i>{$espece->nom_s}</i></a>
	{if $citation_modif_ok}<a class="modif" href="javascript:citation_modifier_espece();">modifier</a>{/if}
	<script>
	{literal}
	function citation_modifier_espece() {
		J('#espece').autocomplete({source: '?t=espece_autocomplete2',
			select: function (event,ui) {
				event.target.value = '';
				J('#modif_id_espece').val(ui.item.value);
				J('#nouveau_nom').html(ui.item.label);
				J('#modifier_espece_form').show();
				J('#modifier_espece').hide();
				return false;
			}
		});
		J('#modifier_espece').show();
	}
	{/literal}
	</script>
</h1>
<div id="modifier_espece" style="display:none;">
	Espèce : <input type="text" id="espece"/>
</div>
<div id="modifier_espece_form" style="display:none;">
	<form method="post" action="?t=citation&id={$citation->id_citation}">
		<input type="hidden" name="action" value="modifier"/>
		<input type="hidden" name="champ" value="id_espece"/>
		<input type="hidden" value="" id="modif_id_espece" name="id_espece"/>
		Remplacer {$espece} par <b><span id="nouveau_nom"></span></b>
		<input type="submit" value="enregistrer"/>
	</form>
	<hr/>
</div>
{if $citation->invalide()}
	<span style="color:red; font-weight: bold;">Attention cette citation est notée comme étant invalide !</span><br/>
{/if}
<div id="reuse_w_dobs" style="display:none;" title="Créer une observation">
	Date d'observation : <input type="text" id="reuse_dobs" value=""/>
	<div id="reuse_dobs_info"></div>
</div>
<div style="float:right; padding: 5px; border-color: 2px; max-width:250px;">
	{if $auth_ok}
		<div style="background-color: white; margin:5px; padding: 5px;">
		<b>Accès : </b>
		{if $citation->acces_public()}
			<font color=green>ouverte au public</font><br/>
			Vous pouvez diffuser cette adresse :<br/>
			<input type="text" width="40" value="http://poste.obs.picardie-nature.org/?t=citation&id={$citation->id_citation}"/><br/>
		{else}
			pas ouvert à tous<br/>
		{/if}
		{if $utilisateur_citation_authok}
			{if $citation->acces_public()}
				<form method="post" action="?t=citation&id={$citation->id_citation}">
					<input type="hidden" name="action" value="fermer_a_tous"/>
					<input type="submit" value="Limiter l'accès"/>
				</form>
			{else}
				<form method="post" action="?t=citation&id={$citation->id_citation}">
					<input type="hidden" name="action" value="ouvre_a_tous"/>
					<input type="submit" value="Ouvrir l'accès"/>
				</form>
			{/if}
		{/if}
		</div>
	{else}
		<div style="background-color: white; padding: 5px; margin: 2px; border-style:solid; border-size:1px; border-color:#d90019;">
		<b>Ouvrir une session</b><br/>
		<form method="post" action="?t=accueil">
			<input type="hidden" name="act" value="login"/>
			<input type="hidden" name="redir" value="?t=citation&id={$citation->id_citation}"/>
			Nom d'utilisateur<br/>
			<input type="text" name="username" value=""/><br/>
			Mot de passe<br/>
			<input type="password" name="password" value=""/><br/><br/>
			<input type="submit" value="Envoyer"/>			
		</form>
		</div>
	{/if}

	{if $citation->acces_public()}
		<div style="background-color: white; margin:5px; padding: 5px;">
			<g:plusone></g:plusone>
		</div>
	{/if}

	
	{if $reseau}
	<div style="background-color: white; margin:5px; padding: 5px;">
		<b>Réseau naturaliste</b><br/>Cette espèce fait partie du réseau naturaliste <i>{$reseau}</i><br/>
		{if $reseau->est_coordinateur($u->id_utilisateur)}
			<b>Vous êtes coordinateur du réseau</b><br/>
		{/if}
		{if $citation->autorise_validation($u->id_utilisateur)}
			{if $citation->en_attente_de_validation()}
				<a href="?t=citation&id={$citation->id_citation}&valider=1">Valider l'observation</a><br/>
				<a href="?t=citation&id={$citation->id_citation}&invalider=1">Invalider l'observation</a><br/>
			{else}

				{if $citation->invalide()}
					<a href="?t=citation&id={$citation->id_citation}&revalider=1">Enlever le statut invalide et rendre valide</a><br/>
				{else}
					<a href="?t=citation&id={$citation->id_citation}&invalider=1">Invalider l'observation</a><br/>
				{/if}
			{/if}
		{/if}
	</div>
	{/if}

	{if $auth_ok}
	<div style="background-color: white; margin:5px; padding: 5px;">
		<b>Bêta-test validation</b>
		<div>
			<a href="#" id="btn_beta_validation" id_citation="{$citation->id_citation}">Lancer les tests</a>
		</div>
	</div>
	{/if}
</div>
<table>
	<tr>
		<td valign="top" width="20%"><b>Date d'observation</b></td>
		<td valign="top">
			{$observation->date_observation|date_format:"%A %e %B %Y"}
			<small>
				<a class="modif" href="?t=observation&id_observation={$observation->id_observation}">
					{if $citation_modif_ok}modifier{else}voir observation/inventaire{/if}
				</a>
			</small>
			<br/>
			<small>
				précision de la date : {$observation->precision_date_lib}
			</small>
			{if $observation->brouillard == true}
				<font color="red">observation en cours de saisie</font>
			{/if}
		</td>
	</tr>

	{if $auth_ok}
	<tr>
		<td valign="top"><b>Observateurs</b></td>
		<td valign="top">
			{foreach from=$observation->get_observateurs() item=o}
				{$o.nom} {$o.prenom}<br/>
			{/foreach}
		</td>
	</tr>	
	<tr>
		<td valign="top"><b>Effectif</b></td>
		<td valign="top">
			{if $citation->nb < 0}  
				pas observé - pas trouvé
			{elseif $citation->nb >0}
				{$citation->nb}
			{else}
				inconnu - non renseigné
			{/if}
			{if $citation_modif_ok}
				<script>
				{literal}
					function citation_modifier_effectif() {
						J('#mod_effectif_a').hide();
						J('#mod_effectif').show();
					}
				{/literal}
				</script>
				<a class="modif" href="javascript:citation_modifier_effectif();" id="mod_effectif_a">modifier</a>
				<div id="mod_effectif" style="display:none;">
					<form method="post" action="?t=citation&id={$citation->id_citation}">
						<input type="hidden" name="action" value="modifier"/>
						nouvel effectif : <input type="hidden" name="champ" value="nb"/>
						<input type="text" value="{$citation->nb}" size="5" size="5" name="nb"/>
						<input type="submit" value="enregistrer modification"/>
					</form>
				</div>
			{/if}
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Sexe</b></td>
		<td valign="top">
			{$citation->sexe}
			{if $citation_modif_ok}
				<script>
				{literal}
					function citation_modifier_sexe() {
						J('#mod_sexe_a').hide();
						J('#mod_sexe').show();
					}
				{/literal}
				</script>
				<a class="modif" href="javascript:citation_modifier_sexe();" id="mod_sexe_a">modifier</a>
				<div id="mod_sexe" style="display:none;">
					<form method="post" action="?t=citation&id={$citation->id_citation}">
						<input type="hidden" name="action" value="modifier"/>
						nouveau genre : <input type="hidden" name="champ" value="sexe"/>
						<select name="sexe">
							<option value="?"></option>
						{foreach from=$genres item=sexe}
							<option value="{$sexe.val}" {if $citation->sexe eq $sexe.val}selected=true{/if}>{$sexe.val} {$sexe.lib}</option>
						{/foreach}
						</select>
						<input type="submit" value="enregistrer modification"/>
					</form>
				</div>
			{/if}
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Age</b></td>
		<td valign="top">
			{$citation->age}
			{if $citation_modif_ok}
				<script>
				{literal}
					function citation_modifier_age() {
						J('#mod_age_a').hide();
						J('#mod_age').show();
					}
				{/literal}
				</script>
				<a class="modif" href="javascript:citation_modifier_age();" id="mod_age_a">modifier</a>
				<div id="mod_age" style="display:none;">
					<form method="post" action="?t=citation&id={$citation->id_citation}">
						<input type="hidden" name="action" value="modifier"/>
						nouvel âge : <input type="hidden" name="champ" value="age"/>
						<select name="age">
							<option value="?"></option>
						{foreach from=$ages item=age}
							<option value="{$age.val}" {if $citation->age eq $age.val}selected=true{/if}>{$age.val} {$age.lib}</option>
						{/foreach}
						</select>
						<input type="submit" value="enregistrer modification"/>
					</form>
				</div>
			{/if}

		</td>
	</tr>

	{/if}
	<tr>
		<td valign="top"><b>Lieu d'observation</b></td>
		<td valign="top">
			{if $espace->get_table() == 'espace_polygon'}
				polygone numéro {$espace->id_espace} <i>(mettre en place une carte)</i>
			{/if}
			{if $espace->get_table() == 'espace_point'}
				{$espace}<br/>
				coordonnées GPS - point<br/>
				{if $auth_ok}
					X:{$espace->get_x()} Y:{$espace->get_y()}<br/>
					<a target="_blank" href="http://maps.google.fr/maps?q=@{$espace->get_y()},{$espace->get_x()}">voir le point sur Google Maps</a>	<br/>
					<a href="javascript:reuse('espace_point', {$espace->id_espace});">créer une autre observation à cet endroit</a><br/>
				{else}
					<small>visible uniquement une fois connecté</small><br/>
				{/if}				
				{assign var=commune value=$espace->get_commune()}
				commune : <a target="_blank" href="http://obs.picardie-nature.org/?page=commune&id={$commune->id_espace}">{$commune}</a>
			{/if}
			{if $espace->get_table() == 'espace_chiro'}
				{$espace->nom}<br/>
				commune : {$commune}<br/>
				{if $auth_ok}
					<a href="javascript:reuse('espace_chiro', {$espace->id_espace});">créer une autre observation à cet endroit</a><br/>
				{/if}
			{/if}
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Étiquettes</b><br/><small>(codes comportements, validation...)</small></td>
		<td valign="top">
			{foreach from=$citation->get_tags() item=tag}
				{$tag.lib}<br/>
			{foreachelse}
				Aucune
			{/foreach}
		</td>
	</tr>
	<tr>
		<td valign="top" colspan="2"><b>Niveau de certitude dans l'identification : </b>
			{if $citation->indice_qualite!=''}
				<img src="picnat/niveau_identif_{$citation->indice_qualite}.png" alt="{$citation->indice_qualite}" />			
			{else} 
				?
			{/if}
			{if $citation_modif_ok}
				<script>
				{literal}
					function citation_modifier_certitude() {
						J('#mod_certitude_a').hide();
						J('#mod_certitude').show();
					}
				{/literal}
				</script>
				<a class="modif" href="javascript:citation_modifier_certitude();" id="mod_certitude_a">modifier</a>
				<div id="mod_certitude" style="display:none;">
					<form method="post" action="?t=citation&id={$citation->id_citation}">
						<input type="hidden" name="action" value="modifier"/>
						nouveau niveau de certitude : <input type="hidden" name="champ" value="indice_qualite"/>
						<select name="indice_qualite">
							<option value="4" {if $citation->indice_qualite eq 4}selected=1{/if}>très fort</option>
							<option value="3" {if $citation->indice_qualite eq 3}selected=1{/if}>fort</option>
							<option value="2" {if $citation->indice_qualite eq 2}selected=1{/if}>moyen</option>
							<option value="1" {if $citation->indice_qualite eq 1}selected=1{/if}>faible</option>
						</select>
						<input type="submit" value="enregistrer modification"/>
					</form>
				</div>
			{/if}


		</td>
	</tr>
	<tr>
		<td valign="top"><b>Documents - photos</b></td>
		<td>
			{assign var=n_image value=0}
			{foreach from=$citation->documents_liste() item=d}
				{if $d->get_type() == 'image'}
					{if $auth_ok}					
						<a href="?t=img&id={$d->get_doc_id()}" target="_blank">
							<img src="?t=img&id={$d->get_doc_id()}&w=320"/>
						</a><br/>
					{else}
					     {assign var=n_image value=$n_image+1}
					{/if}
				{else}
					{$d->get_doc_id()}<br/>
				{/if}
				{if $citation_modif_ok}
					<form method="post" action="?t=citation&id={$citation->id_citation}">
						<input type="hidden" name="action" value="modifier"/>
						<input type="hidden" name="champ" value="doc"/>
						<input type="hidden" name="doc_id" value="{$d->get_doc_id()}"/>
						<input type="submit" value="retirer"/>
					</form>
				{/if}
			{foreachelse}
				Pas de document associé
			{/foreach}
			{if !$auth_ok}
				{if $n_image > 0}
					{$n_image} image{if $n_image>1}s{/if}  associée{if $n_image>1}s{/if} (visible une fois connecté)
				{/if}
			{/if}
			<br/>
			{if $utilisateur_citation_authok}
				<a href="javascript:;" id="l_photo" onClick="bascule('l_photo', 'f_photo');">Ajouter une photo</a>
				<div id="f_photo" style="display:none;">
				<form enctype="multipart/form-data" method="post" action="?t=citation_attache_doc">
					<input type="hidden" name="id" value="{$citation->id_citation}"/>
					<input type="hidden" name="url_retour" value="?t=citation&id={$citation->id_citation}"/>
					<input type="hidden" name="MAX_FILE_SIZE" value="300000000" />
					<fieldset>
						<legend>Joindre un fichier </legend>
						<input name="f" type="file" /><br/>
						<input type="submit" value="Envoyer"/><br/>
						<small>Attention, n'envoyez que vos photos associées à cette observation, pas d'autres photos de la même espèce.</small>					
					</fieldset>					
				</form>
				</div>
			{/if}
		</td>
	</tr>	
	<tr>
		<td valign="top"><b>Commentaire principal</b></td>
		<td valign="top">
			{$citation->commentaire}
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Commentaire sur l'observation</b></td>
		<td valign="top">
			<table>
				{assign var=observation value=$citation->get_observation()}
				{foreach from=$observation->get_commentaires() item=c}
					<tr>
						<td valign="top">
							{if $c->type_commentaire == 'info'}
								<img src="icones/friends.png"/>
							{elseif $c->type_commentaire == 'attr'}
								<img src="icones/tools.png"/>
							{/if}
						</td>
						<td valign="top" width="60%" style="background-color:white;">
							{if $c->type_commentaire == 'info'}
								{$c->commentaire}<br/><br/>
							{elseif $c->type_commentaire == 'attr'}
								<code>{$c->commentaire}</code>
							{/if}
						</td>
						<td valign="top" >
							{assign var=uc value=$c->utilisateur}
							<i>{$uc->nom} {$uc->prenom}</i><br/>
							<small>le {$c->date_commentaire|date_format:"%d-%m-%Y"}</small>
						</td>
					</tr>
				{/foreach}
			</table>
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Commentaires / Discussion</b></td>
		<td valign="top">
			<table>
				{foreach from=$citation->get_commentaires() item=c}
					<tr>
						<td valign="top">
							{if $c->type_commentaire == 'info'}
								<img src="icones/friends.png"/>
							{elseif $c->type_commentaire == 'attr'}
								<img src="icones/tools.png"/>
							{/if}
						</td>
						<td valign="top" width="60%" style="background-color:white;">
							{if $c->type_commentaire == 'info'}
								{$c->commentaire}<br/><br/>
							{elseif $c->type_commentaire == 'attr'}
								<code>{$c->commentaire}</code>
							{/if}							
						</td>
						<td valign="top" >
							{assign var=uc value=$c->utilisateur}
							<i>{$uc->nom} {$uc->prenom}</i><br/>
							<small>le {$c->date_commentaire|date_format:"%d-%m-%Y"}</small>
						</td>						
					</tr>
				{/foreach}
			</table>
			{if $auth_ok}
				<a id="lien" href="javascript:;" onClick="bascule('lien','formulaire');">Ajouter un commentaire</a>
				<div id="formulaire" style="display:none;">
				<form method="post" action="?t=citation&id={$citation->id_citation}">
					<input type="hidden" name="action" value="enregistre_commentaire"/>
					<textarea name="c" cols="40" rows="8"></textarea><br/>
					<input type="submit" value="Ajouter un commentaire"/>
				</form>
				</div>
			{/if}
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Identifiant unique</b></td>
		<td valign="top">{$citation->guid}</td>
	</tr>
	<tr>
		<td valign="top"><b>Enquête</b></td>
		<td valign="top">
			{if $resultat_enquete}
			<ul>
				{foreach from=$resultat_enquete item=v key=k}
					<li>{$k}: <b>{$v}</b></li>
				{/foreach}
			</ul>
			{else}
				Pas d'enquête associée	
			{/if}
		</td>
	</tr>
</table>
{else}
	{if !$auth_ok}
	<div style="background-color: white; padding: 4px; margin: 2px; border-style:solid; border-size:1px; border-color:#d90019;float:right;">
		<b>Ouvrir une session</b><br/>
		<form method="post" action="?t=accueil">
			<input type="hidden" name="act" value="login"/>
			<input type="hidden" name="redir" value="?t=citation&id={$id_citation}"/>
			Nom d'utilisateur<br/>
			<input type="text" name="username" value=""/><br/>
			Mot de passe<br/>
			<input type="password" name="password" value=""/><br/><br/>
			<input type="submit" value="Envoyer"/>			
		</form>
	</div>
	{/if}
	<h1>Consultation d'une observation</h1>
	Vous ne pouvez pas consulter cette observation, soit parce qu'elle n'existe pas ou que vous n'en avez pas le droit.
{/if}
<div id="z_beta_validation" style="display:none;" title="Résultat des tests"></div>
{literal}
<script>
J('#btn_beta_validation').click(function () {
	var id_citation = J(this).attr('id_citation');
	var z_aff = J('#z_beta_validation');
	z_aff.html('Tests en cours...');
	z_aff.load('?t=citation_beta_validation&id='+id_citation);
	z_aff.dialog({width:600, modal:true});
});
</script>
{/literal}
{include file="poste_foot.tpl"}
