<input type="hidden" name="classe" value="bobs_ext_c_classe"/>
Classe <select name="cl">
{foreach from=$classes item=c}
	<option value="{$c.id}">{$c.lib}</option>
{/foreach}
</select>
