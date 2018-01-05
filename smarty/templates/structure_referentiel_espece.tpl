{include file="poste_head.tpl"}
<h1>Structure - gestion du référentiel espèce</h1>
<h3>Le référentiel</h3>
<div class="bobs-table" style="max-height:300px; overflow:scroll;">
	<table width="100%">
	<thead>
		<tr>
			<th>Votre code</th>
			<th>Notre code</th>
			<th>Code MNHN</th>
			<th>Nom de l'espèce</th>
			<th></th>
		</tr>
	</thead>
	{foreach from=$ref->get_referentiel() item=e}
	<tbody>
		<tr>		
			<td align="center">{$e.id_tiers}</td>
			<td align="center">{$e.id_espece}</td>
			<td align="center">{$e.taxref_inpn_especes}</td>
			<td>{$e.nom_s} - <i>{$e.nom_f}</i></td>
			<td><a href="?t=structure_referentiel_espece&act=retirer&id_tiers={$e.id_tiers}">suppr.</a></td>
		</tr>
	</tbody>
	{/foreach}
	</table>
</div>
<h3>Ajouter une référence</h3>
<table width="100%">
	<tr>
		<td valign="top">
			Rechercher une espèce  : <input type="text" id="recherche" />
		</td>
		<td valign="top">
			<form method="post" action="?t=structure_referentiel_espece&act=ajout">
				Notre code espèce : <input type="text" name="id_espece" id="f_id_espece" /><br/>
				Nom: <b><span id="nom"></span></b><br/>
				Votre code espèce : <input type="text" name="id_tiers" id="f_id_tiers" />
				<input type="submit" value="ajouter"/>
			</form>
		</td>
	</tr>
</table>
<h3>Télécharger le référentiel <a href="?t=structure_referentiel_espece&act=telecharger"><img src="icones/document-save.png"/></a></h3>
<script>
	//{literal}
	J('#recherche').autocomplete({source: '?t=autocomplete_espece', select: function (event,ui) {
			log(ui.item);
			event.target.value = '';
			J('#nom').html(ui.item.label);
			J('#f_id_espece').val(ui.item.value);
			return false;
		}});
	//{/literal}
</script>
{include file="poste_foot.tpl"}
