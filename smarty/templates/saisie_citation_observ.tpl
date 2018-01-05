{foreach from=$observation->get_observateurs() item=o}
	<li id="{$o.id_utilisateur}"><a href="javascript:supprimer_observateur({$o.id_utilisateur});">{$o.nom} {$o.prenom}</a></li>
{/foreach}
