{include file="poste_head.tpl" titre_page="liste : $liste"}
<h1>Liste d'espèces : {$liste}</h1>
<div class="bobs-table">
<table width="80%">
	<thead>
	<tr>
		<th>Nom français</th>
		<th>Nom scientifique</th>
		<th></th>
	</tr>
	</thead>
	<tbody>
{foreach from=$liste->liste_especes() item=e}
	<tr>
		<td><a href="?t=espece_detail&id={$e.id_espece}" title="Consulter la fiche espèce">{$e.nom_f}</a></td>
		<td><a href="?t=espece_detail&id={$e.id_espece}" title="Consulter la fiche espèce">{$e.nom_s}</a></td>
		<td><a href="?t=liste_espece&id={$liste->id_liste_espece}&retirer_id_espece={$e.id_espece}" title="Retirer de la liste">suppr.</a></td>
	</tr>
{foreachelse}
	<tr>
		<td colspan="2">Liste vide</td>
	</tr>
{/foreach}
	</tbody>
</table>
<h1>Opérations sur la liste d'espèces</h1>
<div class="bobs-demi">
	<div class="bobs-demi-titre">Ajouter une liste d'identifiants INPN (cd_nom ou cd_ref)</div>
	<div class="bobs-demi-interieur">
		{foreach from=$tab_inpn_erreurs item=e}
			{$e.id} : {$e.msg}<br/>
		{/foreach}
		<form method="post" action="?t=liste_espece&id={$liste->id_liste_espece}">
			<textarea name="inpn_liste_espece" cols=40 rows=8></textarea><br/>
			<input type="submit" value="Ajouter cette liste"/>
		</form>
	</div>
</div>

<div class="bobs-demi">
	<div class="bobs-demi-titre">Autres opérations</div>
	<div class="bobs-demi-interieur">
		<ul>
			<li><a href="?t=liste_espece&id={$liste->id_liste_espece}&vider=1">Vider la liste</a></li>
			<li><a href="?t=liste_espece&id={$liste->id_liste_espece}&supprimer=1">Supprimer la liste</a></li>
			<li><a href="?t=liste_espece&id={$liste->id_liste_espece}&creer_extraction=1">Créer une extraction</a></li>
		</ul>
	</div>
</div>

<div class="bobs-demi">
	<div class="bobs-demi-titre">Ajouter une liste d'identifiants espèce (id_espece)</div>
	<div class="bobs-demi-interieur">
		{foreach from=$tab_id_erreurs item=e}
			{$e.id} : {$e.msg}<br/>
		{/foreach}
		<form method="post" action="?t=liste_espece&id={$liste->id_liste_espece}">
			<textarea name="id_especes_liste_espece" cols=40 rows=8></textarea><br/>
			<input type="submit" value="Ajouter cette liste"/>
		</form>
	</div>
</div>
<div class="bobs-demi">
	<div class="bobs-demi-titre">Ajouter depuis une liste de noms vernaculaire d'espèces</div>
	<div class="bobs-demi-interieur">
		{foreach from=$tab_nom_erreurs item=e}
			{$e.txt} : {$e.msg}<br/>
		{/foreach}
		<form method="post" action="?t=liste_espece&id={$liste->id_liste_espece}">
			<textarea name="nom_especes_liste_especes" cols=40 rows=8>{foreach from=$tab_nom_erreurs item=e}{$e.txt}
{/foreach}</textarea><br/>
			<input type="submit" value="Ajouter cette liste"/>
		</form>
	</div>
</div>

<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
