<input type="hidden" name="classe" value="bobs_ext_c_structure"/>
<p class="directive">Observations dans un site géré</p>
<p class="valeur"><select name="id_espace">
{foreach from=$espaces_structure item=e}
    <option value="{$e.id_espace}">{$e.structure}-{$e.reference} - {$e.nom}</option>
{/foreach}
</select>
</p>
<br/>
