<div style="display:none;">
	<div id="bobs-dvo">
		<img id="bobs-dvo-img" src=""></img>
		<p><small>Fond : SCAN100 &copy; IGN</small></p>
		<p>
			<small>
				Cette image indique la position enregistrée de l'observation,
				l'emprise affichée est celle de la commune de l'observation.
			</small>
		</p>
	</div>
</div>
<ul class="bobs-liste-obs">
{foreach from=$observations key=k item=obs}
	<li {if $obs->brouillard}class="bobs-liste-obs-nonvalidee"{/if}>
		{foreach from=$obs->get_especes_vues() key=kk item=esp name=foresp}
			{if $surligner_espece == $esp.id_espece} <b style="background-color:yellow;"> {/if}
			{if $esp.total != 0}{$esp.total}{/if}
			<a href="?t=espece_detail&id={$esp.id_espece}" title="{$esp.nom_s}">{$esp.obj}</a>
			{if $surligner_espece == $esp.id_espece} </b> {/if}
			{if !$smarty.foreach.foresp.last}, {/if}
		{/foreach}
		<br/>
		le {$obs->date_obs_tstamp|date_format:$format_date_complet} 
		par 
		{foreach from=$obs->get_observateurs() item=observ}
			<a href="?t=profil&id={$observ.id_utilisateur}"> {$observ.nom} {$observ.prenom}</a>
		{/foreach} 
		<br/>
		{assign var='esp' value=$obs->get_espace()}
		{assign var='commune' value=$esp->get_commune()}
		{assign var='departement' value=$esp->get_departement()}
		dans la commune de <b>{$commune->nom}</b> ({$departement->nom}) 
		<a href="javascript:dialog_vignette('bobs-dvo', {$obs->id_observation});">(carte)</a>
	</li>
{foreachelse}
	<li>
		<i>Aucune observation</i>
	</li>
	<a href="?t=saisie">Commencer a saisir mes observations</a>
{/foreach}
</ul>
