<table style="">
	<thead>
		<tr>
			<th>Code</th>
			<th>Nom</th>
			<th>Sélection</th>
		</tr>
	</thead>
	<tbody >
		{foreach from=$citation->get_tags() item=tag}
		<tr>
			<td>{$tag.ref}</td>
			<td>{$tag.lib}</td>
			<td><a href="javascript:retirer_code_comportement_editeur({$tag.id_tag});">retirer</a></td>
		</tr>
		{/foreach}
	</tbody>
</table>

