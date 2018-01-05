<input type="hidden" name="classe" value="bobs_ext_c_in_liste_espaces"/>
Liste d'espaces :
<select name="id_liste_espace">
	{foreach from=$u->listes_espaces() item=l}
		<option value="{$l->id_liste_espace}">{$l}</option>
	{/foreach}
</select>
