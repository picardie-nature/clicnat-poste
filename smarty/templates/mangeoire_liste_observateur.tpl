{include file="mangeoire_head.tpl" titre_page="Observateurs"}
<br/>
<div class="desc">
	<h1>Les observateurs de la mangeoire {$mangeoire->nom}</h1>
	<div>
		<ul>
		{foreach from=$mangeoire->liste_observateurs() item=o}
			<li>{$o}	
			{if $mangeoire->id_utilisateur eq $o->id_utilisateur}
				<i>Propriétaire</i>
			{else}
				{if $proprietaire}
					<a href="?t=mangeoire_liste_observateur&id={$mangeoire->id_espace}&retirer={$o->id_utilisateur}">retirer</a></li>
				{/if}
			{/if}
		{/foreach}
		</ul>
	</div>
</div>
{if $proprietaire}
<div class="desc">
	<h1>Ajouter un observateur</h1>
	<div>
		Commencer a taper le nom de la personne et cliquez sur son nom quand il apparaît.<br/>
		<input type="text" id="u_ajout">
		<script>
		{literal}
		J('#u_ajout').autocomplete({
			source: "?t=observateur_autocomplete2",
			minLength: 3,
			select: function (e, ui) {
				document.location.href = '?t=mangeoire_liste_observateur&id={/literal}{$mangeoire->id_espace}{literal}&ajouter='+ui.item.id;
			}
		});
		{/literal}
		</script>
	</div>
</div>
{/if}
{include file="mangeoire_foot.tpl"}
