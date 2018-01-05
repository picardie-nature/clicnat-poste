{include file="poste_head.tpl" titre_page="Étiquette - $tag"}
<h1>Étiquette {$tag}</h1>
<div class="bobs-demi">
	<div class="bobs-demi-titre">{$tag}</div>
	<div class="bobs-demi-interieur">
	{if $tag->have_childs()}
		{assign var=childs value=$tag->get_childs()}
		<b>Étiquettes associées : {$childs|@count}</b><br/>
		<ul>
		{foreach from=$childs item=child}
			<li><a href="?t=tag_infos&id={$child.id_tag}">{$child.lib}</a></li>
		{/foreach}
		</ul>
	{/if}
	<b>Classes d'espèces associables</b>
	<ul>
	{foreach from=$tag->classes() item=classe}
		<li>{$classe}</li>
	{/foreach}
	</ul>
	</div>
</div>
<div class="bobs-demi">
	<div class="bobs-demi-titre">Espèces où l'étiquette a été utilisée</div>
	<div class="bobs-demi-interieur">
	{assign var=especes value=$tag->especes()}
	<ul>
	{foreach from=$especes item=espece}
		<li><a href="?t=espece_detail&id={$espece->id_espece}" title="{$espece->nom_s}">{$espece}</li>	
	{/foreach}
	</ul>
	</div>
</div>
{include file="poste_foot.tpl"}
