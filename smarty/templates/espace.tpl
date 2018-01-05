{include file="poste_head.tpl" titre_page="Informations sur espace '$espace'"}
<h1>Informations sur l'espace {$espace}</h1>
<pre>
Nom: {$espace->nom}
Type / table : {$espace->get_table()}
Référence : {$espace->reference}
Identifiant clicnat : {$espace->id_espace}
{if $extraction}
Liste d'espèces (attention uniquement les données que vous pouvez consulter):
{foreach from=$extraction->especes() item=e}
	<a href="?t=espece_detail&id={$e->id_espece}">{$e}</a>
{/foreach}
{/if}

Communes :
{foreach from=$espace->get_communes() item=c}
	{$c}
{/foreach}


</pre>
{include file="poste_foot.tpl"}
