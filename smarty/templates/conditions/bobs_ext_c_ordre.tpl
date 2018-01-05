Ordre :
<input type="hidden" name="classe" value="bobs_ext_c_ordre"/>
<select name="ordre">
{foreach from=$ordres item=ordre}
	<option value="{$ordre.ordre}">{$ordre.ordre}</option>
{/foreach}
</select>
