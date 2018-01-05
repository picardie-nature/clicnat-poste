<div style="float:right;">
	Citation<br/>
	<b>{$citation->id_citation}</b>
</div>
{assign var=espece value=$citation->get_espece()}
{assign var=height value=280}
{$espece->nom_f}<br><small>{$espece->nom_s}</small>
<div style="clear:both;"></div>
<hr/>
<div id="bobs-saisie-ed-acc">
	<h3><a href="#">Détail de la citation</a></h3>
	<div>
		{assign var=chr value=$espece->get_chr()}
		{if $chr}
			<div style="color:#f89e1e;">
				{texte nom="poste_saisie_msg_chr"}
			</div>
		{/if}
		{if $espece->n_citations < 20}
			<div style="color:#f89e1e;">
				{texte nom="poste_saisie_msg_n_cits"}
			</div>
		{/if}
		{if $espece->referentiel_regionale_existe()}
			{assign var=rr value=$espece->get_referentiel_regional()}
			{if $rr.indice_rar eq 'EX'} {assign var=avertissment_rarete value=1}{/if}
			{if $rr.indice_rar eq 'TR'} {assign var=avertissment_rarete value=1}{/if}
			{if $rr.indice_rar eq 'R'} {assign var=avertissment_rarete value=1}{/if}
			{if $rr.indice_rar eq 'AR'} {assign var=avertissment_rarete value=1}{/if}
			{if $rr.indice_rar eq 'PC'} {assign var=avertissment_rarete value=1}{/if}
			{if $avertissment_rarete eq 1}
				<p style="color:#f89e1e">Attention, cette espèce n'est pas commune (statut de rareté : "{$rr.indice_rar}"), êtes vous sûr(e) de vous ?</p>
			{else}
				{if $rr.categorie eq 'NT'} {assign var=avertissment_menace value=1}{/if}
				{if $rr.categorie eq 'VU'} {assign var=avertissment_menace value=1}{/if}
				{if $rr.categorie eq 'EN'} {assign var=avertissment_menace value=1}{/if}
				{if $rr.categorie eq 'CR'} {assign var=avertissment_menace value=1}{/if}
				{if $rr.categorie eq 'RE'} {assign var=avertissment_menace value=1}{/if}
				{if $avertissment_menace eq 1}
					<p style="color:#f89e1e">Attention, cette espèce est menacée (statut de menace : "{$rr.categorie}"), êtes vous sûr(e) de vous ?</p>
				{/if}
			{/if}
		{/if}
		{if $espece->remarquable}
			<div style="color:#f89e1e;">
				{texte nom="poste_saisie_msg_remarq"}
			</div>
		{/if}
		<form id="bobs-saisie-ed-f-p1" onsubmit="javascript: return false;">
			<input type="hidden" name="cid" id="cid" value="{$citation->id_citation}"/>
		<table>
		<tr>
			<td>Nombre d'individus observés</td>
			<td>
				<input type="text" name="effectif" id="effectif" size="4" maxlength="6" value="{$citation->nb}"/> précis ou utiliser fourchette ci-dessous
			</td>
		</tr>
		<tr>
			<td>Fourchette d'effectifs</td>
			<td>
				<input type="text" name="nb_min" id="nb_min" size="4" maxlength="6" value="{$citation->nb_min}"/>
				&gt;&gt;<input type="text" name="nb_max" id="nb_max" size="4" maxlength="6" value="{$citation->nb_max}"/>
			</td>
		</tr>
		<tr>
			<td>Sexe</td>
			<td>
				<select name="sexe">
				{foreach from=$citation->get_gender_list() item=sex}
					{if $sex.prop}
						<option value="{$sex.val}" {if $sex.val == $citation->sexe} selected {/if}>
							{$sex.lib}
						</option>
					{/if}
				{/foreach}
				</select>
			</td>
		</tr>
		<tr>
			<td>Âge</td>
			<td>
				<select name="age">
				{foreach from=$espece->get_age_list() item=age}
					{if $age.prop}
						<option value="{$age.val}" {if $age.val == $citation->age} selected {/if}>
							{$age.val} - {$age.lib}
						</option>
					{/if}
				{/foreach}
				</select>
			</td>
		</tr>
		<tr>
			<td>Indice de fiabilité<br/>de l'identification</td>
			<td>
				<select name="indice_qualite">
				    <option value="4" {if $citation->indice_qualite == "4"} selected {/if}>très fort</option>
				    <option value="3" {if $citation->indice_qualite == "3"} selected {/if}>fort</option>
				    <option value="2" {if $citation->indice_qualite == "2"} selected {/if}>moyen</option>
				    <option value="1" {if $citation->indice_qualite == "1"} selected {/if}>faible</option>
				</select>
			</td>
		</tr>
		</table>
			<br/>
			<div id="bobs-saisie-ed-f-p"></div>
			<p class="informal"> Après avoir saisi ces informations cliquez
			sur le titre "Codes comportements" pour passer à la suite.</p>
			<p class="informal"> Effectif inconnu : pour noter uniquement
			la présence de l'espèce indiquer 0.</p>
			<p class="informal"> Aucun effectif : pour indiquer l'absence
			de l'espèce (prospection négative) indiquer -1</p>
		</form>
	</div>
	{if $enquete}
	<h3><a href="#">Informations complémentaires</a></h3>
	<div style="max-height:{$height}px; overflow:auto" id="clicnat_enquete" id_enquete="{$enquete->id_enquete}" version="{$enquete->version}">
		<div id="clicnat_enquete_orig" style="display:none;">{$citation->enquete_resultat}</div>
		{$enquete->formulaire($citation->id_citation)}
	</div>
	{else}
	<h3><a href="#">Codes comportements</a></h3>
	<div style="max-height:{$height}px; overflow:auto;">
		<a href="javascript:rechercher_code_comportement();">rechercher un comportement qui n'est pas dans la liste</a>
		<div id="cc_z_statut"></div>
		<table style="">
			<thead>
				<tr>
					<th>Code</th>
					<th>Nom</th>
					<th>Sélection</th>
				</tr>
			</thead>
			<tbody >
			{foreach from=$principaux_codes item=code}
				<tr>
					<td>
						<label for="bobs-cpri-{$code->id_tag}">{$code->ref}</label>
					</td>
					<td>
						<label for="bobs-cpri-{$code->id_tag}">{$code->lib}</label>
					</td>
					<td>
						<input align="center" onchange="javascript:enregistre_citation_tag({$citation->id_citation},{$code->id_tag},this);" type="checkbox" value="{$code->id_tag}" id="bobs-cpri-{$code->id_tag}" value="{$code->id_tag}" {if $citation->a_tag($code->id_tag)}checked{/if}/>
						<span id="bobs-rt-{$code->id_tag}"></span>
					</td>
				</tr>
			{/foreach}
			</tbody>
		</table>
	</div>
	{/if}
	<h3><a href="#">Commentaire</a></h3>
	<div style="max-height:{$height}px; overflow:auto;">
		<form id="bobs-saisie-ed-c-p1" onsubmit="javascript: return false;">
			<input type="hidden" name="cid" value="{$citation->id_citation}"/>
			<p class="directive">Commentaire</p>
			<p class="valeur">
				<textarea rows="10" cols="40" name="commentaire" id="bobs-editeur-comtr">{$citation->commentaire}</textarea>
			</p>
		</form>
	</div>
</div>
