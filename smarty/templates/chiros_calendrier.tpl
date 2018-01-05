{include file="poste_head.tpl" titre_page="Chiros - Calendrier"}
{literal}
<style>
    .cache { display:none; }
    h3 {margin-bottom: 2px;}
</style>
<script language="javascript">
    function oloc(id) {
	J('#loc'+id).show(1000);
    }
    function cloc(id) {
	J('#loc'+id).hide(500);
    }
    function uniquement_moi()
    {
	J('.paspresent').hide(500);
    }
    function toutes() {
	J('.paspresent').show(500);
    }
</script>
{/literal}
<h1 style="margin-bottom: 2px;">Chiros - Calendrier</h1>
{if $u->acces_chiros}
<div style="float:right; width:180px;">
    <h1>Dates</h1>
    {assign var=prev value=''}
    <ul>
    {foreach from=$dates item=date}
	{if $prev != $date->date_sortie_tstamp}
	<li><a href="#date{$date->id_date}">{$date->date_sortie_tstamp|date_format:"%d-%m-%Y"}</a></li>
	{/if}
	{assign var=prev value=$date->date_sortie_tstamp}
    {/foreach}
    </ul>
</div>

<a href="?t=chiros">retour</a> -
<a href="javascript:uniquement_moi();">ne voir que mes dates</a> -
<a href="javascript:toutes();">voir toutes les dates</a>
{assign var=prev value='aa'}
{foreach from=$dates item=date}
    {if $prev != $date->date_sortie_tstamp}
	<h3>{$date->date_sortie_tstamp|date_format:"%d-%m-%Y"}</h3>
    {/if}
    {assign var=je_suis_pas_dedans value=true}
    {foreach from=$date->get_participants() item=p}
	{if $p.id_utilisateur == $u->id_utilisateur}
	    {assign var=je_suis_pas_dedans value=false}
	{/if}
    {/foreach}
    {assign var=prev value=$date->date_sortie_tstamp}
    <a name="date{$date->id_date}"></a>
    <div {if $je_suis_pas_dedans}class="paspresent"{/if}>
	{assign var=espace value=$date->get_espace()}
	{assign var=commune value=$espace->get_commune()}
	Gîte ou repère <b>{$espace->nom}</b> (<a href="javascript:oloc({$date->id_date})">localisation</a>)
	par
	{foreach from=$date->get_participants() item=p}
	    {$p.nom} {$p.prenom},
	    
	{/foreach}
	{if $je_suis_pas_dedans == true}
	    <a href="?t=chiros_calendrier&participer={$date->id_date}#date{$date->id_date}">participer</a>
	{else}
	    <a href="?t=chiros_calendrier&annuler={$date->id_date}">annuler</a>
	{/if}
	{if strlen($date->commentaire) > 0}<p class="valeur">commentaire : {$date->commentaire}</p>{/if}
	<div class="cache" id="loc{$date->id_date}">
	    <img src="?t=espace_chiro_vignette&id={$espace->id_espace}" onclick="javascript:cloc({$date->id_date});"/><br/>
	    <small>Coordonnées GPS : {$espace->get_x()},{$espace->get_y()}<br/>
	    sur la commune de {$commune->nom} (cliquer sur l'image pour réduire)</small><br/>
	</div>
    </div>
{/foreach}
{else}
<div class="bobs-commtr">Vous n'avez pas accès à cette page</div>
{/if}

{include file="chiros_outils.tpl"}
<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
