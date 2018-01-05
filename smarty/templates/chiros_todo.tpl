{include file="poste_head.tpl"}
{literal}
<style>
    h3 {margin-bottom: 2px;}
    .cache {display: none;}
</style>
<script language="javascript">
    function que_sans_date()
    {
	J('.adate').hide(500);
    }
    function voir_tout()
    {
	J('.adate').show(500);
    }

    function oloc(id) {
	J('#loc'+id).show(1000);
    }
    function cloc(id) {
	J('#loc'+id).hide(500);
    }
</script>
{/literal}
<h1>Points inscrits aux prospections</h1>
<a href="javascript:que_sans_date();">Voir que les gîtes sans visite de prévue</a>
<a href="javascript:voir_tout();">Voir tout</a>
<ul>
{foreach from=$points item=point}
    {assign var=calendriers value=$point.obj->get_calendriers()}
    {assign var=commune value=$point.obj->get_commune()}
    {assign var=departement value=$point.obj->get_departement()}
    <li class="{if $calendriers}adate{/if}">
	<h3>
	    {$point.obj->reference}
	    sur la commune de {$commune->nom} - {$departement->nom}
	</h3>
	{foreach from=$calendriers item=cal name=cals}
	    {if $smarty.foreach.cals.first}
		{if $smarty.foreach.cals.total == 1}
		    prospection prévue le
		{else if $smarty.foreach.cals.total > 1}
		    prospections prévues les
		{/if}
	    {/if}
	    {$cal->date_sortie_tstamp|date_format:$format_date_complet}{if !$smarty.foreach.cals.last}, {else}.{/if}
	{foreachelse}
	    pas de prospection de prévue.
	{/foreach}
	<br/>
	<a href="javascript:oloc({$point.id_espace});">en savoir plus...</a>
	<div class="cache" id="loc{$point.id_espace}">
	    <img src="?t=espace_chiro_vignette&id={$point.obj->id_espace}" onclick="javascript:cloc({$point.id_espace});"/><br/>
	    <small>Coordonnées GPS : {$point.obj->get_x()},{$point.obj->get_y()}<br/>
	    sur la commune de {$commune->nom} (cliquer sur l'image pour réduire)</small><br/>
	</div>
    </li>
{/foreach}
</ul>
{include file="chiros_outils.tpl"}
<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
