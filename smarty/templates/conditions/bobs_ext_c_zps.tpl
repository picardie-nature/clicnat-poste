<input type="hidden" name="classe" value="bobs_ext_c_zps"/>
<p class="directive">Observations dans la ZPS</p>
<p class="valeur"><select name="id_espace">
{foreach from=$espaces_zps item=e}
    <option value="{$e.id_espace}">{$e.nom}</option>
{/foreach}
</select>
</p>
<br/>