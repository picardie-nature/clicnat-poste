{include file="poste_head.tpl" titre_page="Ma page"}
<script src="js/raphael-min.js" language="javascript"></script>
<script src="js/morris.min.js" language="javascript"></script>

<h1>Informations sur mon compte et mes observations</h1>
<a href="#smail">Adresse email</a> -
<a href="#sdate_naissance">Date de Naissance</a> -
<a href="#smdp">Mot de passe</a> -
<a href="#sobs">Nombre d'observations</a> -
<a href="#satlas">Carrès Atlas</a> -
<a href="#reseaux">Réseaux</a> -
<a href="#expertise">Expertise et ajout d'espèce</a>

<h2 id="smail">Mon adresse email</h2>
{if $message_mail}<div class="bobs-commtr">{$message_mail}</div>{/if}
<form method="post" action="?t=mapage&act=mail">
    <p class="valeur"><input type="text" name="mail" value="{$u->mail}"/></p>
    <p class="valeur"><input type="submit" value="Enregistrer"/></p>
</form>
<h2 id="smail">Ma date de naissance</h2>
{if $message_date}<div class="bobs-commtr">{$message_date}</div>{/if}
<form method="post" action="?t=mapage&act=date_naissance">
    <p class="valeur"><input type="text" name="date_naissance" value="{if $u->date_naissance}{$u->date_naissance|date_format:'%d-%m-%Y'}{/if}"/></p>
    <p class="valeur"><input type="submit" value="Enregistrer"/></p>
</form>

<h2 id="smdp">Modifier mon mot de passe</h2>
{if $message_mdp}<div class="bobs-commtr">{$message_mdp}</div>{/if}
<form method="post" action="?t=mapage&act=mdp">
    <p class="directive">Nouveau mot de passe</p>
    <p class="valeur"><input type="password" name="p1" value=""/></p>
    <p class="directive">Confirmation</p>
    <p class="valeur"><input type="password" name="p2" value=""/></p>
    <p class="valeur"><input type="submit" value="Enregistrer"/></p>
</form>
<h2 id="pobs">Options de partage</h2>
<form method="post" action="?t=mapage&act=options">
<div><label class="checkbox">
	<input type="checkbox" name="partage_opts[transmettre_nom_sinp]" {if $u->partage_opts('transmettre_nom_sinp')}checked{/if}/>
	Transmettre votre nom avec les observations lors d'échanges dans le cadre du SINP
</label></div>
<div><label class="checkbox">
	<input type="checkbox" name="partage_opts[ma_localisation]" {if $u->partage_opts('ma_localisation')}checked{/if}/>
	Je souhaite partager ma localisation et je permets que d'autres observateurs me contactent.
</label></div>
<div><label class="checkbox">
	<input type="checkbox" name="partage_opts[mes_medias]" {if $u->partage_opts('mes_medias')}checked{/if}/>
	J'autorise les autres observateurs à voir les photos et écouter les sons associés à mes observations sur ma page de profil
	et sur les flux d'observations.
</label></div>
<div><label class="checkbox">
	<input type="checkbox" name="partage_opts[pas_de_mail_utilisateurs]" {if $u->partage_opts('pas_de_mail_utilisateurs')}checked{/if}/>
	Je ne souhaite pas recevoir les messages d'informations envoyés par les administrateurs de la plate-forme aux utilisateurs
</label></div>
<div><label class="checkbox">
	<input type="checkbox" name="partage_opts[pas_de_mail_interaction]" {if $u->partage_opts('pas_de_mail_interaction')}checked{/if}/>
	Je ne souhaite pas recevoir de message par mail lorsqu'un utilisateur ajoute un commentaire sur une de mes observations
</label></div>


<!--
<div><label class="checkbox">
	<input type="checkbox" name="partage_opts[liste_espece]" {if $u->partage_opts('liste_espece')}checked{/if}/>
	J'autorise les autres observateurs a voir ma liste d'espèces observées.
</label></div>
<div><label class="checkbox">
	<input type="checkbox" name="partage_opts[journal]" {if $u->partage_opts('journal')}checked{/if}/>
	J'autorise les autres observateurs a voir mon journal d'observation.
</label></div>
-->
	<input type="submit" value="Mettre à jour les options">
</form>
<h2 id="sobs">Nombre d'observations par mois en <span id="g_annee">{$y}</span></h2>

<script language="javascript">
{literal}
function change_annee(annee) {
	J('#g1').html("");
	J.ajax({
		url: '?t=mes_obs_par_mois&y='+annee,
		success: function (data,textStatus,xhr) {
			Morris.Bar({
				data: data,
				element: 'g1',
				xkey: 'mois',
				ykeys: ['n'],
				labels: ['n. obs par mois']
			});
		}
	});
	J('#g_annee').html(annee);
}
{/literal}
</script>
Années : {foreach from=$u->get_n_obs_par_annee() item=a}
<a href="javascript:change_annee({$a.annee});">{$a.annee} <small>({$a.n})</small></a>
{/foreach}

<div id="g1" style="width:600px; height:300px;"> </div>
<div style="clear:both;"></div>

<h2 id="satlas">Carrés atlas</h2>
{foreach from=$u->liste_carre_atlas() item=car}
    {$car.nom}
{foreachelse}
    Vous ne suivez pas de carré atlas.
{/foreach}
{if $install == "picnat"}
<h2 id="reseaux">Liste des réseaux dont vous êtes membre.</h2>
{if $u->id_gdtc == null}
	<b>Pas d'identifiant GDTC associé à votre compte !</b><br/>
	Si vous êtes membre d'un réseau, demandez que soit lier votre compte Clicnat avec l'espace adhérent.
{/if}
<ul>
{foreach from=$u->get_reseaux() item=reseau}
	<li>{$reseau}</li>
{foreachelse}
	<li>Aucun réseau</li>
{/foreach}
</ul>
{/if}
<h2 id="#expertise">Niveau d'expertise et ajout d'espèce</h2>
<p>Certains utilisateurs, sont autorisés à ajouter des espèces manquantes à partir du référentiel du MNHN.</p>
<p><ul><li>{if $u->peut_ajouter_espece}Vous pouvez ajouter des espèces.{else}Vous ne pouvez pas ajouter des espèces.{/if}</li></ul></p>
<p>Par défaut la liste d'espèces accessibles en saisie est limitée aux espèces identifiables par le plus grand nombre.
Si vous avez les compétences et ou le matériel nécessaire, vous pouvez enlever cette limite.</p>
<p><ul><li>{if $u->expert}Vous avez accès au référentiel en entier <a href="?t=mapage&act=expert&v=0">remettre le filtre</a>
{else}Vous avez accès à une partie du référentiel <a href="?t=mapage&act=expert&v=1">retirer le filtre</a>{/if}</li></ul></p>
{include file="poste_foot.tpl"}
