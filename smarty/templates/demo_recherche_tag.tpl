{include file="poste_head.tpl" titre_page="Démo recherche tag"}
<h1>Interface de démo pour la recherche d'étiquettes</h1>

<a id="at" href="javascript:;">Tester</a>

{include file="partiels/recherche_tag.tpl"}
<div style="clear:both;"></div>
<script>
	{literal}
		function cback(n) {
			alert(n);
		}
		J('#at').click(function() { l = new BoiteRechercheTag(cback); });
	{/literal}

</script>
{include file="poste_foot.tpl"}
