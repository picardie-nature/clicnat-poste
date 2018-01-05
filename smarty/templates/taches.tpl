{include file="poste_head.tpl" titre_page="Mes taches"}
{assign var=en_attente value=$u->taches_en_attente()}
{assign var=en_cours   value=$u->taches_en_cours()}
{assign var=terminees  value=$u->taches_terminees()}
<h2>Mes taches</h2>
<a href="?t=fichiers">Consulter mes fichiers</a>
<div class="bobs-table">
<table width="100%">	
	<tr><th colspan="3">En attente</th></tr>
	{foreach from=$en_attente item=tache}
	<tr>
		<td>{$tache->id_tache}</td>
		<td>{$tache}</td>
		<td>Créé le {$tache->date_creation|date_format:"%d-%m-%Y"}</td>
	</tr>
	{/foreach}
	{if $en_attente->count() == 0}
	<tr>
		<td colspan="3">Aucune tache en attente</td>
	</tr>
	{/if}
	<tr><th colspan="3">En cours</th></tr>
	{foreach from=$en_cours item=tache}
	<tr>
		<td>{$tache->id_tache}</td>
		<td>{$tache}</td>
		<td>Démarée le {$date->date_exec|date_format:"%d-%m-%Y"}</td>
	</tr>
	{/foreach}
	{if $en_cours->count() == 0}
	<tr>
		<td colspan="3">Aucune tache en cours</td>
	</tr>
	{/if}

	<tr><th colspan="3">Terminées</th></tr>
	{foreach from=$u->taches_terminees() item=tache}
		<tr>
			<td>{$tache->id_tache}</td>
			<td>{$tache}</td>
			<td>Terminée le {$tache->date_fin|date_format:"%d-%m-%Y"}</td>
		</tr>
	{/foreach}

</table>
</div>
{include file="poste_foot.tpl"}
