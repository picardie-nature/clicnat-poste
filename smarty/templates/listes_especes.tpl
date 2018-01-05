{include file="poste_head.tpl" titre_page="Listes d'espèces"}
<h1>Liste d'espèces</h1>
<h2>Vos listes</h2>
<script>
{literal}
function liste_supprimer(i) {
	if (confirm('Supprimer la liste ?'))
		document.location.href = '?t=listes_especes&supprimer='+i;
}
{/literal}
</script>
<ul>
{foreach from=$u->listes_especes() item=l}
	<li><a href="?t=liste_espece&id={$l->id_liste_espece}">{$l}</a></li>
{foreachelse}
	<li>Vous n'avez pas encore créé de liste d'espèces.</li>
{/foreach}
</ul>
<br/><br/>
<h2>Créer une nouvelle liste</h2>
<form method="post" action="?t=listes_especes">
	Créer une nouvelle liste : <br/>
	<input type="text" name="nouveau_nom" value="" />
	<input type="submit" value="Créer une nouvelle liste"/>
</form>
{include file="poste_foot.tpl"}
