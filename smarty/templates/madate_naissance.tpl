{include file="poste_head.tpl"  titre_page="Ma Date de Naissance"}
<h1>Ma date de naissance </h1>
<p>Veuillez renseigner votre date de naissance</p>
<div id="date_naissance_form">
	<form method="post" action="?t=madate_naissance">
		<input type="text" id="date" name="date_naissance" required="true" placeholder="jj-mm-aaaa" /> (votre date de naissance format jj-mm-annee)
		<input type="submit" value="Enregistrer" />
	</form>
</div>
</form>
{include file="poste_foot.tpl"}
