{if $voir_nicheur}
<a style="color:blue;" href="?t=atlas_oiseaux_nicheurs_r_carre&id_espace={$espace->id_espace}">voir les statuts retenus et LPO</a><br/>
<h3>Liste des oiseaux nicheurs 2009-2011</h3>
Légende : 
<span class="bobs-nicheur-possible">possible</span>, 
<span class="bobs-nicheur-probable">probable</span>, 
<span class="bobs-nicheur-certain">certain</span>.

{assign var=nicheurs value=$espace->get_oiseaux_nicheurs()}
{foreach from=$nicheurs item=especes key=annee}
	<h4>Pour {$annee}</h4>
	{foreach from=$especes key=id_espece item=o}
		<a  alt="{$o.statut}" href="?t=atlas_oiseaux_nicheurs_espece&id={$id_espece}"><span class="bobs-nicheur-{$o.statut}">{$o.objet}</span></a>
	{/foreach}
{/foreach}
{else}
<h3>Liste des oiseaux hivernants 2009-2011</h3>
{foreach from=$espace->get_oiseaux_hivernant_2010_2011() item=e name=hivernant}
    <a href="?t=espece_detail&id={$e.id_espece}" title="{$e.nom_s}">{$e.nom_f}</a>
{foreachelse}
    Aucune
{/foreach}

<p>{if $smarty.foreach.hivernant.total > 1} {$smarty.foreach.hivernant.total} espèces recensées{/if}</p>
{/if}
<h3>Attribution du carré aux observateurs</h3>
<ul>
{foreach from=$espace->responsables_carre() item=resp}
    <li>{$resp.nom} {$resp.prenom}</li>
{foreachelse}
    Carré libre
{/foreach}
</ul>

<h3>Liste des communes sur le carré</h3>
{foreach from=$espace->liste_communes() item=commune}
    {$commune.commune}
{/foreach}
