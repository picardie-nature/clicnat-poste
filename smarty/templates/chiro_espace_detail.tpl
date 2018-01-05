{if $u->acces_chiros}
<p class="directive">Nom du site / référence</p>
<p class="valeur">
    {$espace->reference}
    {if $espace->a_prospecter()}
	<small><a href="javascript:chiro_retirer_prospection({$espace->id_espace});">retirer des prospections</a></small>
    {else}
	<small><a href="javascript:chiro_ajouter_prospection({$espace->id_espace});">ajouter aux prospections</a></small>
    {/if}
    -
    <small><a href="javascript:chiro_ouvre_w_propriete({$espace->id_espace});">modifier</a></small>
</p>
{assign value=$espace->get_commentaires() var=commentaires}
{if $commentaires|@count > 0}
	<a href="javascript:chiro_ouvre_commentaire_espace({$espace->id_espace});">Ouvrir les commentaires ({$commentaires|@count})</a><br/>
	<div id="commentaires_{$espace->id_espace}" class="chiros_commentaire_invis">
		{foreach from=$commentaires item=c}
			<div style="background-color: yellow; margin: 4px;">
				<i><small>de {$c->utilisateur} le {$c->date_commentaire|date_format:"%d-%m-%Y"}</small></i><br/>
				<b>{$c->commentaire}</b>
			</div>
		{/foreach}
	</div>
{/if}
<a href="javascript:chiro_ouvre_commentaire_espace_editeur({$espace->id_espace});">Ajouter un commentaire</a><br/>
{foreach from=$espace->get_tags() item=t}
    {if strlen($t.v_text) > 0}
	<b>{$t.lib}</b><br/>
	{$t.v_text}<br/>
	<br/>
    {/if}
{/foreach}
{else}
    Problème de droit d'accès
{/if}
