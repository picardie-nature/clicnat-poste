{if $espace}
	Parcelle : {$espace->nom}<br/>
	Type : {$culture}<br/>
	<a href="javascript:;" onClick="javascript:lepido_nouvelle_date('{$espace->get_table()}',{$espace->id_espace},'lepido rpg');">Ajouter au calendrier</a>
	<ul>
	{foreach from=$dates item=date}
		<li><a href="javascript:;" onClick="javascript:lepido_rpg_edit_date({$date->id_date});">{$date->date_sortie|date_format:"%d-%m-%Y"}</a></li>
	{/foreach}
	</ul>
{else}
	Pas de parcelle trouvée
{/if}
