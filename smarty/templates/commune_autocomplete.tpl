<ul>
	{foreach from=$communes item=c}
		<li id="{$c->id_espace}">{$c->nom} ({$c->get_dept()})</li>
	{/foreach}
</ul>
