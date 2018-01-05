{include file="poste_head.tpl" titre_page="Flux"}
{literal}
<style>
.flux-content {
	min-height: 150px;
	background-color: #efefef;
	padding: 5px;
}

.flux-attente {
	background-color: #afafaf;
}

#flux > h1, #flux * h2 {
	text-align:center;
}
</style>
{/literal}
<div>
	Commune : <input type="text" id="z_commune" placeholder="commune">
	Espèce : <input type="text" id="z_espece" placeholder="espèce">
</div>
<div>
	<ul>
	{foreach from=$extraction->conditions item=c name=l key=k}
		<li>{$c} <a href="?t=flux&action=retirer&n={$k}">retirer</a></li>
	{/foreach}
	</ul>
</div>
<div id="timeline"></div>
<div id="flux"></div>
{literal}
<script src="js/flux.js"></script>
<script>
flux_chargement();
</script>
{/literal}
{include file="poste_foot.tpl"}
