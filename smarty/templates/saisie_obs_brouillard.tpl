{assign var=observations value=$u->liste_observations_brouillard()}
<div class="bobs-table">
<table width="80%">
	<tr>
		<th>Date d'observation</th>
		<th>Lieu d'observation</th>
		<th>N. citations</th>
		<th></th>
		<th></th>
	</tr>
	{foreach from=$observations item=t_o}
	{assign var=id_obs value=$t_o.id_observation}
	{assign var=o value=$u->observation_brouillard($id_obs)}
	<tr>
		<td align="center">
			<a href="?t=saisie_base&id={$o->id_observation}"><big>{$o->date_observation|date_format:"%d-%m-%Y"}</big></a>
		</td>
		<td>
			{assign var=e value=$o->get_espace()}
			{$e}<br/>
			<small>
			{foreach from=$e->get_communes() item=c}
				{$c}
			{/foreach}
			</small>

		</td>
		<td>
			{assign var=ids value=$o->get_citations_ids()}
			{$ids|@count}
		</td>
		<td>
			<a href="javascript:placer_point_observation({$o->id_observation});">voir sur la carte</a>
		</td>
		<td>
			<a href="?t=saisie_base&id={$o->id_observation}">ouvrir</a>
		</td>

	</tr>
	{/foreach}
</table>
</div>
