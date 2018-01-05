<input type="hidden" name="classe" value="bobs_ext_c_reseau"/>
<select name="id">
{foreach from=$reseaux item=r}
	<option value="{$r->id}">{$r}</option>
{/foreach}
</select>
