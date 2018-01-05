{include file="poste_head.tpl" titre_page="Mes fichiers"}
<h1>Vos fichiers</h1>
<div class="bobs-table">
<table>
	<tr>
		<th>Nom du fichier</th>
		<th>Libellé</th>
		<th>Date de création</th>
	</tr>
{foreach from=$u->fichiers() item=fichier}
	<tr>
		<td>
			<a href="?t=fichier&id={$fichier->file._id}">
				{$fichier->file.filename}
			</a>
		</td>
		<td>{$fichier->file.lib}</td>
		<td>{$fichier->file.date_creation}</td>
	</tr>
{/foreach}
</table>
</div>
{include file="poste_foot.tpl"}
