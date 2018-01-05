<input type="hidden" name="classe" value="bobs_ext_c_liste_especes"/>
L'espèce doit faire partie de la liste :
<select name="id_liste_espece">
	{foreach from=$liste_public item=l}
		<option value="{$l.id_liste_espece}">{$l.nom} (référence)</option>
	{/foreach}
	{foreach from=$liste_perso item=l}
		<option value="{$l.id_liste_espece}">{$l.nom}</option>
	{/foreach}
</select>
