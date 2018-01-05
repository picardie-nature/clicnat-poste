{include file="poste_head.tpl" titre_page="liste : $liste"}
<h1>Liste d'espaces : {$liste}</h1>
<div class="bobs-table">
<table width="80%">
	<thead>
	<tr>
		<th>Nom</th>
		<th>Référence</th>
		<th>#</th>
		<th></th>
	</tr>
	</thead>
	<tbody>
{foreach from=$liste->liste_espaces() item=e}
	<tr>
		<td><a id_espace="{$e.id_espace}" class="nom_espace">{if $e.nom}{$e.nom}{else}sans nom{/if}</td>
		<td>{$e.reference}</td>
		<td><a href="?t=espace&table={$e.espace_table}&id_espace={$e.id_espace}">{$e.id_espace}</a></td>
		<td><a href="?t=liste_espace&id={$liste->id_liste_espace}&enlever={$e.id_espace}">x</a></td>
	</tr>
{foreachelse}
	<tr>
		<td colspan="2">Liste vide</td>
	</tr>
{/foreach}
	</tbody>
</table>
</div>

<h1>Opérations sur la liste d'espaces</h1>

<div class="bobs-demi">
	<div class="bobs-demi-titre">Ajouter une liste d'identifiants</div>
	<div class="bobs-demi-interieur">
		<form method="post" action="?t=liste_espace&id={$liste->id_liste_espace}">
			<textarea name="ajouter_ids" cols=40 rows=8></textarea><br/>
			<input type="submit" value="Ajouter cette liste"/>
		</form>
	</div>
</div>


<div class="bobs-demi">
	<div class="bobs-demi-titre">Opérations</div>
	<div class="bobs-demi-interieur">
		<ul>
			<li><a href="?t=liste_espace&id={$liste->id_liste_espace}&vider=1">Vider la liste</a></li>
			<li><a href="?t=liste_espace&id={$liste->id_liste_espace}&supprimer=1">Supprimer la liste</a></li>
			<li><a href="?t=liste_espace&id={$liste->id_liste_espace}&creer_extraction=1">Créer une extraction</a></li>
		</ul>
		<ul>
			<li><a href="?t=liste_espace&id={$liste->id_liste_espace}&telecharger_kml=1">Télécharger KML</a></li>
			<li><a href="?t=liste_espace&id={$liste->id_liste_espace}&telecharger_shp_englob=1">Télécharger SHP polygone englobant</a></li>
		</ul>
		<ul>
			<li><a href="?t=liste_espace_carte&id={$liste->id_liste_espace}">Voir la carte</a></li>
			<li><a href="?t=liste_espace_carte_fs&id={$liste->id_liste_espace}">Voir la carte en plein écran</a></li>
		</ul>
	</div>
</div>

<div class="bobs-demi">
	<div class="bobs-demi-titre">Modifier</div>
	<div class="bobs-demi-interieur">
		<form method="post" action="?t=liste_espace&id={$liste->id_liste_espace}">
			Nom :<br/>
			<input type="text" width="60" name="nom" value="{$liste->nom}"/><br/><br/>
			Mention :<br/>
			<input type="text" width="60" name="mention" value="{$liste->mention}"/><br/><br/>

			<input type="submit" value="Enregistrer"/>
		</form>
	</div>
</div>
<div class="bobs-demi">
	<div class="bobs-demi-titre">Importer un fichier KML</div>
	<div class="bobs-demi-interieur">
		{if !$choix_import_kml}
		<p>Toutes les géométries présentent dans le fichier KML seront importées dans la liste.</p>
		<form method="post" action="?t=liste_espace&id={$liste->id_liste_espace}" enctype="multipart/form-data">
			<input name="kml" type="file"/>
			<input type="submit" value="Envoyer le fichier"/>
		</form>
		{else}
		<form method="get" action"index.php">
			<p>Vous pouvez choisir quel attributs de votre fichier KML seront utilisés pour l'import.</p>
			<input type="hidden" name="t" value="liste_espace"/>
			<input type="hidden" name="id" value="{$liste->id_liste_espace}"/>
			<input type="hidden" name="import_kml_suite" value="1"/>
			Attribut nom : <select name="nom">
				<option value=""></option>
				{foreach from=$choix_import_kml item=type key=nom}
					<option value="{$nom}">{$nom} ({$type})</option>
				{/foreach}
			</select><br/>
			Attribut référence : <select name="reference">
				<option value=""></option>
				{foreach from=$choix_import_kml item=type key=nom}
					<option value="{$nom}">{$nom} ({$type})</option>
				{/foreach}
			</select>
			<input type="submit" value="Importer le fichier"/>
		</form>
		{/if}
	</div>
</div>
<div class="bobs-demi">
	<div class="bobs-demi-titre" id="table_attributaire">Table attributaire</div>
	<div class="bobs-demi-interieur">
		<table class="table" width="80%">
			<tr>
				<th>Nom</th>
				<th>Type</th>
				<th>Valeurs</th>
				<th>Actif</th>
			</tr>
		{foreach from=$liste->attributs() item=attr}
			<tr>
				<td>{$attr.name}</td>
				<td>{$attr.type}</td>
				<td>{$attr.values}</td>
				<td>{$attr.active}</td>
			</tr>
		{foreachelse}
			<tr><td colspan="4">Aucun attribut</td></tr>
		{/foreach}
		</table>
		<fieldset>
			<legend>Ajout d'un attribut</legend>
			<form method="post" action="?t=liste_espace&id={$liste->id_liste_espace}#table_attributaire">
				<input type="hidden" name="action" value="ajouter_attribut"/>
				Nom du champ <input name="name" type="text" width="30"><br/>
				Type 
				<select name="type">
					<option value="string">chaîne de caractères</option>
					<option value="int">entier</option>
				</select><br/>
				Valeurs <input type="text" width="100" name="values"><br/>
				<i>exemple : "bois,haie,herbe haute"</i><br/>
				<input type="submit" value="ajouter"/>
			</form>
		</fieldset>
	</div>
</div>

<script>
{literal}
	J('.nom_espace').click(function (e) {
		console.log(e);
		var a = J(e.currentTarget);
		var id_espace = a.attr('id_espace');
		var nouveau_nom = prompt('Nouveau nom', a.html());
		if (nouveau_nom) {
			document.location.href+='&id_espace='+id_espace+'&renomme='+nouveau_nom;
		}
		
	});
{/literal}
</script>
<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
