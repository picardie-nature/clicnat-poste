{literal}
<style>
.boite_dialogue_protocole h1 {
	font-size: 14px;
}
.boite_dialogue_protocole {
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
function BoiteChoixProtocole() {
	this.en_cours = function () {
		J('#z_proto_etat').html('chargement...');
		J('#z_protocole_en_cours').load('?t=protocole_get', function (e) {
			J('#z_proto_etat').html('');
			J('#z_proto_'+e).attr('checked', true);
		});
	};

	J('.z_proto_btn').unbind('click');
	J('.z_proto_btn').data('boite', this);
	J('.z_proto_btn').click(function (e) {
		J('#z_proto_etat').html('mise à jour...');
		J.ajax({
			url: '?'+J.param({t: 'protocole_set', protocole: this.value}),
			async: false
		});
		var b = J(this).data('boite');
		b.en_cours();
	});

	J('#proto_b_fermer').unbind('click');
	J('#proto_b_fermer').click(function () { J('#z_protocole').hide()});
	this.en_cours();
	J('#z_protocole').show();
}
</script>
{/literal}
<div class="boite_dialogue_protocole" id="z_protocole">
	<h1>Choix d'un protocole ou étude</h1>
	<p>Cela permet de mettre une étiquette sur les données qui fond partie
	d'une étude ou d'un protocole particulier.</p>
	{foreach from=$protocoles item=nom key=id}
		<input type="radio" class="z_proto_btn" name="z_protocole" id="z_proto_{$id}" value="{$id}">
		<label for="z_proto_{$id}">{$nom}</label>
	{/foreach}
	<input type="radio" class="z_proto_btn" name="z_protocole" id="z_proto_aucun" value="aucun">
	<label for="z_proto_aucun">aucun</label>
	<div id="z_proto_etat"></div>
	<p>Protocole actuellement sélectionné : <span id="z_protocole_en_cours"></span></p>
	<p>Votre choix est conservé pendant la durée de cette connection.</p>
	<div style="clear:both;"></div>
	<a href="javascript:;" id="proto_b_fermer">fermer</a>
</div>
