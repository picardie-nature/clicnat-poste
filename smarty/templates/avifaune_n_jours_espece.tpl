<b>{$espece}</b><br/>
{assign var=n value=0}
{foreach from=$citations item=c}
	{if $c->nb >0}{$c->nb}{/if}
	{assign var=n value=$n+1}
	{assign var=o value=$c->get_observation()}
	{assign var=e value=$o->get_espace()}
	{assign var=ec value=$e->get_communes()}
	le {$o->date_observation|date_format:'%A %e %B %Y'}
	{foreach from=$ec item=ecc}
		{$ecc}
	{/foreach}
	<br/>
{/foreach}
{if $n > 1}<br/>{$n} citations affichées.{/if}
{if $n eq 0}Pas de résultat{/if}
