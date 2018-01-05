{include file="poste_head.tpl"}
<h1 style="margin-bottom: 2px;">Liste des personnes disposant d'un accès.</h1>
{if $u->acces_chiros}
	<a href="?t=chiros">retour</a>
	<small>(cette liste n'est pas celle des membres du réseau)</small>
	<ul>
	    {foreach from=$liste item=p}
	    	<li>{$p.nom} {$p.prenom}</li>
	    {/foreach}
	</ul>
{else}
	<div class="bobs-commtr">Vous n'avez pas accès à cette page</div>
{/if}
{include file="poste_foot.tpl"}
