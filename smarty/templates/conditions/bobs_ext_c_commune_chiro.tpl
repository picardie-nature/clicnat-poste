<input type="text" name="srch_commune" id="srch_commune"/>
<br/>
<input type="hidden" name="id_espace" id="src_com_id"/>
<input type="hidden" name="classe" value="bobs_ext_c_commune_chiro"/>
<small>indiquez ici le nom d'une commune</small>
<div id="srch_commune_choix" class="autocomplete"></div>
<script>
{literal}
function selection_commune(text, li) {
    document.getElementById('src_com_id').value = li.id;
}
new Ajax.Autocompleter('srch_commune', 'srch_commune_choix', '?t=commune_autocomplete', {afterUpdateElement: selection_commune});
{/literal}
</script>
