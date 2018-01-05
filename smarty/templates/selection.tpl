{assign var=titre value=$s->nom_selection}
{include file="poste_head.tpl" titre_page="Sélection $titre"}
{literal}
<script language="javascript" src="js/commentaires.js"></script>
<script language="javascript">
function suppr(ligne) {
	{/literal}
	var url = '?t=json&a=selection_retirer&citation='+ligne+'&selection={$s->id_selection}';
	{literal}
	J.ajax({
		url: url,
		success: function (data, txtStatus, xhr) {
			J('#citation_'+data).detach();
		}
	});
}
function detail_citation(id_citation) {
	J('#bobs-citation').html('<img src="icones/load.gif"/> chargement en cours');
	J('#bobs-citation').load('?t=citation_detail&id='+id_citation);
	J('#bobs-citation').attr('id_citation', id_citation);
	J('#bobs-citation').dialog({height: 400, width: 400, buttons: {
		Fermer: function() {
			J(this).dialog('close');
		},
		Ouvrir: function() {
			document.location.href = '?t=citation&id='+J(this).attr('id_citation');
		},
		Validation: function() {
			var dlg = J('#dlg_validation');
			dlg.html('<img src="icones/load.gif"/> chargement en cours');
			dlg.load('?t=citation_beta_validation&id='+id_citation);
			dlg.dialog({width: 600,modal:true});
		}
	}});	
}

function selection_renommer(id_selection) {
	var nouveau_nom = prompt("Nouveau nom");
	if (nouveau_nom && nouveau_nom.length > 0) {
		document.location.href = '?'+J.param({
			t: "selection_renommer",
			sel: id_selection,
			nom: nouveau_nom
		});
	}
}
</script>
{/literal}
<div style="display:none;">
	<div id="dlg_validation" title="Validation"></div>
	<div id="bobs-citation" title="Citation" style="overflow:scroll;"> </div>
	<div id="bobs-dvo">
		<img id="bobs-dvo-img" src=""/>
		<p><small>Fond : SCAN100 &copy; IGN</small></p>
		<p>
			<small>
				Cette image indique la position enregistrée de l'observation,
				l'emprise affichée est celle de la commune de l'observation.
			</small>
		</p>
	</div>
	<div id="bobs-fusion" title="Fusion de sélections">
		<form method="get" action="index.php">
			<input type="hidden" name="t" value="selection_action"/>
			<input type="hidden" name="action" value="fusion"/>
			<input type="hidden" name="id_selection_a" value="{$s->id_selection}"/>
			Mélanger le contenu de cette sélection avec celle-ci :
			<select name="id_selection_b">
			{assign var=util value=$s->get_utilisateur()}
			{assign var=liste value=$util->selections()}
			{foreach from=$liste item=as}
				<option value="{$as->id_selection}">{$as->nom_selection}</option>
			{/foreach}
			</select>
			et l'enregistrer dans une nouvelle sélection avec le nom
			<input type="text" name="nom"/><br/>
			<input type="submit" value="Créer la nouvelle sélection"/>
		</form>
	</div>
	<div id="bobs-dr" title="Filtrer observateurs">
		<form method="get" action="index.php">
			<input type="hidden" name="t" value="selection_action"/>
			<input type="hidden" name="action" value="filtrer"/>
			<input type="hidden" name="id_selection" value="{$s->id_selection}"/>
			Sélectionner les observateurs dont vous souhaiter retirer les observations
			de cette sélection :<br/>
			<div style="height: 200px; overflow: auto;">
				{foreach from=$s->get_observateurs() item=o}
					<input type="checkbox" name="u_{$o.id_utilisateur}" id="chk_fil_u_{$o.id_utilisateur}" value="1"/>
					<label for="chk_fil_u_{$o.id_utilisateur}">{$o.nom} {$o.prenom}</label><br/>
				{/foreach}
			</div><br/>
			<input type="submit" value="Filtrer"/>
		</form>
	</div>
</div>
Sélection : <b><a href="javascript:selection_renommer({$s->id_selection});">{$s->nom_selection}</a></b> ({$s->n()} éléments)
{if $s->n() < $nav_max}<a href="?t=selection_nav&id={$s->id_selection}">consulter la carte</a>{/if}
<input type="checkbox" id="afficher_nom_scientifique"><label for="afficher_nom_scientifique">afficher que le nom scientifique dans le tableau</label>
<br/>
<script>
{literal}
var tbody = jQuery('#tbody');
J('#afficher_nom_scientifique').change(function () {
	charge_page(s_id, p);
});
function ouvre_fusion() {
	jQuery('#bobs-fusion').dialog();
}

function ouvre_dr() {
	jQuery('#bobs-dr').dialog();
}

function charge_page(select_id, page) {
	jQuery('#tbody').html('<tr><td colspan=7><img src=icones/load.gif> chargement en cours</td></tr>');
	jQuery.ajax({
		url: '?t=selection_data&sel='+select_id+'&page='+page,
		dataType: 'json',
		success: function (data) {					
			tbody = jQuery('#tbody');
			tbody.empty();
			for (var i=0; i<data.length; i++) {
				var c_tr = "<tr id=citation_"+data[i].id_citation+"><td style='background-color:white;'><a href='javascript:;' title='Détails' onclick=javascript:detail_citation("+data[i].id_citation+")><img src='picnat/loupe_16x16.png'/></a></td>";
				c_tr = c_tr + " <td><a href=?t=citation&id="+data[i].id_citation+" target='_blank'>"+data[i].id_citation+" <a href='javascript:;' onclick=javascript:suppr("+data[i].id_citation+");>[-]</a></td>";
				
				c_tr = c_tr + "<td>"+data[i].date+"</td> <td>"+data[i].lieu+"</a></td>";
				if (!data[i].nom_f || J('#afficher_nom_scientifique').attr('checked') != undefined)
					c_tr = c_tr + "<td>"+data[i].nom_s+"</td>";
				else
					c_tr = c_tr + "<td>"+data[i].nom_f+"</td>";
				if (data[i].nb == 0)
					c_tr = c_tr + "<td align=center>ind.</td>";
				else
					c_tr = c_tr + "<td align=center>"+data[i].nb;
				c_tr = c_tr + "<td><small>"+data[i].observateurs+"</small></td></tr>";
				tbody.append(c_tr);
			}			
		}
	});
	jQuery('#num_page').html(p+1);
	jQuery('#page_nav').val(p);
}

function page_precedente(select_id)
{
	if (p>0) {
		p=p-1;
		charge_page(select_id, p);
	}
}


function page_suivante(select_id, n_elem, n_elem_par_p)
{
	if ((p+1)*n_elem_par_p < n_elem) {
		p=p+1;
		charge_page(select_id, p);
	}
}

function page_nav_init()
{
	pn = jQuery('#page_nav');
	var myp = 0;
	log('n_elem='+n_elem);
	while (myp*n_par_page < n_elem) {
		log('ajoute '+myp);
		pn.append("<option value="+myp+">page "+(myp+1)+"</option>");
		myp=myp+1;
	}
}

function page_nav_change()
{
	nav = jQuery('#page_nav');
	log(nav.val());
	if (nav.val() != p) {
		p = parseInt(nav.val());
		charge_page(s_id, p);
	}
}

{/literal}

</script>
{literal}
<style>
	.avertissement {
		background-color: #faaaaa;
		color: black;
		padding: 3px;
		border-color:  #D90019;
		border-width: 2px;
		border-style: solid;
		margin-top:4px;
	}
</style>
{/literal}
{if $s->a_des_citations_de_nouveaux_observateurs()}
<div class="avertissement">
	<b>Attention,</b> cette sélection contient des observations de nouveaux observateurs qui n'ont pas encore été validées.
	<a href="?t=selection_action&action=retirer_newo&sel={$s->id_selection}">Enlever ces données de cette sélection</a>.
</div>
{/if}
{if $s->a_des_citations_invalides()}
<div class="avertissement">
	<b>Attention,</b> cette sélection contient des données invalides. Vous pouvez les retirer en cliquant ici.
	<a href="?t=selection_action&action=retirer_invalides&sel={$s->id_selection}">Enlever ces données de cette sélection</a>.
</div>
{/if}
<a href="#num_page" onclick="javascript:page_precedente(s_id);">page précédente</a> - page <span id=num_page>--</span> - <a href="#num_page" onclick="javascript:page_suivante(s_id,n_elem,n_par_page);">suivante</a>

<div style="min-height: 500px; background-color: #fafafa;" class="bobs-table">
<table width="100%">
	<thead>
		<tr>
			<th colspan="2">#</th>
			<th>Date</th>
			<th>Lieu</th>
			<th>Espèce</th>
			<th>N.</th>
			<th>Observateur(s)</th>
		</tr>
	</thead>
	<tbody  id="tbody"> </tbody>
</table>
</div>
<div align="center">
	<a style="float:left" href="#num_page" onclick="javascript:page_precedente(s_id);">précédente</a>
	<select id="page_nav" onchange="javascript:page_nav_change()"></select>
	<a style="float:right;" href="#num_page" onclick="javascript:page_suivante(s_id,n_elem,n_par_page);">suivante</a>
</div>
<div>
	<div class="bobs-demi">
		<div class="bobs-demi-titre">Actions sur la sélection</div>
		<div class="bobs-demi-interieur">
			<ul>
				{if $s->n() < 750}
				<li><a href="?t=selection_nav&sel={$s->id_selection}">ouvrir la sélection dans une carte</a></li>
				{/if}
				<li><a href="javascript:;" onclick="javascript:q('Supprimer la sélection','?t=selection_action&action=suppr&sel={$s->id_selection}');">supprimer la sélection</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Filtrer la sélection','?t=selection_action&action=filtrer_selection&sel={$s->id_selection}');">Lancer les tests de validation</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Vider la sélection', '?t=selection_action&action=vider&sel={$s->id_selection}');">vider la sélection (remettre à zéro)</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Extraction des oiseaux nicheurs', '?t=selection_action&action=nicheur&sel={$s->id_selection}');">tester extraction des nicheurs</a></li>
				<li><a href="javascript:ouvre_fusion();">fusionner avec une autre sélection</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 1km en LAEA (INSPIRE)', '?t=selection_action&action=mix_a&pas=1000&srid=3035&sel={$s->id_selection}');">agréger sur mailles de 1km en LAEA (INSPIRE)</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 2km en LAEA (INSPIRE)', '?t=selection_action&action=mix_a&pas=2000&srid=3035&sel={$s->id_selection}');">agréger sur mailles de 2km en LAEA (INSPIRE)</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 5km en LAEA (INSPIRE)', '?t=selection_action&action=mix_a&pas=5000&srid=3035&sel={$s->id_selection}');">agréger sur mailles de 5km en LAEA (INSPIRE)</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 10km en LAEA (INSPIRE)', '?t=selection_action&action=mix_a&pas=10000&srid=3035&sel={$s->id_selection}');">agréger sur mailles de 10km en LAEA (INSPIRE)</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 1km en Lambert 93', '?t=selection_action&action=mix_a&pas=1000&srid=2154&sel={$s->id_selection}');">agréger sur mailles de 1km en Lambert 93</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 2km en Lambert 93', '?t=selection_action&action=mix_a&pas=2000&srid=2154&sel={$s->id_selection}');">agréger sur mailles de 2km en Lambert 93</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 5km en Lambert 93', '?t=selection_action&action=mix_a&pas=5000&srid=2154&sel={$s->id_selection}');">agréger sur mailles de 5km en Lambert 93</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 10km en Lambert 93', '?t=selection_action&action=mix_a&pas=10000&srid=2154&sel={$s->id_selection}');">agréger sur mailles de 10km en Lambert 93</a></li>

				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 2km en Lambert 2 étendue', '?t=selection_action&action=mix_a&pas=2000&srid=27572&sel={$s->id_selection}');">agréger sur mailles de 2km en Lambert 2 étendue</a></li>
				<li><a href="javascript:;" onclick="javascript:q('Agréger sur mailles de 10km en Lambert 2 étendue', '?t=selection_action&action=mix_a&pas=10000&srid=27572&sel={$s->id_selection}');">agréger sur mailles de 10km en Lambert 2 étendue</a></li>
				{foreach from=$s->liste_mix() item=m}
				<li><a href="?t=selection_telecharger_shp_mix&sel={$s->id_selection}&pas={$m.pas}&srid={$m.srid}">télécharger agrégation mailles de {$m.pas/1000}km  srid:{$m.srid} (2154=Lambert 93)</a></li>
				{/foreach}
				<li><a href="?t=selection_telecharger&sel={$s->id_selection}">télécharger</a></li>
				{if $s->extraction_xml}
					<li><a href="?t=journal&act=extraction_charge_selection&id={$s->id_selection}">faire une nouvelle extraction</a></li>
				{/if}
				<li><a href="javascript:;" id="btn_filtre_smax">Filtrer selon la superficie</a></li>
			</ul>
		</div>
	</div>
	<div class="bobs-demi">
		<div class="bobs-demi-titre">Espèces</div>
		<div class="bobs-demi-interieur">
		<div style="background-color: white; overflow: auto; max-height: 300px; height: 200px; font-size: 10px;">
		  <b>Classes</b>
		    <ul>
		    {foreach from=$s->get_classes() item=r_classe name=bc}
				{assign var=classe value=$r_classe.obj}
			    <li style="background-color: {if $smarty.foreach.bc.index % 2 == 0}white{else}#dfdfdf;{/if}">
				{$r_classe.n} {$classe} 
				- <a href="?t=selection_action&action=retirer_avec_classe&sel={$s->id_selection}&classe={$classe->classe}">retirer</a>
			    </li>
		    {/foreach}
		    </ul>

		    <b>Espèces citées</b>, <a href="?t=selection_liste_espece_csv&sel={$s->id_selection}">télécharger la liste</a>
		    <ul>
		    {foreach from=$s->get_especes() item=e name=be}
			    <li style="background-color: {if $smarty.foreach.be.index % 2 == 0}white{else}#dfdfdf;{/if}">
				{if strlen($e.nom_f) > 1}{$e.nom_f}{else}{$e.nom_s}{/if}
				[<a href="?t=selection_action&action=retirer_avec_espece&sel={$s->id_selection}&id_espece={$e.id_espece}">retirer de la liste</a> -
				<a href="t=espece_detail&id={$e.id_espece}">voir la fiche espèce</a>]
			    </li>
		    {/foreach}
		    </ul>
		</div>
		</div>
	</div>
	<div class="bobs-demi">
		<div class="bobs-demi-titre">Observateurs</div>
		<div class="bobs-demi-interieur">
			<small>Observateurs présents dans la liste (<a style="display:inline;" href="javascript:ouvre_dr();">filtrer</a>)</small>
			<div style="background-color: white; overflow: auto; max-height: 300px; height: 200px; font-size: 10px;">
			    <ul>
			    {foreach from=$s->get_observateurs() item=o name=obs}
				    <li style="background-color: {if $smarty.foreach.obs.index % 2 == 0}white{else}#dfdfdf;{/if}">
					<a href="?t=profil&id={$o.id_utilisateur}">{$o.nom} {$o.prenom}</a>
				    </li>
			    {/foreach}
			    </ul>
			</div>
		</div>
	</div>
	<div class="bobs-demi">
		<div class="bobs-demi-titre">Saisisseurs</div>
		<div class="bobs-demi-interieur">
			<div style="background-color: white; overflow: auto; max-height: 300px; height: 200px; font-size: 10px;">
			    <a href="?t=selection_liste_auteur_csv&sel={$s->id_selection}">télécharger la liste</a>

			    <ul>
			    {foreach from=$s->get_auteurs() item=o name=obs}
				    <li style="background-color: {if $smarty.foreach.obs.index % 2 == 0}white{else}#dfdfdf;{/if}">
					<a href="?t=profil&id={$o.id_utilisateur}">{$o.nom} {$o.prenom}</a> ({$o.n_citations} citations)
				    </li>
			    {/foreach}
			    </ul>
			</div>

		</div>
	</div>
	<div class="bobs-demi">
		<div class="bobs-demi-titre">Etiquettes - Comportements</div>
		<div class="bobs-demi-interieur">
			<small>Etiquettes et codes comportement présents dans la liste</small>
			<div style="background-color: white; overflow: auto; max-height: 300px; height: 200px; font-size: 10px;">
			    <ul>
			    {foreach from=$s->get_tags() item=tag name=ltags}
				    <li style="background-color: {if $smarty.foreach.ltags.index % 2 == 0}white{else}#dfdfdf;{/if}">
					{$tag.lib} sur {$tag.usage} citation{if $tag.usage > 1}s{/if}
					<a href="?t=selection_action&action=retirer_avec_tag&sel={$s->id_selection}&id_tag={$tag.id_tag}">retirer</a>
				    </li>
			    {/foreach}
			    </ul>
			</div>
		</div>
	</div>
	<div class="bobs-demi">
		<div class="bobs-demi-titre">Nombre de carrés occupés</div>
		<div class="bobs-demi-interieur">
			<table>
				<tr>
					<th>Pas</th>
					<th>Projection</th>
					<th>Nombre</th>
				</tr>
			{foreach from=$s->nombre_de_carres() item=carre}
				<tr>
					<td>{$carre.pas}</td>
					<td>{$carre.srid}</td>
					<td>{$carre.count}</td>
				</tr>
			{/foreach}
			</table>
		</div>
	</div>
</div>
<script>
// initialisation
var s_id = {$s->id_selection};
var n_elem = {$s->n()};
var n_par_page = 25;
var p = 0;

page_nav_init();
charge_page(s_id, 0);
//{literal}
J('#btn_filtre_smax').click(function () {
	var smax = parseInt(prompt("Superficie max en km²"));
	if (smax) {
		smax = smax * 1000 * 1000;
		document.location.href = '?t=selection_action&action=filtrer_smax&smax='+smax+'&sel='+s_id;
	}
});
//{/literal}
</script>
<div style="clear:both;"></div>
{include file="poste_foot.tpl"}
