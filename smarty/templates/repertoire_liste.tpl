{if $gpx_wpts}
	<b>Points import GPX</b>
	<table width="100%">
		<tr>
			<th>lat</th>
			<th>lon</th>
			<th>nom</th>
			<th>commentaire</th>
			<th></th>
		</tr>
		{foreach from=$gpx_wpts item=wpt}
		<tr>
			<td>{$wpt->latitude}</td>
			<td>{$wpt->longitude}</td>
			<td>{$wpt->nom}</td>
			<td>{$wpt->commtr}</td>
			<td><a href="javascript:v2_saisie_placerGPX({$wpt->latitude}, {$wpt->longitude});">Placer</a></td>
		</tr>
		{/foreach}
	</table>
{/if}
<table style="border-style:solid; border-width:1px;">
	<tr>
		<th></th>
		<th>Nom</th>
		<th>Date</th>
		<th>#</th>
	</tr>
	{foreach from=$repertoire item=espace}
	<tr>
		<td><img src="picnat/{$espace.table_espace}.png" alt="{$espace.table_espace}"/></td>
		<td>
			<a style="color:blue;" href="javascript:iface.repertoireUtilise('{$espace.table_espace}',{$espace.id_espace});">{$espace.nom}</a>
		</td>
		<td>{$espace.date_association|date_format:"%d-%m-%Y"}</td>
		<td>{$espace.id_espace}</td>
		<td><a style="color:blue;" href="javascript:iface.repertoireSupprime('{$espace.table_espace}',{$espace.id_espace});">x</a></td>
	</tr>
	{/foreach}
</table>

