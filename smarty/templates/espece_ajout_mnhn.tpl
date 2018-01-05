{include file=poste_head.tpl titre_page="Ajout espèce référentiel MNHN"}
<h1>Ajout d'une espèce via le référentiel du MNHN</h1>
<div>Nom scientifique : <input type="text" id="espece"/></div>
<script>
{literal}
    J('#espece').autocomplete({source: '?t=espece_inpn_autocomplete',
	select: function (event,ui) {
	    document.location.href = '?t=espece_ajout_mnhn&id='+ui.item.value;
	    event.target.value = '';
	    return false;
	}
    });
{/literal}
</script>

{if $espece_inpn}
	Règne : {$espece_inpn->regne}<br/>
	Embranchement : {$espece_inpn->phylum}<br/>
	Classe : {$espece_inpn->classe}<br/>
	Ordre : {$espece_inpn->ordre}<br/>
	Famille : {$espece_inpn->famille}<br/>
	Nom scientifique : <b>{$espece_inpn->lb_nom}</b> <i>{$espece_inpn->lb_auteur}</i><br/>
	Rang : {$espece_inpn->rang_es}<br/>
	Nom français : {$espece_inpn->nom_vern}<br/>
	CD_NOM : {$espece_inpn->cd_nom}<br/>
	CD_REF : <a href="?t=espece_ajout_mnhn&id={$espece_inpn->cd_ref}">{$espece_inpn->cd_ref}</a><br/>
	<hr/>
	{foreach from=$espece_inpn->get_especes() item=espece}
		Déjà présent dans la base <a href="?t=espece_detail&id={$espece->id_espece}">{$espece}</a>
	{foreachelse}
		<a href="?t=espece_ajout_mnhn&id={$espece_inpn->cd_ref}&ajouter=1">Ajouter à la base</a>
	{/foreach}
{/if}

{include file=poste_foot.tpl}
