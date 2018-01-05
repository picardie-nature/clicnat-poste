Protocoles : 
<select name="texte">
	{foreach from=$protocoles item=nom key=id}
		<option value="{$id}">{$nom}</option>
	{/foreach}
</select>
<input type="hidden" name="classe" value="bobs_ext_c_tag_protocole"/>
