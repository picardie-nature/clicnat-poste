<ul>
	{foreach from=$observateurs item=o}
		<li id="{$o->id_utilisateur}">{$o->nom} {$o->prenom}</li>
	{/foreach}
</ul>
