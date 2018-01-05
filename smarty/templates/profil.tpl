{include file="poste_head.tpl"}
<h1>Profil de {$u}</h1>

Inscrit dans les réseaux 
<ul>
{foreach from=$u->get_reseaux() item=r}
	<li>{$r}</li>	
{/foreach}
</ul>

<p>Cette page est en cours de réalisation</p>

{include file="poste_foot.tpl"}
