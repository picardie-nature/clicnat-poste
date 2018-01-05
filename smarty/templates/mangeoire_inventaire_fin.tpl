{include file="mangeoire_head.tpl" titre_page="Merci"}
<div class="desc">
	<br/>
	<h1>Envoi de vos observations</h1>
	<div>
		Merci, Vos observations sont maintenant enregistrées.
		<a href="?t=mangeoire_accueil">Cliquez ici pour retourner à la page d'accueil des observations à la mangeoire.</a>
		<script>
			{literal}
			function redir() {
				document.location.href='?t=mangeoire_accueil';
			}
			setTimeout(redir, 2000);
			{/literal}
		</script>
	</div>
</div>
{include file="mangeoire_foot.tpl"}
