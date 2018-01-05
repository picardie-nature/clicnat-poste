<input type="hidden" name="classe" value="bobs_ext_c_departement"/>
Département : <select name="id_espace">
{foreach from=$departements item=dept}
	<option value="{$dept->id_espace}">{$dept}</option>
{/foreach}
</select>

