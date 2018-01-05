{include file="mangeoire_head.tpl" titre_page="Accueil"}
{assign var=mangeoires value=$observateur->get_mangeoires()}
<script>
//{literal}
function nouvelle_saisie(id_espace) {
	J('#nouvelle_saisie').dialog({
		modal:true,
		buttons: {
			"Annuler": function () {
				J(this).dialog("close");
			}
		}
	});
	J('#saisie_id_espace').val(id_espace);
	J('#saisie_date').datepicker({maxDate: 0});
}
//{/literal}
</script>
<br/>
<div class="desc">
	<h1>Avertissement</h1>
	<div>
		Attention, les mangeoires s'installent aux premiers froids et se retirent avec l'arrivée du printemps.
		Si des oiseaux prennent l'habitude de s'y nourrir en hiver, veillez à ce qu'ils les trouvent, à cette période
		toujours garnies. <b>Un arrêt brutal du nourrissage leur serait fatal</b> (vacances de Noël ou de février).<br/><br/>
		En cas de dégel ou de redoux, il est recommandé de réduire les quantités.<br/><br/>
		Une mangeoire en dehors des périodes de froid peut être dangereuse pour les oiseaux : 
		<a href="http://www.picardie-nature.org/spip.php?article1443" target="_blank">voir ce cas arrivé au centre de sauvegarde</a>.
	</div>
</div>
<div class="desc">
	{if $mangeoires|@count eq 0}
	<h1>Accueil</h1>
	<div>
		<!-- pas de mangeoire -->
		Vous n'avez pas de mangeoire enregistrée.
		<ul>
			<li>Vous pouvez partager une mangeoire avec un autre observateur,
			dans ce cas, demander lui de vous ajouter à la liste des observateurs
			de celle-ci.</li>
			<li><a href="?t=mangeoire_enregistrer">Enregistrer votre mangeoire</a></li>
		</ul>
	</div>
	{/if}
	{if $mangeoires|@count eq 1}
	<h1>Accueil</h1>
	<div>
		<!-- une mangeoire -->
		{assign var=mangeoire value=$mangeoires[0]}
		Pour votre mangeoire <b>{$mangeoire->nom}</b>
		<ul>
			<li><a href="javascript:;" onclick="javascript:nouvelle_saisie({$mangeoire->id_espace});">Démarrer une nouvelle observation</a></li>
			<li><a href="?t=mangeoire_rapport&id={$mangeoire->id_espace}">Quelques chiffres sur ma mangeoire</a></li>
			<li><a href="?t=mangeoire_liste_observateur&id={$mangeoire->id_espace}">Observateurs de la mangeoire</a></li>
			{foreach from=$mangeoire->get_observations() item=lo}
				{if $lo->brouillard}
					<li><a href="?t=mangeoire_inventaire&id={$lo->id_observation}">Inventaire du {$lo->date_observation|date_format:"%d-%m-%Y"} a terminer</a></li>
				{/if}
			{/foreach}

		</ul>
		<br/>
		Si vous avez plusieurs mangeoires vous pouvez en enregistrer une supplémentaire <a href="?t=mangeoire_enregistrer">ici</a>.
	</div>
	{/if}
</div>

{if $mangeoires|@count > 1}
	<h1>Les mangeoires</h1>
	{foreach from=$mangeoires item=mangeoire}
	<div class="desc" style="width: 30%; float: left;">
		<h1>{$mangeoire->nom}</h1>
		<div>
		<ul>
			<li><a href="javascript:;" onclick="javascript:nouvelle_saisie({$mangeoire->id_espace});">Démarrer une nouvelle observation</a></li>
			<li><a href="?t=mangeoire_rapport&id={$mangeoire->id_espace}">Quelques chiffres sur ma mangeoire</a></li>
			<li><a href="?t=mangeoire_liste_observateur&id={$mangeoire->id_espace}">Observateurs de la mangeoire</a></li>
			{foreach from=$mangeoire->get_observations() item=lo}
				{if $lo->brouillard}
					<li><a href="?t=mangeoire_inventaire&id={$lo->id_observation}">Inventaire du {$lo->date_observation|date_format:"%d-%m-%Y"} a terminer</a></li>
				{/if}
			{/foreach}
		</ul>
		</div>
	</div>
	{/foreach}
<div style="clear:both;"></div>
<div class="desc">
	<h1>Ajouter une mangeoire</h1>
	<div>
		Ajouter une mangeoire supplémentaire <a href="?t=mangeoire_enregistrer">ici</a>.
	</div>
</div>
{/if}
<div id="nouvelle_saisie" class="desc pas_visible" title="Commencer la saisie des observations">
	<p>
		À quelle date les observations ont été faites ?
		<form method="get" action="index.php" id="f_nouvelle_saisie">
			<input type="hidden" name="t" value="mangeoire_creation_obs"/>
			<input type="hidden" name="id_espace" value="" id="saisie_id_espace"/>
			<input type="text" name="date" size="12" id="saisie_date"/>		
			<input type="submit" value="Valider"/>
		</form>
	</p>
</div>
{include file="mangeoire_foot.tpl"}
