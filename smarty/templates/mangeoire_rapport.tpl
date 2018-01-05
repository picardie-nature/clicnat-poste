{include file="mangeoire_head.tpl" titre_page="Rapport"}
<br/>
<div class="desc">
	<h1>Quelques chiffres pour votre mangeoire {$mangeoire->nom}</h1>
	<div>
	<h2>Les espèces vues en {$smarty.now|date_format:"%Y"}</h2>
		<ul>
		{foreach from=$mangeoire->liste_especes() item=e}
			<li><a href="http://obs.picardie-nature.org/?page=fiche&id={$e.id_espece}" target="_blank">{$e.nom_f}</a></li>
		{foreachelse}
			<li>Pas d'observations</li>
		{/foreach}
		</ul>
	</div>
</div>
{include file="mangeoire_foot.tpl"}
