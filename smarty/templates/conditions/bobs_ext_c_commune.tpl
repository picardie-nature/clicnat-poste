<br/>
<input type="hidden" name="id_espace" id="src_com_id"/>
<input type="hidden" name="classe" value="bobs_ext_c_commune"/>
<small>indiquez ici le nom d'une commune</small>
<input type="text" name="srch_commune" id="srch_commune"/>
<script>
{literal}
J('#srch_commune').autocomplete({
	source: '?t=autocomplete_commune',
	select: function (event,ui) {
		J('#src_com_id').val(ui.item.value);
		J(this).val(ui.item.label);
		return false;
	}
});
{/literal}
</script>
