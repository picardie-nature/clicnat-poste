{assign var=id_observation value=-1}
{foreach from=$citations item=c}
	{if $id_observation != $c->id_observation}
		{assign var=obs value=$c->get_observation()}
		{assign var=id_observation value=$c->id_observation}
		<hr/>
		le {$obs->date_observation|date_format:"%d-%m-%Y"}
		{assign var=espace value=$obs->get_espace()}
		{assign var=nc value=0}
		{foreach from=$espace->get_communes() item=commune}
			{assign var=nc value=$nc+1}
			{$commune->nom2} ({$commune->get_dept()})
		{/foreach}
		{if $nc == 0}
			{assign var=lits value=$espace->get_littoraux()}
			{foreach from=$lits item=lit}
				<i class="littoral">{$lit}</i>
			{/foreach}
		{/if} :
	{/if}
	{if $c->nb == -1}<strike>{/if}
	{if $c->nb > 0}
		{$c->nb}{/if}
		{if $c->sexe != '?'}
			<abbr class="sexe" title="xxx">{$c->sexe}</abbr>
		{/if} 
		{if $c->age != '?'}
			<abbr class="age" title="xxx">{$c->age}</abbr>
		{/if}
		{$c->get_espece()}
	{if $c->nb == -1}</strike>{/if}
{/foreach}

