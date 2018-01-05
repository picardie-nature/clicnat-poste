{assign var=obs value=$citation->get_observation()}
<h3>Observation</h3>
<table>
<tr><td>Date</td><td><i>{$obs->date_observation|date_format:"%d-%m-%Y"}</i></td></tr>
{if $obs->heure_observation}
	<tr><td>Heure</td><td><i>{$obs->heure_observation}</i></td></tr>
{/if}
{if $obs->duree_observation}
	<tr><td>Durée</td><td><i>{$obs->duree_observation}</i></td></tr>
{/if}
<tr><td valign="top" colspan=2>Observateur(s)</td></tr>
<tr><td valign="top" colspan=2>
		<ul>
			{foreach from=$obs->get_observateurs() item=observateur}
				<li><i>{$observateur.nom} {$observateur.prenom}</i></li>
			{/foreach}
		</ul>
	</td>
</tr>
{assign var=tags value=$obs->get_tags()}
{if count($tags)>0}
<tr><td colspan="2">Attributs</td></tr>
<tr><td colspan="2" valign="top">
		<ul>
			{foreach from=$tags item=tag}
				<li><i>{$tag.lib}</i></li>
			{/foreach}
		</ul>
	</td>
</tr>
{/if}
</table>
<h3>Citation</h3>
{assign var=tags value=$citation->get_tags()}
{assign var=espece value=$citation->get_espece()}
<table>
	<tr><td>Espèce</td><td><i>{$espece}</i></td></tr>
	<tr>
		<td>Effectif</td>
		<td><i>
			{if $citation->nb == -1}prospection négative{/if}
			{if $citation->nb == 0}indéterminé{/if}
			{if $citation->nb > 0}{$citation->nb}{/if}
		</i></td>
	</tr>
	{if count($tags)>0}
	<tr><td colspan=2 valign="top">Attributs</td></tr>
	<tr><td colspan=2 valign="top">
			<ul>
				{foreach from=$tags item=tag}
					<li><i>{$tag.lib}</i></li>
				{/foreach}
			</ul>
		</td>
	</tr>
	{/if}
	{if $citation->ref_import}
	<tr><td>Réference import</td><td><i>{$citation->ref_import}</i></td></tr>
	{/if}	
</table>
<h3>Historique et commentaires</h3>
<pre>{$citation->commentaire}</pre>
<h4>Ajouter un nouveau commentaire</h4>

<div id="bobs-commtrs-citation"></div>
<script>
	citation_affiche_commentaire({$citation->id_citation}, 'bobs-commtrs-citation');
</script>
<form id="bobs-ajoute-commtr-citation">
	<input type="hidden" name="id" value="{$citation->id_citation}"/>
	<textarea rows=6 cols=30 name="msg"></textarea><br/>
	<input type="button" value="Enregistrer" onclick="javascript:citation_ajoute_commentaire();"/>
</form>
</textarea>
<h3>Documents associés </h3>
{foreach from=$citation->documents_liste() item=doc}
	{if $doc->get_type() == 'image'}
		<a href="?t=img&id={$doc->get_doc_id()}" target="_blank">
			<img src="?t=img&id={$doc->get_doc_id()}&w=300"/>
		</a>
	{/if}
{/foreach}
<h3>Identifiants</h3>
<table>
	<tr><td>Numéro d'observation</td><td><i>{$citation->id_observation}</i></td></tr>
	<tr><td>Localisation stockée dans</td><td><i>{$obs->espace_table}</i></td></tr>
	<tr><td>Numéro de la géométrie</td><td><i>{$obs->id_espace}</i></td></tr>
	<tr><td>Numéro de citation</td><td><i>{$citation->id_citation}</i></td></tr>
	<tr><td>Code espèce</td><td><i>{$citation->id_espece}</i></td></tr>
	<tr><td>Numéro auteur</td><td><i>{$obs->id_utilisateur}</i></td></tr>
</table>
