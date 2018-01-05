{include file="mangeoire_head.tpl" titre_page="Inventaire"}
<h1>Espèces vues le {$obs->date_observation|date_format:"%A %e %B %Y"}</h1>
<form method="get" action="index.php">
	<input type="hidden" name="t" value="mangeoire_inventaire_fin"/>
	<input type="hidden" name="id" value="{$obs->id_observation}"/>
	<input type="submit" value="Terminer l'inventaire"/>
</form>
<style>
{literal}
div.mangeoire_espece {
	background-color: white;
	width: 222px;
	float: left;
	margin: 5px;
}

.mangeoire_espece h1 {
	font-size: 14px;
}

.mangeoire_effectif span {
	font-size: 45px;
	padding-bottom: 4px;
}

.sauve { 
}

.manettes a:hover , .sauve a:hover {
	text-decoration: none;
}
{/literal}
</style>
<script>
{literal}
function plus_un(id_espece) {
	op(id_espece,1);
}

function moins_un(id_espece) {
	op(id_espece,-1);
}

function op(id_espece, v) {
	var cpt = J('#e'+id_espece);
	var prev = J('#p'+id_espece);
	var eff = parseInt(cpt.html());

	eff = eff + v;
	if (eff < 0) eff = 0;
	
	cpt.html(eff);
	
	if (cpt.html() == prev.html()) J('#s'+id_espece).hide();
	else J('#s'+id_espece).show();
}

function set_esp(id_espece, v) {
	J('#e'+id_espece).html(parseInt(v));
	J('#p'+id_espece).html(parseInt(v));
}

function sauve(id_observation, id_espece) {
	var cpt = J('#e'+id_espece);
	var effectif = parseInt(cpt.html());
	var args = {
		t: 'mangeoire_set_effectif',
		id_espece: id_espece,
		id_observation: id_observation,
		nb: effectif
	};
	J('#e'+id_espece).load('?'+J.param(args), function (resultat) {
		var id = this.id;
		id = '#s'+this.id.substring(1);
		var prev_id = '#p'+this.id.substring(1);
		J(id).hide();
		console.log(prev_id);
		console.log(parseInt(resultat));
		J(prev_id).html(parseInt(resultat));
	});
}
{/literal}
</script>
<div style="clear:both;">
{assign var=especes value=$mangeoire->liste_especes_base()}
{foreach from=$especes item=espece}
	<div class="mangeoire_espece">
		{assign var=n value=0}
		{foreach from=$espece->documents_liste() item=img}
			{if $n eq 0}
			{if $img->get_type() == 'image'}
			{if !$img->est_en_attente()}
				{assign var=n value=1}
				<img src="?t=img&id={$img->get_doc_id()}&w=222" onclick="javascript:ouvre_photo_poste('{$img->get_doc_id()}');" />
			{/if}
			{/if}
			{/if}
		{/foreach}
		{if $n == 0}<img width="222" src="image/vide1.png"/>{/if}
		<h1>{$espece}</h1>
		<div class="mangeoire_effectif">
			<span id="p{$espece->id_espece}" class="pas_visible">0</span>
			<div class="manettes" style="vertical-align: center; text-align:left;margin-left: 20px;">
				<a href="javascript:moins_un({$espece->id_espece});"><img width="40" height="40" src="image/moins.png"/></a>
				<span id="e{$espece->id_espece}">0</span>
				<a href="javascript:plus_un({$espece->id_espece});"><img width="40" height="40" src="image/plus.png"/></a>
				<span id="s{$espece->id_espece}" class="sauve pas_visible">
					<a href="javascript:sauve({$obs->id_observation},{$espece->id_espece});">
						<img width="40" height="40" src="image/enregistrer.png"/>
					</a>
				</span>
			</div>
			<div style="clear:both;"></div>
		</div>
	</div>
{/foreach}
<script>
{foreach from=$obs->get_citations_ids() item=id_c}
	{assign var=citation value=$obs->get_citation($id_c)}
	set_esp({$citation->id_espece}, {$citation->nb});
{/foreach}
</script>
</div>
<div style="clear:both;"></div>
<div class="desc">
	<h1>Validation et autre masque</h1>
	<div>
		Vous pouvez ouvrir cet inventaire sur le masque de saisie classique : <a href="?t=saisie_base&id={$obs->id_observation}">passer sur le masque classique</a>.<br/>
		Une fois que vous avez terminé cliquez sur le bouton terminé en haut à gauche ou ici pour <a href="?t=mangeoire_inventaire_fin&id={$obs->id_observation}">terminer votre inventaire</a>.
	</div>
</div>

{include file="mangeoire_foot.tpl"}
