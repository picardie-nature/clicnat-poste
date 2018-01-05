{include file="poste_head.tpl" titre_page="Observation"}
<h1>Observation</h1>
{if !$obs}
	<p>Vous ne pouvez pas consulter cette observation</p>
{else}
<table>
	<tr>
		<td valign="top"><b>Date</b></td>
		<td>
			{$obs->date_observation|date_format:"%d-%m-%Y"}
			{if $peut_modifier}
				<a href="#" id="btn_modifier_date">modifier</a>
				<div id="mod_date" style="display:none;">
					<form method="post" action="?t=observation&id={$obs->id_observation}"/>
						<input type="text" size="10" name="date" value="{$obs->date_observation|date_format:"%d-%m-%Y"}"/>
						<input type="submit" value="Modifier"/>
					</form>
				</div>
				<script>
				//{literal}
				J('#btn_modifier_date').click(function () { J(this).hide(); J('#mod_date').toggle(); });
				//{/literal}
				</script>
			{/if}
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Saisie par</b></td>
		<td>{$obs->get_auteur()} {if $obs->date_creation}le {$obs->date_creation|date_format:"%d-%m-%Y"}{/if}</td>
	</tr>
	{if $obs->date_modif}
	<tr>
		<td valign="top"><b>Dernière modification</b></td>
		<td>{$obs->date_modif|date_format:"%d-%m-%Y"}</td>
	</tr>
	{/if}
	<tr>
		<td valign="top"><b>Observateurs</b></td>
		<td>
			<ul>
			{foreach from=$obs->get_observateurs() item=observ}
				<li>{$observ.nom} {$observ.prenom}</li>
			{/foreach}
			</ul>
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Espèces citées</b></td>
		<td>
			<ul>
			{foreach from=$obs->get_citations() item=citation}
				<li><a href="?t=citation&id={$citation->id_citation}">{$citation->nb} {$citation->get_espece()}</a></li>
			{/foreach}
			</ul>
		</td>
	</tr>
	<tr>
		<td valign="top"><b>Commentaires</b></td>
		<td>
			<ul>
			{foreach from=$obs->get_commentaires() item=c}
				<li>
					<div>{$c->commentaire}</div>
					<div><small>par {$c->utilisateur} le {$c->date_commentaire_f}</small></div>
				</li>
			{foreachelse}
				<li>Aucun commentaire</li>
			{/foreach}
			</ul>
			<form method="post" action="?t=observation&id_observation={$obs->id_observation}">
				<textarea name="commentaire" style="height:200px;width:500px;"></textarea><br/>
				<input type="submit" value="Ajouter un commentaire"/>
			</form>
		</td>
	</tr>
</table>
{/if}
{include file="poste_foot.tpl"}
