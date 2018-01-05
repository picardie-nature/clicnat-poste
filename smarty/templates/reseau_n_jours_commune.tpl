<b>{$commune}</b><br/>
{assign var=n value=0}
{foreach from=$citations item=c}
	{assign var=n value=$n+1}
	{assign var=o value=$c->get_observation()}
	{assign var=espece value=$c->get_espece()}
	le {$o->date_observation|date_format:'%A %e %B %Y'} {if $reseau->restitution_nom_s}{$espece->nom_s}{else}{$espece}{/if} {if $c->nb >0}{$c->nb}{/if}
	{if $c->indice_qualite < 3}&plusmn;{/if}.<br/>
{/foreach}
{if $n > 1}<br/>{$n} citations affichées.{/if}
{if $n eq 0}Pas de résultat{/if}
<br/>
<i>&plusmn; &rarr; observation avec identification incertaine</i>
