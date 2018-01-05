{assign var=espece value=$citation->get_espece()}
<div style="display:none;" id="citation{$citation->id_citation}"></div>
<h1>{$espece->nom_f} <a href="?t=espece_detail&id={$citation->id_espece}">&rarr;</a></h1>
<h2>{$espece->nom_s}</h2>

<div align="right">
	<a href="javascript:editer({$citation->id_citation});">modifier</a>
	<a href="javascript:ajouter_photo({$citation->id_citation},{$citation->id_observation});">+ photo</a>
</div>
<div style="padding:5px;">
	<div class="bobs-table" width="80%">
	<table>
		<tr>
			<td width="60%">Effectif observé</td>
			<td width="40%">{$citation->nb}</td>
		</tr>
		{if $citation->nb_min > 0}
		<tr>
			<td>Fouchette effectifs</td>
			<td>{$citation->nb_min} - {$citation->nb_max}</td>
		</tr>
		{/if}
		<tr>
			<td>Sexe</td>
			<td>{$citation->sexe}</td>
		</tr>
		<tr>
			<td>Âge</td>
			<td>{$citation->age}</td>
		</tr>
		<tr>
			<td>Niveau de certitude</td>
			<td>{$citation->get_indice_qualite()}</td>
		</tr>
	</table>
	</div>
	<p class="">Comportements et autre étiquettes</p>
	{foreach from=$citation->get_tags() item=tag}
		<div class="bobs-saisie-citations-tag" id="{$citation->id_citation}-{$tag.id_tag}">
			{$tag.lib}
			{if $tag.a_chaine eq 't'} : <i>"{$tag.v_text}"</i>{/if}
		</div>
	{foreachelse}
		<div class="bobs-saisie-citations-tag">
			<small><i>Aucun</i></small>
		</div>
	{/foreach}
	
	<p class="">Documents - images</p>
	{foreach from=$citation->documents_liste() item=doc}
	{if $doc->get_type() == 'image'}
		<a href="?t=img&id={$doc->get_doc_id()}" target="_blank">
			<img src="?t=img&id={$doc->get_doc_id()}&w=280"/>
		</a>
	{/if}
{/foreach}
</div>
