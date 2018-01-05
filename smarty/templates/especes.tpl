{if empty($objet)}
{include file="poste_head.tpl"}
{literal}
<style>
	#bobs-zone-espece {
		background-color: white;
	}
	
	.bobs-zone-scroll {
		overflow: scroll;
		max-height: 500px;
		height: 500px;
	}
	
    	.bobs-zone-scroll li {
		cursor: pointer;
		border-style: solid;
		border-width: 1px;
		border-color: white;
	}

	.bobs-zone-scroll li:hover {
		background-color: #efefef;
		border-color: #ffafaf;
		border-style: solid;
		border-width: 1px;
	}
</style>
{/literal}
<h1>Liste des espèces</h1>
<div id="bobs-zone-espece"></div>

<script>
	var objet = '{$r_objet|default:'classes'}';
	var ref = '{$r_ref|default:'all'}';
//{literal}
	function bobs_esp_redirection(objet, ref)
	{
		J('#bobs-zone-espece').load('?t=especes&objet='+objet+'&ref='+ref);
	}
	bobs_esp_redirection(objet, ref);
//{/literal}
</script>
{include file="poste_foot.tpl"}
{/if}


{if $objet eq "classes"}
{literal}
Classes :
<style>

</style>
<div class="bobs-zone-scroll">
    <ul>
	<li id="ca">Arachnides</li>
	<li id="cb">Batraciens</li>
	<li id="cr">Reptiles</li>
	<li id="co">Oiseaux</li>
	<li id="cm">Mammifères</li>
	<li id="ci">Insectes</li>
	<li id="cp">Poissons</li>
	<li id="ml">Mollusques</li>
	<li id="cc">Crustacés</li>
    </ul>
</div>
<script>
    J('#ca').click(function () {bobs_esp_redirection('classe', 'A')});
    J('#cb').click(function () {bobs_esp_redirection('classe', 'B')});
    J('#cr').click(function () {bobs_esp_redirection('classe', 'R')});
    J('#co').click(function () {bobs_esp_redirection('classe', 'O')});
    J('#cm').click(function () {bobs_esp_redirection('classe', 'M')});
    J('#ci').click(function () {bobs_esp_redirection('classe', 'I')});
    J('#cp').click(function () {bobs_esp_redirection('classe', 'P')});
    J('#ml').click(function () {bobs_esp_redirection('classe', 'L')});
    J('#cc').click(function () {bobs_esp_redirection('classe', 'C')});
</script>
{/literal}
{/if}

{if $objet eq "classe"}
{literal}
<div style="display:inline; cursor:pointer;" id="classe_classes"><u>Classes</u></div> / {/literal}{$classe_lib}{literal}<br/>
<div class="bobs-zone-scroll">
Ordres :
<ul>
{/literal}
{foreach from=$ordres item=ordre}
    <li id="{$ordre.md5}">{if strlen($ordre.ordre) <= 1}?{else}{$ordre.ordre}{/if}</li>
{/foreach}
{literal}
</div>
</ul>
<script language="javascript">
    
    J('#classe_classes').click(function () {bobs_esp_redirection('classes', 'all')});
    // {/literal}
    // {foreach from=$ordres item=ordre}
    
        J('#{$ordre.md5}').click( function () {literal} {  bobs_esp_redirection('ordre', '{/literal}{$ordre.md5}{literal}'); } {/literal} );
    // {/foreach}
    // {literal}
</script>
{/literal}
{/if}

{if $objet eq "ordre"}
{literal}
<script>
	function r(id)
	{
		var o = J('#e'+id);
		o.attr('id_espece', id);
		o.click(function () { v = J(this).attr('id_espece'); document.location.href = '?t=espece_detail&id='+v; });
	}
</script>
<div style="display:inline; cursor:pointer;" id="classe_ordres"><u>Classes</u></div> / {/literal}{$classe_lib}{literal} -
<div style="display:inline; cursor:pointer;" id="ordre_ordres"><u>Ordres</u></div> / {/literal}{$ordre_lib}{literal}
<div class="bobs-zone-scroll">
    <ul>
    {/literal}
    {foreach from=$especes item=esp}
	<li>
		<div id="e{$esp->id_espece}">
			<div style="float:right;">
				{if count($esp->documents_liste())>0}<img src="icones/photo.png" title="Photos"/>{/if}
			</div>
			{if strlen($esp->nom_f) > 1}{$esp->nom_f} <br/>{/if}
			<i>{$esp->nom_s}</i>
			<a style="text-decoration: none;" href="?t=espece_detail&id={$esp->id_espece}">&rarr;</a>
			<div style="clear:both;"></div>
		</div>
	</li>
    {/foreach}
    </ul>
    <script> 
    	{foreach from=$especes item=e}
		r({$e->id_espece}); 
	{/foreach}
    </script>
</div>
    {literal}
<script>
    J('#classe_ordres').click(function () {bobs_esp_redirection('classes', 'all')});
    J('#ordre_ordres').click(function () {bobs_esp_redirection('classe', {/literal}'{$classe}'{literal})});
</script>
{/literal}
{/if}
