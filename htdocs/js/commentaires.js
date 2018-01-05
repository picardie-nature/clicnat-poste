

function citation_ajoute_commentaire()
{
	formulaire = J('#bobs-ajoute-commtr-citation');
	J('#bobs-commtrs-citation').html('enregistrement en cours');
	J('#bobs-commtrs-citation').load('?t=citation_ajoute_commentaire&'+formulaire.serialize());
}

function citation_affiche_commentaire(id_citation,elem)
{
	J('#'+elem).load('?t=citation_liste_commentaires&id='+id_citation);
}
