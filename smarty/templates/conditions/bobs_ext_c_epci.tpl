<input type="hidden" name="classe" value="bobs_ext_c_epci"/>
<p class="directive">Observations dans EPCI</p>
<p class="valeur"><select name="id_espace">
{foreach from=$espaces_epci item=e}
    <option value="{$e.id_espace}">{$e.nom} ({$e.reference})</option>
{/foreach}
</select>
</p>
<br/>
