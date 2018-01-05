<b>{$commune}</b><br/>
{assign var=n value=0}
{foreach from=$citations item=c}
	{assign var=n value=$n+1}
	{assign var=o value=$c->get_observation()}
	le {$o->date_observation|date_format:'%A %e %B %Y'} {$c->get_espece()} {if $c->nb >0}{$c->nb}{/if}
	{if $c->indice_qualite < 3}&plusmn;{/if}.<br/>
{/foreach}
{if $n > 1}<br/>{$n} citations affichées.{/if}
{if $n eq 0}Pas de résultat{/if}
<br/>
<i>&plusmn; &rarr; observation avec identification incertaine</i>
