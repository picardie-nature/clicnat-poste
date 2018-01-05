{include file="poste_head.tpl" titre_page="CHR"}
<h1>Comité d'homologation : {$comite}</h1>
<h2>Membres du comité</h2>
{foreach from=$comite->get_members() item=membre name=membre}
	{$membre}{if !$smarty.foreach.membre.last},{else}.{/if}
{/foreach}
<h2>Espèces soumises</h2>
{foreach from=$comite->get_especes() item=espece name=espece}
	<a href="?t=espece_detail&id={$espece->id_espece}">{$espece}</a>{if !$smarty.foreach.espece.last},{else}.{/if}
{/foreach}
{include file=poste_foot.tpl}
