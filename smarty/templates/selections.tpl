{include file="poste_head.tpl" titre_page="Liste des sélections"}
<script>
    {literal}
    function drop_selection(id) {
		J('#dialog-drop-sel').dialog({
		    modal:true,
		    buttons: {
				Supprimer: function () {
				    document.location.href="?t=selection_action&action=suppr&sel="+id;
				},
				Annuler: function () {
				    J(this).dialog('close');
				}
		    }
		});
    }
    {/literal}
</script>
<div style="display:none;">
    <div id="dialog-drop-sel" title="Suppression">
		<p>Confirmez-vous la suppression de cette sélection de citations ?</p>
    </div>
</div>
<h1>Vos sélections : {$u->selections_n()}</h1>
{foreach from=$msgs item=msg}
	{$msg}<br/>
{/foreach}
<form method="post" action="?t=selections">
<div style="max-height: 400px; height:400px; overflow:scroll;">
<div class="bobs-table">
	<table width="100%">
	    <thead>
		    <tr>
				<th>Nom</th>
				<th>Date de création</th>
				<th>Nombre de citations</th>
				<th></th>
		    </tr>
	    </thead>
	    <tbody>
	    {foreach from=$u->selections() item=s}
	    <tr>
	    		{assign var=n value=$s->n()}
			<td>
				<a href="?t=selection&sel={$s->id_selection}" style="display:block;">{$s->nom_selection}</a>
			</td>
			<td align="center">{$s->date_creation|date_format:"%d-%m-%Y"}</td>
			<td align="center">{$n}</td>
			<td align="left">
			    <input type="checkbox" name="sel_{$s->id_selection}" value="1" />
			</td>
	    </tr>
	    {/foreach}
	    </tbody>
	</table>
</div>
</div>
	<div style="text-align:right;">
		Pour les sélections cochées : 
		<select name="action">
			<option value="fusionner">fusionner le contenu</option>
			<option value="supprimer">supprimer</option>
		</select>
		<input type="submit" value="Lancer"/>
	</div>
</form>
<div class="bobs-commtr">
    Les sélections sont des listes de citations, vous pouvez
    en ajouter, en supprimer en divers endroits de l'application.
    Il est aussi possible d'exporter ces listes dans un tableur
    ou de créer des cartes.
</div>
<h3>Créer une nouvelle sélection</h3>
<form method="post" action="?t=selections">
	<p class="directive">Nom de la nouvelle sélection</p>
	<p class="valeur"><input type="text" name="nouvelle_selection" value=""/></p>
	<input type="submit" value="Créer une nouvelle sélection"/>
</form>
<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
