<input type="hidden" name="classe" value="bobs_ext_c_zsc"/>
<p class="directive">Observations dans la ZSC</p>
<p class="valeur"><select name="id_espace">
{foreach from=$espaces_zsc item=e}
    <option value="{$e.id_espace}">{$e.nom}</option>
{/foreach}
</select>
</p>
<br/>