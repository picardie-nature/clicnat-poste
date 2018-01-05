{include file="poste_head.tpl" titre_page="Démo recherche observateur"}
<h1>Interface de démo pour la recherche d'observateur</h1>

{include file="partiels/recherche_observateurs.tpl" utilisateur=$u}
<div style="width:40%; float:left; background-color: white; margin: 4px;">
	Liste A
	<ul id="liste_observateurs">
		<li id=2033>Test Nico</li>
	</ul> 
	<a id="b_r" href="javascript:;">Recherche</a>
</div>

<div style="width:40%; float:left; background-color: white; margin: 4px;">
	Liste B
	<ul id="liste_observateurs_b">
	</ul> 
	<a id="b_rb" href="javascript:;">Recherche</a>
</div>
<div style="clear:both;"></div>
<script>
	{literal}
		J('#b_r').click(function() { l = new BoiteRechercheObservateurs('liste_observateurs'); });
		J('#b_rb').click(function() { l = new BoiteRechercheObservateurs('liste_observateurs_b'); });
	{/literal}

</script>
{include file="poste_foot.tpl"}
