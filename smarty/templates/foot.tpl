</div>
<div id="bloc-bas">
	<div id="b-bas-1">
		<!-- <div id="b-bas-fne">
			<a href="http://www.fne.asso.fr/"><img src="{#PN_BASE_URL#}/{#PN_LOGO_FNE#}" alt="Membre de France Nature Environnement"></a>
		</div> -->
		<div id="b-bas-eas-cont">
			<span id="b-bas-eas">&Eacute;TUDIER - AGIR - SENSIBILISER</span>
		</div>
	</div>
	<div id="b-bas-2">&nbsp;</div>
	<div id="b-bas-3">
		{if $install == "picnat"}
		<div class="text-center">
			<a href="http://www.europa.eu" target="_blank" title="Union européenne"><div id="logo_europe" class="hoverscroll"></div></a>
			<a href="http://www.picardie-europe.eu" target="_blank" title="L'Europe s'engage en Picardie"><div id="logo_europe_eng" class="hoverscroll"></div></a>
			<a href="http://www.developpement-durable.gouv.fr/" target="_blank"><div id="logo_dreal" class="hoverscroll"></div></a>
			<a href="http://www.picardie.fr/" target="_blank"><div id="logo_cr" class="hoverscroll"></div></a>
			<a href="http://www.cg02.fr" target="_blank"><div id="logo_cg02" class="hoverscroll"></div></a>
			<a href="http://www.cg80.fr" target="_blank"><div id="logo_cg80" class="hoverscroll"></div></a>
			<a href="http://www.amiens.fr" target="_blank"><div id="logo_amiens" class="hoverscroll"></div></a>
		</div>
		{/if}
	</div>
	<div id="b-bas-4">
		<!-- adresse pn -->
		<small>Révision : {include file='/etc/baseobs/revision.txt'}</small><br/>
		<small>Temps de traitement : {$tps_exec_avant_display}s [version {$install}]</small>
	</div>
</div><!-- /bloc-bas -->
</div><!-- /globcont -->
{include file='/etc/baseobs/piwik.tpl'}
</body>
</html>
