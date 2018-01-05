<div id="reseau_{$reseau->id}" class="reseau">
	<div id="r{$reseau->id}_accueil">
		[ <a href="javascript:;" class="reseau_liste_switch" div="r{$reseau->id}_ce">Commune &gt espèces</a> -
		<a href="javascript:;"  class="reseau_liste_switch" div="r{$reseau->id}_ec">Espèce &gt communes</a> -
		<a href="javascript:;"  class="reseau_liste_switch" div="r{$reseau->id}_li">Littoral</a> ]
	</div>
	<div id="r{$reseau->id}_ce" class="reseau_liste r{$reseau->id}liste">{include file=$reseau->restitution_f_ce}</div>
	<div id="r{$reseau->id}_ec" class="reseau_liste r{$reseau->id}liste">{include file=$reseau->restitution_f_ec}</div>
	<div id="r{$reseau->id}_li" class="reseau_liste r{$reseau->id}liste">{include file=$reseau->restitution_f_li}</div>
</div>

