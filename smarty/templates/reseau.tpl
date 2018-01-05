{include file="head.tpl"}
<h1>Liste des réseaux</h1>
<table>
	<tr>
		<th>Réseau</th>
		<th>Nombre de taxons</th>
	</tr>
	{foreach from=$reseaux item=r}
	<tr>
		<td><a href="?t=reseau&id={$r->get_id()}">{$r}</a></td>
		<td>{$r->get_n_especes()}</td>
	</tr>
	{/foreach}
</table>
{if $reseau}
	<table>
	<tr>
		<th>Ordre</th>
		<th>Famille</th>
		<th>Nom scientifique</th>
		<th>Nom</th>
	</tr>
	{foreach from=$reseau->get_liste_especes() item=esp}
	<tr>
		<td>{$esp.ordre}</td>
		<td>{$esp.famille}</td>
		<td>{$esp.nom_s}</td>
		<td>{$esp.nom_f}</td>
	</tr>
	{/foreach}	
</table>	
{/if}
{include file="poste_foot.tpl"}
