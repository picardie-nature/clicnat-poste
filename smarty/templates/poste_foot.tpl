	</div><!-- pn_main -->
<div id="bloc-bas">
	<div id="b-bas-1">
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
		{if $install == "gonm"}
		<style>
		/* {literal} */
		.gonm-pied {
			color: black;
		}
		.gonm-pied a, .gonm-pied a:visited {
			color: blue !important;
		}
		.gonm-pied td {
			text-align: justify;
			vertical-align: top;
		}
		.gonm-pied img {
			width: 100%;
			margin-bottom: 5px;
		}
		.gonm-pied p {
			margin-top: 0px;
			font-size: 13px;
		}
		.pied-gonm-titre {
			background-color: white;
			text-align: center;
			margin-bottom: 3px;
			font-weight: bold;
			padding: 6px;
		}
		/* {/literal} */
		</style>
		<div class="gonm-pied">
		<table>
			<tr>
				<td width="25%">{texte nom="base/gonm/pied"}</td>
				<td width="16%">
					<div class="pied-gonm-titre">Coordinateurs des réseaux d'observations</div>
					<a href="http://www.gonm.org/"><img src="image/gonm/gonm.jpg"/></a>
				</td>
				<td width="16%">
					<a href="http://gmn.asso.fr/"><img src="image/gonm/gmn.jpg"/></a>
					<a href="http://celinelecoq9.wix.com/obhen"><img src="image/gonm/OBHeN.jpg"></a>
				</td>
				<td width="16%">
					<a href="http://www.gretia.org"><img src="image/gonm/gretia.jpg"></a>
					<a href="http://www.asehn.org"><img src="image/gonm/asehn.jpg"></a>
				</td>
				<td width="32%">
					<table>
						<tr>
							<td colspan="2">
								<div class="pied-gonm-titre">Partenaires territoriaux</div>
							</td>
						</tr>
						<tr>
							<td width="50%">
								<a href="http://www.parc-naturel-normandie-maine.fr/"><img src="image/gonm/pnr_normandie_maine.jpg"></a>
								<a href="http://www.parc-cotentin-bessin.fr/"><img src="image/gonm/pnr_marais_cotentin_bessin.jpg"></a>
								<a href="http://www.cren-haute-normandie.com/"><img src="image/gonm/cen_hn.jpg"></a>
							</td>

							<td width="50%">
								<a href="http://www.cpiecotentin.com/"><img src="image/gonm/cpie.jpg"></a>
								<a href="http://www.paysdauge-natureetconservation.fr/"><img src="image/gonm/pays_auge_nature_et_conservation.jpg"></a>
							</td>
						</tr>
					</table>

				</td>
			</tr>
		</table>
		</div>
		{/if}
	</div>
	<div id="b-bas-4">
		<!-- adresse pn -->
		<small>Temps de traitement : {$tps_exec_avant_display}s [{$install}]</small>
	</div>
</div><!-- /bloc-bas -->	
</div><!-- globcont -->
{include file='/etc/baseobs/piwik.tpl'}
</body>
</html>
