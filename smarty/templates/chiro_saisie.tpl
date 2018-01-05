
<h1>{$cavite->nom}</h1>
<form id="f_chiro_envoi_donnees">
    <input type="hidden" name="id_espace" value="{$cavite->id_espace}" id="saisie_id_espace"/>
    
    <h2>Date</h2>
    <input type="text" size="10" name="date_observation" id="saisie_date_observation"/>
    
    <h2>Observateurs</h2>
    
    <p class="valeur" id="saisie_liste_observateurs"></p>
    Recherchez le nom d'un observateur et cliquez
    sur son nom dans la liste pour l'ajouter
    <input type="text" id="saisie_recherche_nom"/>
    
    <h2>Espèces observées</h2>
    <input type="checkbox" value="1" name="prospection_negative" id="prop_neg"/>
    <label for="prop_neg">Cochez pour indiquer une prospection négative (laisser les autres champs vides).</label>
    <table width="100%">
	<tr>
	    <th>Espèce</th>
	    <th>Effectif</th>
	</tr>
    {foreach from=$especes item=e name=t}
	<tr>
	    <td bgcolor="{if $smarty.foreach.t.index%2==1}#aeaeae{/if}">
		{$e->nom_f} <br/><small><i>{$e->nom_s}</i></small>
	    </td>
	    <td bgcolor="{if $smarty.foreach.t.index%2==1}#aeaeae{/if}" align="center">
		<input type="text" size="3" name="effectif_{$e->id_espece}"/>
	    </td>
	</tr>
    {/foreach}
    </table>
</form>
