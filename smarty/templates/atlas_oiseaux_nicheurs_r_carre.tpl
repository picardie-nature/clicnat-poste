{include file="poste_head.tpl" titre_page="AONFM Restitution $carre"}
{literal}
<style>
	#dlg, #dlg_tps,#dlg_abondance {
		position: fixed;
		width: 400px;
		height: 200px;
		margin-left: -150px;
		margin-top: -100px;
		background-color: white;
		top: 50%;
		left: 50%;
		border-style: solid;
		border-color: black;
		border-width: 2px;
		text-align: center;
		display:none;
	}

	div.choix {
		float:left;
		width:76px;
		height:56px;
		margin:10px;
		padding-top:30px;
		cursor:pointer;
		border-style: solid;
		border-color: white;
		border-width: 2px;
	}
	div.choix:hover {
		border-style: solid;
		border-color: red;
		border-width: 2px;
	}
	div.selection {
		border-color: black;
		border-style: dashed;
	}
	.btn_c {
		cursor:pointer;
	}
	.responsable {
		font-weight: bold;
		text-decoration: underline;
	}
	div.btn_abondance {
		text-align:center;
		cursor:pointer;
	}
</style>
<script>
	var g_annee;
	var g_id_espece;
	var g_carre = {/literal}{$carre->id_espace}{literal};
	var g_statut;

	function choix_tps(espace) {
		/*var s2 = J('#r'+annee+'_'+id_espece+ ' > div.btn_c');
		var classe = s2.html();
		if (classe == "&nbsp;") classe = 'A';
		e = J('#c_classe option:[value='+classe+']').attr("selected","selected");
		*/
		J('#dlg_tps').show();
	}

	function choix_abondance_prev_vars(data) {
		console.log(data);
		if (data.abondance_liste > 0) {
			switch (data.abondance_liste) {
				case "100":
				case "200":
				case "300":
				case "400":
					J('#abondance_fl option').removeAttr("selected");
					J('#abondance_fl option:[value="'+data.abondance_liste+'"]').attr("selected","selected");
					break;
				default:
					J('#abondance_fp option').removeAttr("selected");
					J('#abondance_fp option:[value="'+data.abondance_liste+'"]').attr("selected","selected");
					
			}
		}
		if (data.abondance_n > 0) {
			J('#abondance_cp').val(data.abondance_n);
		}
		J('#abondance_statut').html('');
	}

	function choix_abondance(e) {
		J('#abondance_carre').val(e.attr('carre'));
		J('#abondance_id_espece').val(e.attr('espece'));
		var fourchette_large = e.attr('fourchette_large');
		var fourchette_precise = e.attr('fourchette_precise');
		var chiffre_precis = e.attr('chiffre_precis');
		if (fourchette_large == 1) { J('#dlg_abondance_fl').show(); } else { J('#dlg_abondance_fl').hide(); }
		if (fourchette_precise == 1) { J('#dlg_abondance_fp').show(); } else { J('#dlg_abondance_fp').hide(); }
		if (chiffre_precis == 1) { J('#dlg_abondance_cp').show(); } else { J('#dlg_abondance_cp').hide(); }
		// reset
		J('#abondance_fl option').removeAttr("selected");
		J('#abondance_fl option:[value=null]').attr("selected","selected");
		J('#abondance_fp option').removeAttr("selected");
		J('#abondance_fp option:[value=null]').attr("selected","selected");
		J('#abondance_cp').val('');

		J('#dlg_abondance').show();
		url = '?'+J.param({
			t: 'altas_oiseaux_nicheurs_r_carre_get_abondance',
			id_espace: e.attr('carre'),
			id_espece: e.attr('espece')
		});
		J('#abondance_statut').html('chargement valeur actuelle...');
		J.ajax({async: false, url: url, dataType: 'json', success: choix_abondance_prev_vars});

	}
	
	function choix(annee,id_espece) {
		g_annee = annee;
		g_id_espece = id_espece;
		g_statut = null;

		var s = J('#r'+annee+'_'+id_espece);
		var ajout_classe = false;
		if (s.hasClass('n1')) {
			ajout_classe = 'c_possible';
		} else if (s.hasClass('n2')) {
			ajout_classe = 'c_probable';
		} else if (s.hasClass('n3')) {
			ajout_classe = 'c_certain';
		}
		J('.choix').removeClass('selection');
		if (ajout_classe != false) {
			J('#'+ajout_classe).addClass('selection');
		}
		J('#dlg_msg').html('Cliquez sur le statut de votre choix<br/> ou sur <a href="javascript:fermer();">fermer</a>');
		J('#dlg').show();
	}

	function enregistrer() {
		var url = '?'+J.param({
			t: 'atlas_oiseaux_nicheurs_r_carre_enreg',
			annee: g_annee,
			id_espece: g_id_espece,
			id_espace: g_carre,
			statut: g_statut,
			classe: J('#c_classe').val()
		});
		J('#dlg_msg').html('mise à jour...').load(url, function () { 
			if (J('#dlg_msg').html() == 'Ok') {
				var s = J('#r'+g_annee+'_'+g_id_espece).removeClass('n n0 n1 n2 n3').addClass('n'+g_statut);
				var s2 = J('#r'+g_annee+'_'+g_id_espece+ ' > div.btn_c').html(J('#c_classe').val());
				window.setTimeout(fermer, 750); 
			}
		});
	}

	function fermer() {
		J('#dlg').hide();
	}

	function abondance_fermer() {
		J('#dlg_abondance').hide();
	}

	function abondance_sauve() {
		var id_espace = J('#abondance_carre').val();
		var id_espece = J('#abondance_id_espece').val();
		var url = '?'+J.param({
			t: 'altas_oiseaux_nicheurs_r_carre_enreg_abondance',
			id_espece: id_espece, 
			id_espace: id_espace,
			fp: J('#abondance_fp').val(),
			fl: J('#abondance_fl').val(),
			cp: J('#abondance_cp').val()
		});
		J('#abondance_statut').load(url);
		var aff = '?';
		var fl = parseInt(J('#abondance_fl').val());
		if (fl > 0) {
			aff = 'classe '+fl/100;
		} else {
			var fp = parseInt(J('#abondance_fp').val());
			if (fp > 0) {
				aff = 'classe '+fp/100;
			}
		}
		var cp = parseInt(J('#abondance_cp').val());
		if (cp > 0)
			aff = cp;

		var div = J('div [carre='+id_espace+'][espece='+id_espece+']');
		div.html(aff);
		abondance_fermer();
	}

	J(document).ready(function () {
		J('.btn_c').click(function (e) {
			var id = e.currentTarget.parentNode.id;
			var exp = id.match(/^r(\d+)_(\d+)$/);
			choix(exp[1], exp[2]);
		});
		J('.btn_abondance').click(function (e) {
			var d = J(e.currentTarget);
			choix_abondance(d);
		});
		J('.choix').click(function (e) {
			J('.choix').removeClass('selection');
			J(e.currentTarget).addClass('selection');
			J('#dlg_msg').html('<a href="javascript:enregistrer();">Enregistrer</a> - <a href="javascript:fermer();">Annuler</a>');
			if (e.currentTarget.id == 'c_possible') g_statut = 1;
			else if (e.currentTarget.id == 'c_probable') g_statut = 2;
			else if (e.currentTarget.id == 'c_certain') g_statut = 3;
			else if (e.currentTarget.id == 'c_pas_nicheur') g_statut = -1;
			else alert('pas trouvé le bon statut ?');
		});
		J('#recherche_espece').autocomplete({
			source: '?t=espece_autocomplete2',
			select: function (event,ui) {
				var loc = document.location.href;
				loc += '&'+J.param({ajoute_espece: ui.item.value});
				document.location.href = loc;
			}
		});
	});
</script>
{/literal}
<div >
	<div id="dlg">
		<div style="clear:right;">Choix</div>
		<div id="c_possible" class="n1 choix">possible</div>
		<div id="c_probable" class="n2 choix">probable</div>
		<div id="c_certain" class="n3 choix">certain</div>
		<div id="c_pas_nicheur" class="n choix">pas nicheur</div>
		<div style="clear:right;" id="dlg_msg"></div>
	</div>
	<div id="dlg_tps">
		Classe temps d'observation 
		<select id="c_classe">
			<option value="A">A : &lt; 20h</option>
			<option value="B">B : 20 &lt; t &lt; 40h</option>
			<option value="C">C : 40 &lt; t &lt; 60h</option>
			<option value="D">D : &gt; 60h</option>
		</select>
	</div>
	<div id="dlg_abondance">
		<b>Nombre de couples</b><br/>
		<small>Essayez de répondre au champ le plus précis<br/> si plusieurs champs sont affichés</small>
		<input type="hidden" id="abondance_id_espece" value=""/>
		<input type="hidden" id="abondance_carre" value=""/>
		<div id="dlg_abondance_fl">
			Fourchette large :
			<select id="abondance_fl" name="fl">
				<option value="null"></option>
			{foreach from=$trois.fourchette_large item=f}
				{if $f.max eq "999999"}
					<option value="{$f.id}">plus de {$f.min}</option>
				{else}
					<option value="{$f.id}">de {$f.min} à {$f.max}</option>
				{/if}
			{/foreach}
			</select>
		</div>
		<div id="dlg_abondance_fp">
			Fourchette précise	
			<select id="abondance_fp" name="fp">
				<option value="null"></option>
			{foreach from=$trois.fourchette_precise item=f}
				{if $f.max eq "999999"}
					<option value="{$f.id}">plus de {$f.min}</option>
				{else}
					<option value="{$f.id}">de {$f.min} à {$f.max}</option>
				{/if}
			{/foreach}
			</select>

		</div>
		<div id="dlg_abondance_cp">
			Chiffre prècis :
			<input id="abondance_cp" type="text" name="cp" size="4"/>
		</div>
		<div>
			<br/>
			<span id="abondance_statut"></span>
			<br/>
			<a href="javascript:abondance_sauve();">Enregistrer</a> &nbsp; - &nbsp; <a href="javascript:abondance_fermer();">Annuler</a>
		</div>
	</div>
</div>

<h1>Choix des statuts pour le carré {$carre}</h1>
Code couleur: <span class="n1">nicheur possible</span>, <span class="n2">nicheur probable</span>, <span class="n3">nicheur certain</span>, <span class="n-1">pas nicheur</span><br/>
Attribution du carré : {foreach from=$carre->responsables_carre() item=rc} <span class="{if $rc.decideur_aonfm eq 't'}responsable{/if}">{$rc.nom} {$rc.prenom}</span> - {foreachelse} pas attribué {/foreach}<br/>
<b>Cliquez sur une cellule dans la colonne responsable pour définir un statut.</b><br/>
{assign var=responsable value=false}
{foreach from=$carre->responsables_carre() item=rc}
	{if $rc.id_utilisateur eq $u->id_utilisateur}
		{assign var=responsable value=true}
	{/if}
{/foreach}
{foreach from=$msgs item=m}
	<div class="info">{$m}</div>
{/foreach}
{literal}
<style>
/*
#B49858
#4F4223
#E3D9C1
#868686
*/
	.n { background-color: #4F4223; /*#664;*/ }
	.n0 { background-color: #000000; }
	.n-1 { background-color: #000000; }
	.n1 { background-color: #ff6000; }
	.n2 { background-color: #ffcc00; }
	.n3 { background-color: #00ff00; }

td.y>div {
	color:#868686;
	font-size:10px;
	text-align:center;
}

.yl {
	background-color:#B49858;
}
td.yl>div {
	font-size:10px;
	text-align:center;
	color:black;
}

table {
	empty-cells:show;
	border-collapse: collapse;
	width: 100%;
	background-color: #B49858;
}
tr:hover {
	border-color: #E3D9C1;
	border-width: 1px;
	padding-bottom: 0px;
}
.btn_tps { text-align: center;}
tr {
	border-bottom-style:dashed;
	border-color: #868686;
	border-width: 1px;
	padding-bottom: 0px;
}
</style>
{/literal}
<table>
<thead>
	<tr>
		<th width="30%">Espèce</th>
		<th width="20%" colspan="4">Automatique</th>
		<th width="5%" colspan="1">LPO</th>
		<th width="20%" colspan="4">Responsable</th>
		<th width="10%">Classes</th>
	</tr>
	<tr>
		<th></th>
		<th>2009</th><!-- automatique -->
		<th>2010</th>
		<th>2011</th>
		<th>2012</th>
		<!-- <th>2009</th> 
		<th>2010</th> 
		<th>2011</th> -->
		<th>2012</th><!-- lpo -->
		<th>2009</th><!-- responsable -->
		<th>2010</th>
		<th>2011</th>
		<th>2012</th>
		<th>Abondance</th>
	</tr>
</thead>
<tbody>
{foreach from=$trois.especes item=esp}
	<tr>
		<td>{if $responsable}<a href="?t=atlas_oiseaux_nicheurs_r_espece&id_espece={$esp.espece->id_espece}&id_espace={$carre->id_espace}">{/if}{$esp.espece}{if $responsable}</a>{/if}</td>
		{assign value=$esp.espece->id_espece var=ide}
		<td align="center" class="y"><div class="n{$trois.resultats.2009.$ide.statut_auto}">2009</div></td>
		<td align="center" class="y"><div class="n{$trois.resultats.2010.$ide.statut_auto}">2010</div></td>
		<td align="center" class="y"><div class="n{$trois.resultats.2011.$ide.statut_auto}">2011</div></td>
		<td align="center" class="y"><div class="n{$trois.resultats.2012.$ide.statut_auto}">2012</div></td>
		<!-- <td align="center" class="yl n{$trois.resultats.2009.$ide.statut_lpo}"><div>2009</div></td>
		<td align="center" class="yl n{$trois.resultats.2010.$ide.statut_lpo}"><div>2010</div></td>
		<td align="center" class="yl n{$trois.resultats.2011.$ide.statut_lpo}"><div>2011</div></td> -->
		<td align="center" class="yl n{$trois.resultats.2012.$ide.statut_lpo}"><div class="n{$trois.resultats.2012.$ide.statut_lpo}">2012</div></td>

		<td id="r2009_{$ide}" align="center" class="n{$trois.resultats.2009.$ide.statut_resp}">
			{if !$trois.resultats.2009.$ide.classe}{assign var="classe" value="&nbsp;"}{else}{assign var="classe" value=$trois.resultats.2009.$ide.classe}{/if} 
			<div class="btn_c">{$classe}</div>
		</td>
		<td id="r2010_{$ide}" align="center" class="n{$trois.resultats.2010.$ide.statut_resp}">
			{if !$trois.resultats.2010.$ide.classe}{assign var="classe" value="&nbsp;"}{else}{assign var="classe" value=$trois.resultats.2010.$ide.classe}{/if} 
			<div class="btn_c">{$classe}</div>
		</td>
		<td id="r2011_{$ide}" align="center" class="n{$trois.resultats.2011.$ide.statut_resp}">
			{if !$trois.resultats.2011.$ide.classe}{assign var="classe" value="&nbsp;"}{else}{assign var="classe" value=$trois.resultats.2011.$ide.classe}{/if} 
			<div class="btn_c">{$classe}</div>
		</td>
		<td id="r2012_{$ide}" align="center" class="n{$trois.resultats.2012.$ide.statut_resp}">
			{if !$trois.resultats.2012.$ide.classe}{assign var="classe" value="&nbsp;"}{else}{assign var="classe" value=$trois.resultats.2012.$ide.classe}{/if} 
			<div class="btn_c">{$classe}</div>
		</td>
		<td>
			<div class="btn_abondance" carre="{$carre->id_espace}" espece="{$ide}" fourchette_large="{$trois.requis_abond.$ide.f_large}" fourchette_precise="{$trois.requis_abond.$ide.f_precise}" chiffre_precis="{$trois.requis_abond.$ide.c_precis}">
				{if $trois.resultats_abond.$ide} {$trois.resultats_abond.$ide} {else} ? {/if}
			</div>
		</td>
	</tr>
{/foreach}
</tbody>
</table>
<h2>Ajouter une espèce</h2>
<div id="dlg_esp">
	Nom de l'espèce a ajouter : <input type="text" id="recherche_espece"/>
</div>
{include file="poste_foot.tpl"}
