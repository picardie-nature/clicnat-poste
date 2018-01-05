{include file="poste_head.tpl" titre_page="Recherche"}
<script src="http://deco.picardie-nature.org/prototype/prototype.js" language="javascript"></script>
<script src="http://deco.picardie-nature.org/scriptaculous/effects.js" language="javascript"></script>
<script src="http://deco.picardie-nature.org/scriptaculous/controls.js" language="javascript"></script>
{literal}
<style>
a { color:blue; }

#extraction-top {
	height: 205px;
}
.conditions-top-in h1, #extraction-w h1 {
	padding:3px;
	background-color: rgb(198,229,72);
	color:white;
	font-size: 1em;
}

div#extraction-w  {
	background-color: #efefef;
}
div#extraction-i  {
	padding: 10px;
}

.conditions-top-in {
    height: 180px;
    width: 30%;
    overflow: auto;
    border-style: dashed;
    border-color: #e4e4e4;
    float:left;
    margin-left: 10px;
    background-color: #efefef;
}

</style>
{/literal}
{assign var=conditions_dispo value=$extract->get_conditions_dispo()}
<h1>Rechercher et consulter des observations</h1>
{if $msg}<i>{$msg}</i>{/if}
<div id="extraction-top">
    <div class="conditions-top-in">
	<h1>Choisissez vos critères ({$conditions_dispo|@count})</h1>
	<ul>
	{foreach from=$conditions_dispo item=titre key=classe}
		<li><a href="?t=journal&act=condition_ajoute&classe={$classe}">{$titre}</a></li>
	{/foreach}
	</ul>
    </div>
    <div class="conditions-top-in">
	<h1>Critères sélectionnés ({$extract->conditions|@count})</h1>
	<ul>
	{foreach from=$extract->conditions item=condition key=id}
		<li><a href="?t=journal&act=condition_retirer&n={$id}">{$condition}</a></li>
	{/foreach}
	</ul>
	<a href="?t=journal&act=reset">Remettre à zéro l'extraction</a>
    </div>
    <div class="conditions-top-in">
	<h1>Résultat</h1>
	{if $extract->ready()}
	    <small>
	    <form method="post" action="?t=journal&act=selection_new">
		Placer les données dans une nouvelle selection :
		<input type="text" name="sname"/>
		<input type="submit" value="créer la sélection"/>
	    </form>
	    </small>
	    Nombre de citations : {$compte}<br/>
	    {assign var=especes value=$extract->especes()}
	    Espèces : {$especes->count()}
	    <table>
	    {foreach from=$especes item=espece}
	    	{assign var=refreg value=$espece->get_referentiel_regional()}
	    	<tr>
			<td><a href="?t=espece_detail&id={$espece->id_espece}" title="{$espece->nom_s}">{$espece}</a></td>
			<td>{$refreg.indice_rar}</td>
			<td>{$refreg.categorie}</td>
		</tr>
	    {/foreach}
	    </table>
	{else}
	    Le nombre de critères n'est pas suffisant,
	    ajoutez des critères proposés dans la
	    première boite.
	{/if}
    </div>
</div>
<div id="extraction-w">
    {if $act == 'condition_ajoute'}
    <h1>Nouvelle condition</h1>
    <div id="extraction-i">
	    <form method="post" action="?t=journal&act=condition_enreg" id="formulaire_condition">
		{include file="conditions/$cl.tpl"}
		<input type="submit" value="ajouter cette condition"/>
	    </form>
    </div>
    {/if}
    {if $act == 'selection_new'}
    <h1>Résultats</h1>
    <div id="extraction-i">
	    <a href="?t=selection&sel={$id_selection}">Voir la nouvelle sélection</a>
    </div>	 
    {/if}
</div>
<br/><br/>
<div class="bobs-demi">
	<div class="bobs-demi-titre">Comment procéder ?</div>
	<div class="bobs-demi-interieur">
	    Cette interface vous permet de faire des recherches dans vos données (et celles mises à votre disposition).<br/><br/>
	    <ul>
		<li>Dans la première case cliquez sur les critères de recherche, un formulaire vous invitera à les compléter.<br/>
		    Vous pouvez ajouter plusieurs fois le même critère.</li>
		<li>Dans la deuxième case vous trouvez les critères déjà appliqués, en cliquant dessus vous pouvez les retirer.</li>
		<li>Le nombre de citations sélectionnées est affiché dans la 3ème case.</li>
		<li>Pour obtenir le résultat entrez un nom pour votre de recherche dans la zone de saisie de la troisième case
		    et cliquez sur "créer la sélection". Un lien apparaît en bas de page pour la consulter. Elle est également enregistrée vous pouvez
		    donc la retrouver en suivant le lien "Sélection" dans le menu à droite.</li>
	    </ul>
	 </div>
</div>
<div class="bobs-demi">
	{assign var=nselsmax value=15}
	{assign var=sels value=$u->selections()}
	<div class="bobs-demi-titre">Sélections de données précédentes
		{if $sels|@count > 0}
			{if $sels|@count > $nselsmax}
				Recherches les plus récentes
			{else}
				Vos recherches précédentes
			{/if}
		{else}
			Pas de résultat de recherche enregistré
		{/if}

	</div>
	<div class="bobs-demi-interieur">
		{if $sels|@count > 0}
			{if $sels|@count > $nselsmax}
				Les {$nselsmax} plus récentes : <a href="?t=selections">voir la liste des {$sels|@count} sélections de données</a>
			{/if}
			<div class="bobs-table">
			<table>
				<tr>
					<th>Nom</th>
					<th>Date de création</th>
					<th>N. de citations</th>
				</tr>
				{foreach from=$sels item=s name=s}
				{if $smarty.foreach.s.index < $nselsmax} 
					<tr>
						<td><a href="?t=selection&sel={$s->id_selection}">{$s}</a></td>
						<td align="center">{$s->date_creation|date_format:"%d-%m-%Y"}</td>
						<td align="center">{$s->n()}</td>
					</tr>
				{/if}
			{/foreach}
			</table>
			</div>
		{/if}

	</div>
</div>
<div class="bobs-demi">
	<div class="bobs-demi-titre">Listes de critères d'extractions enregistrées </div>
	<div class="bobs-demi-interieur">
	<fieldset><legend>Enregistrer les critères actuellement sélectionnés</legend>
	<form method="post" action="?t=journal&act=extraction_sauve">
		Nom de la liste<br/> <input type="text" name="ename"/>
		<input type="submit" value="Enregistrer"/>

		<p>Il s'agit ici d'enregistrer une liste de critères d'extraction afin de pouvoir la réutiliser ultérieurement</p>
	</form>
	</fieldset>

	<h4>Vos listes de critères : {$u->id_extraction_utilisateur_flux}</h4>
	<div class="bobs-table">
	<table>
		<tr>
			<th>Nom</th>
			<th></th>
			<th></th>
			<th>Source de mon flux <br/>d'observation</th>
		</tr>
		{foreach from=$u->extraction_liste() item=ext}
		<tr>
			<td><a href="?t=journal&act=extraction_charge&id={$ext.id_extraction}">{$ext.nom}</a></td>
			<td><a href="?t=journal&act=extraction_charge&id={$ext.id_extraction}">charger</a></td>
			<td><a href="?t=journal&act=extraction_supprime&id={$ext.id_extraction}">suppr.</a></td>
			<td>
			{if $u->id_extraction_utilisateur_flux != $ext.id_extraction}
				<a href="?t=journal&act=extraction_choix_flux&id={$ext.id_extraction}">choisir</a>
			{/if}
			</td>
		</tr>
		{/foreach}
	</table>
	</div>
	</div>
</div>
<div style="clear:both;"></div>

{include file="poste_foot.tpl"}
