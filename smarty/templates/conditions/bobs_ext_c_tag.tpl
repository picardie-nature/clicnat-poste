{include file="partiels/recherche_tag.tpl"}
{literal}
<style>#r_info { display:none; }</style>
<script>
function r_ajoute_tag(i) {
	J('#r_id_tag').val(i);
	J('#r_info').html('');
	J('#formulaire_condition').toggle();
	J('#formulaire_condition').submit();
}
new BoiteRechercheTag(r_ajoute_tag);
</script>
{/literal}
<input type="hidden" name="classe" value="bobs_ext_c_tag"/>
<input type="hidden" name="id_tag" value="" id="r_id_tag"/>
<div id="r_info">ajout du code comportement en cours</div>
