{if $u->acces_chiros}
{foreach from=$calendriers item=cal}
<p class="directive">
    Prospection prévue le {$cal->date_sortie|date_format:"%d-%m-%Y"}
</p>
<ul>
    {assign var=je_suis_present value=false}
    {foreach from=$cal->get_participants() item=p}
    {if $p.id_utilisateur == $u->id_utilisateur}
	{assign var=je_suis_present value=true}
    {/if}
    <li>
	{$p.nom} {$p.prenom}
	{if $p.id_utilisateur == $u->id_utilisateur}
	<small>
	    <a href="javascript:chiro_annuler({$espace->id_espace},{$cal->id_date});">annuler</a>
	</small>
	{/if}
    </li>
    {/foreach}
    {if !$je_suis_present}
    <li><a href="javascript:chiro_participer({$espace->id_espace},{$cal->id_date});">Participer à la prospection</a></li>
    {/if}
    <li><a href="javascript:chiro_form_new_date({$espace->id_espace});">Ajouter une autre date de visite</a></li>
</ul>
{foreachelse}
<div class="bobs-commtr">
    Pas de date de visite prévue :
    <a href="javascript:chiro_form_new_date({$espace->id_espace});">ajouter une date de visite</a>
</div>
{/foreach}

<input type="button" value="Saisir données" onclick="javascript:chiro_ouvrir_saisie({$espace->id_espace});" />

{foreach from=$observations item=obs}
<p class="directive">{$obs->date_obs_tstamp|date_format:"%d-%m-%Y"}</p>
<p class="valeur">
<ul>
    {assign var=total value=0}
    {foreach from=$obs->get_citations() item=c}
	{if $c->invalide()}
		<li><strike>{$c->get_espece()}</strike></li>
	{else}
		<li>
			{if $c->nb eq -1}
				<font color="red">Prospection du site négative</font>
			{else}
				{assign var=nb value=$c->nb}
				{assign var=total value=$total+$nb}
				{$c->nb} {$c->get_espece()}
			{/if}
		</li>
	{/if}
    {/foreach}
    Total effectifs : {$total}
</ul>
<ul>
    {foreach from=$obs->get_observateurs() item=obs}
    <li>{$obs.nom} {$obs.prenom}</li>
    {/foreach}
</ul>
</p>
{foreachelse}
<p class="directive">Observations</p>
<p class="valeur">
    Pas d'observation visible avec votre compte
</p>
{/foreach}
{else}
Problème droit d'accès
{/if}
