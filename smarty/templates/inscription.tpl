{include file="poste_head.tpl" titre_page="Inscription"}
{if !$suivi}
	{if !$mail_ok}
	<h1>Demande d'ouverture d'un nouveau compte contributeur</h1>
	<table>
		<tr>
			<td width="30%" valign="top">
			<form method="post" action="?t=inscription">
				<input type="hidden" name="ins" value="1"/>
				<p class="directive">Nom</p>
				<p class="valeur"><input type="text" name="nom" width="30"/></p>

				<p class="directive">Prénom</p>
				<p class="valeur"><input type="text" name="prenom" width="30"/></p>

				<p class="directive">Adresse e-mail</p>
				<p class="valeur"><input type="text" name="email" width="30"/></p>
				<br/>
				<p class="valeur"><input type="submit" value="Envoyer votre demande d'ouverture de compte"/></p>
			</form>
			</td>
			<td valign="top" width="30%">
				<p>Deux étapes sont nécessaires à l'ouverture d'un nouveau compte contributeur.
				Vous devez remplir le formulaire ci-contre. Vous recevrez un email de confirmation.<p>
				<p>Dans ce message de confirmation vous trouverez un lien qui nous permettra de valider
				votre adresse email.</p>
				<p>Il vous restera a accepter la charte du naturaliste pour obtenir votre
				mot de passe.</p>
				<p></p>
			</td>
		</tr>
	</table>
	{else}
	<h1>Demande d'ouverture d'un nouveau compte contributeur</h1>
	<p>Votre inscription a été prise en compte.</p>
	<p>Un message vous a été envoyé pour confirmer votre adresse e-mail.</p>
	{/if}
{/if}
{if $suivi}
	{if $suivi_inconnu}
		<h1>Création de votre compte contributeur</h1>
		<p>Nous ne sommes pas parvenu a retrouver votre inscription.</p>
		<p>Le lien qui vous a été envoyé doit être utilisé dans les 48 heures.</p>
		<p>Vous pouvez reprendre la procédure en <a href="?t=inscription">cliquant ici</a>.</p>
	{/if}
	{if $pre}
		{if !$confirmation_ok}
			<h1>Deuxième étape de la création de votre compte</h1>
			<p>Bonjour <b>{$pre}</b>,</p>
			{texte nom="base/creation_compte_etape2"}
			<form method="post" action="?t=inscription&suivi={$pre->suivi}">
				<input type="hidden" name="ok" value="1" />
				<input type="submit" value="J'ai pris connaissance des conditions d'accès que j'accepte" />
			</form>
		{else}
			{texte nom="base/creation_compte_fin"}
		{/if}
	{/if}
{/if}
{include file="poste_foot.tpl"}
