{literal}
<style>
.boite_dialogue_structure h1 {
	font-size: 14px;
}
.boite_dialogue_structure {
	position:fixed;
	top: 50%;
	left:50%;
	width: 600px;
	height:400px;
	margin-left:-300px;
	margin-top:-200px;
	z-index:42;
	background-color:white;
	border-color: #ccc;
	border-style: solid;
	border-width: 3px;
	display:none;
	padding: 10px;
}
</style>
<script>
function BoiteChoixStructure() {
	this.chargement = function (msgdeb) {
		J('#bds_etat').html(msgdeb);
		J.ajax({
			url : '?t=structure_choix_liste',
			success: function (data, stat, xhr) {
				r = J.parseJSON(data);
				log(r);
				J('#bds_etat').html('');
				J('.bds_struct_choix').attr('checked', false);
				for (var i=0; i<r.length; i++) {
					J('#bds_s'+r[i]).attr('checked', true);
				}
			}
		});

	}
	J('#bds_b_fermer').unbind('click');
	J('#bds_b_fermer').click(function () {J('#z_structure').hide();});
	var s = J('.bds_struct_choix');
	for (var i=0; i<s.length; i++) {
		log(s[i].value);
		J(s[i]).data('boite', this);
		J(s[i]).unbind('click');
		J(s[i]).click(function () {
			J('#bds_etat').html('enregistrement');
			J.ajax({
				url: '?'+J.param({
					t: 'structure_choix_toggle',
					structure: this.value
				}),
				async: false
			});
			var b = J(this).data('boite');
			b.chargement('mise à jour affichage...');
		});
	}
	this.chargement('Chargement...');
	J('#z_structure').show();
}
</script>
{/literal}
<div class="boite_dialogue_structure" id="z_structure">
	<h1>Choix structures</h1>
	<p>En cochant une ou plusieurs structures partenaires proposées vous considérez que vos données (originales) seront
	utilisées librement par la ou les structures en question.</p>
	<p>Ceci permettra à ces dernières de bénéficier d'un lot de données identifié pouvant inclure des observations
	hors de leur champ habituel d'intervention.</p>
	<ul>
		{foreach from=$structures item=struct key=id}
			<li>
				<input type="checkbox" class="bds_struct_choix" id="bds_s{$id}" value="{$id}">
				<label for="bds_s{$id}">{$struct}</label>
			</li>
		{/foreach}
	</ul>
	<p id="bds_etat"></p>
	<p>Le lien est fait après le choix de l'espèce. Les modifications ne sont pas rétroactives.</p>
	<p>Votre choix est conservé pendant la durée de cette connection.</p>
	<a href="javascript:;" id="bds_b_fermer">fermer</a>
</div>
