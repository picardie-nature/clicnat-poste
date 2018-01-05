{foreach from=$citation->get_commentaires() item=c}
	{if $c->type_commentaire=='attr'}
		<small>
			<i>Modification le {$c->date_commentaire_f} par {$c->utilisateur}</i>
			<pre><p class="bobs-commtr">{$c->commentaire}</p></pre>
		</small>
	{else}
		le {$c->date_commentaire_f} par {$c->utilisateur}
		<p class="bobs-commtr">{$c->commentaire}</p>
	{/if}
{/foreach}