Nom du taxon
<input type="hidden" name="id" id="id_espece">
<input type="hidden" name="classe" value="bobs_ext_c_taxon_branche"/>
<small>indiquez ici le nom d'un taxon</small>
<input type="text" id="srch">
<script>
{literal}
J('#srch').autocomplete({
	source: '?t=autocomplete_espece&nohtml=1&affiche_expert=1',
	select: function (event,ui) {
		event.preventDefault();
		J('#id_espece').val(ui.item.value);
		J(this).val(ui.item.label);
		return false;
	}
});
{/literal}
</script>

