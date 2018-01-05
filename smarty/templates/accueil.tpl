{include file="poste_head.tpl" titre_page="Accueil"}
{literal}
	<style>
		a.invalide { color: red; }
		.liste_especes_espece, .listes_communes_commune, .titre_liste {
			cursor: pointer;
		}
		
		.titre_liste_commune , .titre_liste_espece {
			cursor:pointer;
			font-weight: bold;
		}
		.liste_especes_espece {
			cursor: pointer;
		}
		.liste li, .reseau li {
			transition-property: background-color;
			transition-duration: 0.4s;
			padding: 2px;
		}
		.liste li:hover, .reseau li:hover {
			background-color: #C6E548;
		}
		.liste ul, .reseau ul {
			list-style-type: none;
			padding:0px;
			margin: 2px;
		}

		.liste tr {
			transition-property: background-color;
			transition-duration: 0.4s;
		}

		.liste td {
			vertical-align: top;
		}

		.liste tr:hover {
			background-color: #C6E548;
		}

		.liste table {
			border-collapse:collapse;
		}

		.liste_littoral, .liste_date { font-weight: bold;}
	</style>
{/literal}
{if !$auth_ok}
	<br/>
	<div id="login" class="desc" style="float:left; width:49%;">
		<h1>Identifiez-vous</h1>
		<div>
			{if $messageinfo}{$messageinfo}{/if}
			<form method="post" action="?t=accueil">
			    <p class="directive">Nom d'utilisateur</p>
			    <p class="valeur"><input type="text" name="username" value="" id="fm"/></p>
			    <p class="directive">Mot de passe</p>
			    <p class="valeur"><input type="password" name="password" value=""/></p>
			    <p class="valeur"><input type="hidden" name="act" value="login"/></p>
			    <p class="valeur"><input type="submit" value="Envoyer"/></p>
			</form>
			<br/>
		</div>
	</div>
	<div class="desc" style="float:left; width:49%;">
		<h1>Mot de passe perdu ?</h1>
		<div>
			{if $msg_mdp}{$msg_mdp}{/if}
			<form method="post" action="?t=accueil">
			    <p class="directive">Votre adresse e-mail</p>
			    <p class="valeur"><input type="text" name="adr"/></p>
			    <p class="valeur"><input type="submit" value="Envoyer"/></p>
			</form>
		</div>
	</div>
	<div class="desc" style="float:left; width:49%;">
		<h1>Nouvel observateur</h1>
		<div>
			<a href="?t=inscription">Ouvrir un compte</a>
		</div>
	</div>
	<div style="clear:both;"></div>
	<div class="desc" style="float:left; width:98%;">
		<h1>Informations</h1>
		<div>{texte nom="accueil_info_connexion"}</div>
	</div>
	<div style="clear:both;"></div>

	{literal}
	<script>
		J('#fm').focus();
	</script>
	{/literal}	
{else}
	{if $u->agreed_the_rules()}
		{if !$u->the_geom}
			<div class="bobs-info">
				<p>{texte nom="base/localisation_utilisateur"}</p>
			</div>
		{/if}
		{if !$u->date_naissance}
			<div class="bobs-info">
				<p>{texte nom="base/date_naissance"}</p>
			</div>
		{/if}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Mes dernières observations</div>
			<div class="bobs-demi-interieur">
				{assign var=ddate value=''}
				<ul class="liste_dernieres_obs">
				{assign var=id_obs_prev value='x'}
				{foreach from=$dernieres_obs item=cit}
					{assign var=citation value=$u->get_citation_authok($cit.id_citation)}
					{assign var=obs value=$citation->get_observation()}
					{assign var=ddate value=$obs->date_observation}
					{assign var=espace value=$obs->get_espace()}
					{if $id_obs_prev != $cit.id_observation}
						{if $id_obs_prev != 'x'}
							</ul>
						{/if}
						<li class="liste_dernieres_obs_date">le {$ddate|date_format:"%A %e %B %Y"} 
						{if $espace->get_table() eq "espace_point"}
							à {$espace->get_commune()} 
							{assign var=topos value=$espace->get_toponymes()}
							<i>
							{foreach from=$topos item=topo}
								{$topo}
							{/foreach}
							</i>
						{/if}
						<ul>
					{/if}
						<li class="liste_dernieres_obs_cit">
						{assign var=espece value=$citation->get_espece()}
						<a class="{if $citation->invalide()}invalide{/if}" href="?t=citation&id={$citation->id_citation}" title="{$espece->nom_s}">
							{if $citation->nb}
								{$citation->nb}
							{else}
								{if $citation->nb_min}
									entre {$citation->nb_min} et {$citation->nb_max}
								{/if}
							{/if}
							{$espece}
						</a>
						<small><a style="color:rgb(120,120,120);" href="?t=espece_detail&id={$citation->id_espece}" title="voir la fiche">[fiche espèce]</a></small>
						</li>
					{assign var=id_obs_prev value=$cit.id_observation}
				{foreachelse}
					<li>Vous n'avez pas encore envoyé d'observation. Cliquez sur Saisir mes observations à gauche pour commencer.</li>
				{/foreach}
					</li>
				</ul>
				</ul>
			</div>
		</div>
		<!-- dernières observations des reseaux naturalistes -->
		{assign var=reseaux value=$u->get_reseaux()}
		{assign var=n_reseau value=0}
		{foreach from=$reseaux item=reseau}
			{if $reseau->restitution_auto}
				{assign var=n_reseau value=$n_reseau+1}
			{/if}
		{/foreach}
		{if $n_reseau > 0}
		<div id="reseau_root" style="display:none; position:fixed; zindex:1000; width:50%; height:70%; top:15%; left:25%;  background-color:white; border-style:solid; border-width:1px;">
			<div id="reseau_titre" style="height:10%; text-align:center">Observations</div>
			<div id="reseau_content" style="height:80%; overflow:scroll; padding:5px;"></div>
			<div id="reseau_bas" style="height:10%; text-align:center;padding-top:3px;">
				<button id="reseau_fermer">Fermer</button>
			</div>
		</div>
		<div class="bobs-demi ravi">
			<div class="bobs-demi-titre">Observations du réseau 
				<select id="liste_choix_reseau">
					{foreach from=$reseaux item=reseau}
						{if $reseau->restitution_auto}
							<option value="{$reseau->get_id()}">{$reseau}</option>
						{/if}
					{/foreach}
				</select>
			</div>
			<div class="bobs-demi-interieur">
				{foreach from=$reseaux item=reseau}
					{include file="partiels/accueil_reseau.tpl" reseau=$reseau}
				{/foreach}
			</div>
		</div>
		<script>
			//{literal}
			function reseau_do() {
				var reseau = J('#liste_choix_reseau').val();
				J('.reseau').hide();
				J('#reseau_'+reseau).show();
				J(".r"+reseau+"liste").show();

			}
			reseau_do();
			J('#liste_choix_reseau').change(reseau_do);
			function reseau_init() {
				J('.liste_especes_espece, .listes_communes_commune').click(function () {
					var lien = J(this);
					var action = "reseau_n_jours_commune";
					var attr_id = "id_commune";
					if (lien.hasClass("liste_especes_espece")) {
						action = "reseau_n_jours_espece";
						attr_id = "id_espece";
					}
					var p = J.param({
						t: action,
						reseau: lien.attr('reseau'),
						id: lien.attr(attr_id)
					});
					J("#reseau_content").html("Téléchargement de la liste en cours...");
					J("#reseau_content").load("?"+p);
					J('#reseau_root').show();
				});
				J('#reseau_fermer').click(function () {
					J('#reseau_root').hide();
				});
				J('.reseau_liste_switch').click(function () {
					var lien = J(this);
					J('.reseau_liste').hide();
					J('#'+lien.attr("div")).show();
				});
			}
			reseau_init();
			//{/literal}
		</script>
		{/if}
		{if $u->membre_reseau('av')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Avifaune</div>
			<div class="bobs-demi-interieur">
				<p>Vous êtes membre du réseau avifaune, vous pouvez consulter les cartes des atlas oiseaux hivernants et nicheurs.</p>
				<ul>
					<li><a href="?t=atlas_hivernant">Atlas oiseaux hivernants</a></li>
					<li>Atlas oiseaux nicheurs
						<ul>
							<li><a href="?t=atlas_oiseaux_nicheurs">Carte avec statuts "automatique"</a></li>
							<li><a href="?t=atlas_oiseaux_nicheurs_carte_resp">Carte avec statuts des responsables de carrés</a></li>
							<li>Choix des statuts sur vos carrés
								<ul>
								{foreach from=$u->liste_carre_atlas() item=carre}
									<li><a href="?t=atlas_oiseaux_nicheurs_r_carre&id_espace={$carre.id_espace}">{$carre.nom}</a></li>
								{foreachelse}
									<li>Vous n'avez pas de carré attribué</li>
								{/foreach}
								</ul>
							</li>
						</ul>
					</li>
					<li><a href="?t=liste_espace_carte&id=1">Sites Wetlands</a></li>
					<li><a href="?t=redirection_archives_geor">Archives Section Oise : Bulletin</a></li>
				</ul>
				{texte nom="poste/oiseaux/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('cs')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Chiroptères</div>
			<div class="bobs-demi-interieur">
			<p>Vous êtes membres du réseau chiroptères.</p>
				{if $u->acces_chiros}
					<p>Vous avez accès au suivi des prospections.</p>
					<ul>
						<li><a href="?t=chiros">Prospections Chiros</a></li>
					</ul>
				{else}
					<p>Si vous participez aux prospections, vous pouvez demander
					un accès au suivi des propsections au coordinateur du réseau.</p>
				{/if}
				{texte nom="poste/chiros/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('mt')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Mammifères terrestres</div>
			<div class="bobs-demi-interieur">
				{texte nom="poste/mammiferesterrestres/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('co')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Coccinelles</div>
			<div class="bobs-demi-interieur">
				{texte nom="poste/coccinelles/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('sc')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Criquets Sauterelles</div>
			<div class="bobs-demi-interieur">
				{texte nom="poste/orthopteres/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('li')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Libellules</div>
			<div class="bobs-demi-interieur">
				{texte nom="poste/libellules/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('pa')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Papillons</div>
			<div class="bobs-demi-interieur">
				{texte nom="poste/papillons/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('pu')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Punaises</div>
			<div class="bobs-demi-interieur">
				{texte nom="poste/punaises/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('sy')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Syrphes</div>
			<div class="bobs-demi-interieur">
				{texte nom="poste/syrphes/infos"}
			</div>
		</div>
		{/if}
		{if $u->membre_reseau('ar')}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Réseau Amphibiens reptiles</div>
			<div class="bobs-demi-interieur">
				<p>Vous êtes membres du réseau amphibiens reptiles.</p>
				<ul>
					<li><a href="?t=amphibiens_reptiles_carto">Cartographie points noirs amphibiens</a> (zones à prospecter et à confirmer)</li>
				</ul>
				{texte nom="poste/amphibiensreptiles/infos"}
			</div>
		</div>
		{/if}


		{if $u->structure()}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Structure</div>
			<div class="bobs-demi-interieur">
				<p>Votre compte est associé à une structure, il peux exister un référentiel permettant de passer de celui de la base
				au votre.</p>
				<p>Vous pouvez également y télécharger le référentiel de la base.</p>
				<ul>
					<li><a href="?t=structure_referentiel_espece">Référentiel espèce</a></li>
				</ul>
			</div>
		</div>
		{/if}
		<div class="bobs-demi">
			<div class="bobs-demi-titre">Derniers commentaires</div>
			<div class="bobs-demi-interieur liste">
				<table>
				<tr>
					<th></th>
					<th>Date</th>
					<th>Message</th>
					<th>Objet</th>
				</tr>
				{assign var=ctrs value=$u->get_obs_commentaires(100)}
				{foreach from=$ctrs item=ctr}
				<tr>
					<td>
						{if $ctr.type_commentaire=='info'}<img src="icones/friends.png" />{/if}
						{if $ctr.type_commentaire=='attr'}<img src="icones/tools.png" />{/if}
					</td>
					<td>{$ctr.date_commentaire|date_format:"%d-%m-%Y"}</td>
					<td>{commtr_txt commentaire=$ctr}</td>				
					<td align="center">
						{if $ctr.tble == 'citations_commentaires'}<a href='?t=citation&id={$ctr.ele_id}'>Citation<br/>{$ctr.ele_id}</a>{/if}
						{if $ctr.tble == 'observations_commentaires'}<a href='?t=observation&id={$ctr.ele_id}'>Observation<br/>{$ctr.ele_id}</a>{/if}
					</td>
				</tr>
				{/foreach}
				</table>
			</div>
		</div>
		<div style="clear:both;"></div>
	{else}
		{texte nom="poste_premiere_connexion"}
		<a href="?t=reglement">Lire et valider le réglement des réseaux naturalistes</a>
	{/if}
{/if}
{include file="poste_foot.tpl"}
