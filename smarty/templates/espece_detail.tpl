{include file="poste_head.tpl" titre_page=$esp}
{assign var=referentiel value=$esp->get_referentiel_regional()}

<script src="http://deco.picardie-nature.org/jquery/js/jquery.moodular.js" language="javascript"></script>
<script src="http://deco.picardie-nature.org/jquery/js/jquery.moodular.controls.js" language="javascript"></script>
<script src="http://deco.picardie-nature.org/jquery/js/jquery.moodular.effects.js" language="javascript"></script>

<script src="js/raphael-min.js" language="javascript"></script>
<script src="js/morris.min.js" language="javascript"></script>

<h1>{$esp->nom_f} <small>{$esp->nom_s}</small></h1>
<div style="text-align:right;">Rechercher une autre espèce <input type="text" id="espece"/></div>
<script>
{literal}
    J('#espece').autocomplete({source: '?t=espece_autocomplete2&nohtml=1',
	select: function (event,ui) {
	    document.location.href = '?t=espece_detail&id='+ui.item.value;
	    event.target.value = '';
	    return false;
	}
    });
{/literal}
</script>
<div class="bobs-demi">
	<div class="bobs-demi-titre">Fiche</div>
	<div class="bobs-demi-interieur">
		<div align="center">
		<table>
			{if $esp->nom_f}
			<tr>
				<th>Nom vernaculaire</th>
				<td>{$esp->nom_f}</td>			
			</tr>
			{/if}
			{if $esp->nom_s}
			<tr>
				<th>Nom scientifique</th>
				<td>{$esp->nom_s}</td>
			</tr>
			{/if}
			{if $esp->ordre}
			<tr>
				<th>Ordre</th>
				<td><a href="?t=especes&r_objet=ordre&r_ref={$md5_ordre}">{$esp->ordre}</a></td>
			</tr>
			{/if}
			{if $esp->famille}
			<tr>
				<th>Famille</th>
				<td>{$esp->famille}</td>
			</tr>
			{/if}
		</table>
		</div>
		{assign var=ref_inpn value=$esp->get_inpn_ref()}
		{if $ref_inpn}
			<i>Cette fiche est raccordée avec le référentiel du <a href="http://inpn.mnhn.fr/isb/index.jsp">Muséum national d'Histoire naturelle</a>. 
			Voici la liste des taxons associés, le taxon en gras est celui de référence.</i>
			<div align="center">
				<table width="100%">
					<tr>
						<th>Identifiant</th>
						<th>Ordre<br/>Famille</th>
						<th>Nom vernaculaire<br/>Nom scientifique</th>
					</tr>
					{foreach from=$ref_inpn->get_references() item=taxon}
					<tr>
						{assign var=tref value=''}{assign var=ftref value=''}
						{if $taxon.cd_ref == $taxon.cd_nom}
							{assign var=tref value='<b>'}{assign var=ftref value='</b>'}
						{/if}
						<td align="center">{$tref}{$taxon.cd_nom}{$ftref}</td>
						<td>{$tref}{$taxon.ordre}<br/>{$taxon.famille}{$ftref}</td>
						<td>{$tref}{$taxon.nom_vern}<br/>{$taxon.lb_nom} <i>{$taxon.lb_auteur}</i>{$ftref}</td>
					</tr>
					{/foreach}
				</table>
			</div>
		{/if}
	</div>
</div>
{if $referentiel.id_espece}
<div class="bobs-demi">
	<div class="bobs-demi-titre">Satut régional - Référentiel faune</div>
	<div class="bobs-demi-interieur">
		<p><small>
			Indique le degré de rareté et de menace pour  cette espèce en Picardie.
			 Vous pouvez consulter cette <a href="http://www.picardie-nature.org/spip.php?article773" target="_blank">page</a> 
			 consacrée au référentiel pour en savoir plus.</small></p>
		<div align="center">
		<table>
		{if $referentiel.statut_origine}
			<tr>
				<th>Statut d'origine</th>
				<td>{$referentiel.statut_origine}</td>
			</tr>
		{/if}
		{if $referentiel.statut_bio}
			<tr>
				<th>Statut biologique</th>
				<td>{$referentiel.statut_bio}</td>
			</tr>
		{/if}
		{if $referentiel.indice_rar}
			<tr>
				<th>Indice de rareté</th>
				<td>{$esp->get_indice_rar_lib($referentiel.indice_rar)}</td>
			</tr>
		{/if}
		{if $referentiel.niveau_con}
			<tr>
				<th>Niveau de connaissance</th>
				<td>{$referentiel.niveau_con}</td>
			</tr>
		{/if}
		{if $referentiel.categorie}
			<tr>
				<th>Degré de menace</th>
				<td>{$esp->get_degre_menace_lib($referentiel.categorie)}</td>
			</tr>
		{/if}
		{if $referentiel.etat_conv}
			<tr>
				<th>État de conservation</th>
				<td>{$referentiel.etat_conv}</td>
			</tr>
		{/if}
		{if $referentiel.prio_conv_cat}
			<tr>
				<th>Priorité de conservation</th>
				<td>{$referentiel.prio_conv_cat}</td>
			</tr>
		{/if}
		</table>
		</div>
	</div>
</div>
{/if}

<div class="bobs-demi">
	<div class="bobs-demi-titre">Carte de répartition</div>
	<div class="bobs-demi-interieur">
		<p></p>
		<p><a href="http://www.clicnat.fr/?page=fiche&id={$esp->id_espece}">Voir la carte sur la fiche espèce</a></p>
	</div>
</div>

<div class="bobs-demi">
	<div class="bobs-demi-titre">Autres cartes et informations</div>
	<div class="bobs-demi-interieur">
		{if $esp->id_chr > 0}
			<b>Homologation</b><br/>
			<small><i>Cette espèce est soumise à homologation voir la liste des espèces du comité :</small> 
			<a href="?t=ch&id={$esp->id_chr}">{$esp->get_chr()}</a></i><br/><br/>
		{/if}
		{if $esp->classe == 'O'}
		    <b>Oiseaux nicheurs</b><br/>
		    <a href="?t=atlas_oiseaux_nicheurs_espece&id={$esp->id_espece}">Voir l'atlas pour cette espèce</a><br/><br/>
		    <b>Oiseaux hivernants</b><br/>
		    <a href="?t=atlas_oiseaux_hivernants_espece&id={$esp->id_espece}">Voir l'atlas pour cette espèce</a><br/>
		{/if}
		
		<br/><b>Étiquettes et codes comportementaux utilisés par cette espèce</b><br/>
		{foreach from=$esp->tags_utilisees_obj() item=tag}
			{if $tag.id_tag neq 579}
			{assign var=style value=""}
			{assign var=otag value=$tag.obj}
			{if !$otag->test_association_espece($esp)}
				{assign var=style value="color:red;"}
			{/if}
			<a style="{$style}" href="?t=tag_infos&id={$tag.id_tag}">{$tag.lib} ({$tag.count})</a>
			{/if}
		{foreachelse}
			<p>aucune étiquette ou code utilisé pour cette espèce</p>
		{/foreach}
	</div>
</div>
<div class="bobs-entier">
	<div class="bobs-demi-titre">Distribution des observations dans l'année par semaine</div>
	<div class="bobs-demi-interieur" id="distrib"></div>
	<script>
	{literal}var distrib_data=[{/literal}
	{assign var=distrib value=$esp->distribution_observations_semaines()}
	{foreach from=$distrib item=s}
		{literal}{{/literal}semaine: {$s.semaine}, n: {$s.n}, p: {$s.p|string_format:"%.2F"}{literal}}{/literal},
	{/foreach}
	{literal}
	];

	Morris.Line({ element: 'distrib', data: distrib_data, xkey: 'semaine', ykeys: ['p'],labels: ['Semaine'],parseTime:false,postUnits:'%'});
	
	{/literal}

	</script>
</div>
<div class="bobs-demi">
	{assign var=compte value=$mes_obs->compte()}
	<div class="bobs-demi-titre">Vos observations</div>
	<div class="bobs-demi-interieur">
		{if $compte > 0}
		Vous avez fait {$compte} observations de cette espèce.
		{else}
		Vous n'avez pas encore observé cette espèce
		{/if}<br/>
		<table width="100%">
		<tr>
			<th>Numéro de <br/> citation</th>
			<th>Date</th>
			<th>Lieu</th>
		</tr>
		{foreach from=$mes_obs->dans_un_tableau() item=citation}
			{assign var=c value=$u->get_citation_authok($citation.id_citation)}
			{assign var=obs value=$c->get_observation()}
			{assign var=espace value=$obs->get_espace()}
		<tr>
			<td align="center"><a href="?t=citation&id={$citation.id_citation}">{$citation.id_citation}</a></td>
			<td>{$obs->date_observation|date_format:"%A %e %B %Y"}</td>
			<td align="center">
				{if !$espace->nom}{$espace->nom}{/if}
				{if $espace->get_table() == 'espace_point'}
					{$espace->get_commune()}
					<a target="_blank" href="http://maps.google.fr/maps?q=@{$espace->get_y()},{$espace->get_x()}">voir le point sur Google Maps</a>	<br/>
				{/if}
				{if !$espace}<font color=red>?</font>{/if}
			</td>
		</tr>
		{/foreach}
		</table>
	</div>
</div>
	<style>
		{literal}
		.carousel ul, .carousel li {
			margin:0;
			width: 250px;
			height: 187px;
			max-height: 187px;
			overflow: hidden;
			list-style:none;
			padding:0px;
		}

		.carousel li {
			float:left;
			margin:0px;
			padding:0px;
		}
		{/literal}
	</style>
<script>
	//{literal}
	function ouvre_upload() {
		J('#dlg-photo').dialog();
	}

	function ouvre_photo_poste(doc_id) {
		J('#dlg-prev-photo').html('<img src="?t=img&w=600&id='+doc_id+'"/><br/>Photo : '+auteurs[doc_id]);
		J('#dlg-prev-photo').dialog({
			width: 620,
			height: 520,
			modal: true
		});
	}
	//{/literal}
</script>

<div style="display:none;">
	<div id="dlg-photo" title="Envoyer une photo">
		<form enctype="multipart/form-data" method="post" action="?t=espece_attache_doc">
			<input type="hidden" name="id" value="{$esp->id_espece}"/>
			<input type="hidden" name="url_retour" value="?t=espece_detail&id={$esp->id_espece}"/>
			<input type="hidden" name="MAX_FILE_SIZE" value="300000000" />
			<input name="f" type="file" /><br/>
			<input type="submit" value="Envoyer"/><br/>
			<small>Attention, n'envoyez que des photos dont vous êtes l'auteur.</small>
		</form>
	</div>
	<div id="dlg-prev-photo" title="{$esp}"></div>
</div>

<div class="bobs-demi">

	<div class="bobs-demi-titre">En image</div>
	<div class="bobs-demi-interieur">
		<div style="text-align:left;">
			{texte nom="base/fiche_espece_partage_photo"}
			<a href="javascript:ouvre_upload();">Cliquez-ici</a>
		</div>
		<div align="center">
		<div class="carousel" id="car">
		<script>var auteurs = new Array();</script>
		<ul>
		{assign var=n_images value=0}
		{assign var=en_attente value=0}
		{foreach from=$esp->documents_liste() item=img}			
			{if $img->get_type() == 'image'}
				{if !$img->est_en_attente()}
				<li>
					{assign var=n_images value=$n_images+1}
					<img src="?t=img&id={$img->get_doc_id()}&w=250" onclick="javascript:ouvre_photo_poste('{$img->get_doc_id()}');" />
					<script>auteurs['{$img->get_doc_id()}'] = "{$img->get_auteur()}";</script>
				</li>
				{else}
					{assign var=en_attente value=$en_attente+1}
				{/if}
			{/if}
		{/foreach}				
		{if $n_images == 0}
			<li>
				<br/><br/>
				<big>Pas de photographie de cette espèce</big><br/><br/>
				{if $en_attente > 0}
					<b>{$en_attente} photo{if $en_attente>1}s{/if} en attente de validation</b>
					<br/><br/>
				{/if}
				<a href="javascript:ouvre_upload();">Cliquez ici</a>
				</small>
			</li>
		{/if}
		</ul>
		</div>
	</div>
	{if $n_images>1}
		{literal}
			<script>
				window.onload = function () {
					jQuery('#car ul').moodular({dispTimeout:3000});
				};					
			</script>
		{/literal}		
	{/if}
	<p>{$n_images} photographie{if $n_images>1}s{/if}.</p>
	</div>
</div>
<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
