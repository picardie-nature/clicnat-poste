
Numéro d'observateur : 
<input type="text" id='sid' name="id_utilisateur" value="" size=5 maxlength=4/><br/>
(Votre numéro : {$u->id_utilisateur})<br/>
Rechercher un autre observateur par son nom :<input type="text" id="sid2"><br/>
<input type="hidden" name="classe" value="bobs_ext_c_auteur"/>

<script>
{literal}
function s_obs_autocomp_s(evt, ui) {
	J('#sid').val(ui.item.id);
	J('#sid2').val('');
	return false;
}
J('#sid2').autocomplete({source: '?t=observateur_autocomplete2'});
J('#sid2').bind('autocompleteselect', s_obs_autocomp_s);
{/literal}
</script>
