{literal}
<style>
.boite_date_calendrier ul {
	margin-left: 10px;
}
.boite_date_calendrier h1 {
	font-size: 14px;
}
.boite_date_calendrier {
	position:fixed;
	top: 50%;
	left:50%;
	width: 600px;
	height:400px;
	margin-left:-300px;
	margin-top:-200px;
	z-index:1042;
	background-color:white;
	border-color: #ccc;
	border-style: solid;
	border-width: 3px;
	display:none;
	padding: 10px;
}
</style>
<script>
function BoiteChoixDate() {
	this.table_espace = null; //table_espace;
	this.id_espace = null; //id_espace;
	this.id_date = null;
	this.tag = null; //tag;
	this.cback = null;

	J('#dcal_b_fermer').unbind('click');
	J('#dcal_b_enreg').unbind('click');

	J('#dcal_b_fermer').bind('click', function () {
		J('#z_date_calendrier').hide();
	});

	J('#dcal_b_enreg').bind('click', this, function (e) {
		var args;
		var xhr;
		var boite = J(e.currentTarget).data('boite');
		var lst_utl = J('#i_date_participants > li');

		if (lst_utl.length < 1) {
			alert('il faut plus d\'un participant');
			return false;
		}
		
		if (boite.id_date == null) {
			if (!confirm('Créer une nouvelle date ?'))
				return;
			if (J('#i_date_calendrier').val().length < 8) {
				alert('il faut une date');
				return false;
			}
				
			args = J.param({
				t: 'json',
				a: 'calendrier_ajoute_date',
				id_espace: e.data.id_espace,
				espace_table: e.data.table_espace,
				date_sortie: J('#i_date_calendrier').val(),
				tag: e.data.tag
			});

			xhr = J.ajax({url: '?'+args ,async: false});
			boite.id_date = parseInt(xhr.responseText);
		}
		var lst_utl_ids = '';
		for (var i=0; i<lst_utl.length; i++) {
			lst_utl_ids += J(lst_utl[i]).attr('id_utilisateur');
			if (i+1 < lst_utl.length)
				lst_utl_ids += ',';
		}
		args = J.param({
			t: 'json',
			a: 'calendrier_maj_date',
			id_date: boite.id_date,
			commentaire: J('#i_commentaire_calendrier').val(),
			participants: lst_utl_ids,
			date_sortie: J('#i_date_calendrier').val()
		});
		var r = J.ajax({url:'?'+args, async:false});
		var e = J.parseJSON(r.responseText);
		if (e.err == 1)
			alert(e.message);
		
		if (boite.cback) {
			boite.cback();
		}
		J('#z_date_calendrier').hide();
	});
	J('#dcal_b_enreg').data('boite', this);
	J('#i_date_calendrier').datepicker();
	J('#z_date_calendrier').show();
}
BoiteChoixDate.prototype.init_cback = function (cback) {
	this.cback = cback;
}
BoiteChoixDate.prototype.init_new = function (table_espace, id_espace, tag) {
	this.table_espace = table_espace;
	this.id_espace = id_espace;
	this.tag = tag;
	this.id_date = null;
}

BoiteChoixDate.prototype.init_date = function (id_date) {
	this.id_date = id_date;

	var args = J.param({
		t:'json',
		a:'calendrier_date',
		id_date: this.id_date
	});

	var xhr = J.ajax({
		url: '?'+args,
		async: false
	});

	var r = J.parseJSON(xhr.responseText);

	if (r.err == 1) {
		alert(r.message);
		return;
	}
	
	this.table_espace = r.espace_table;
	this.id_espace = r.id_espace;
	this.tag = r.tag;
	var d = new Date(r.date_sortie);
	var date_sortie = d.getDate()+'/'+(d.getMonth()+1)+'/'+d.getFullYear();

	J('#i_date_calendrier').val(date_sortie);
	J('#i_commentaire_calendrier').val(r.commentaire);
	var ul = J('#i_date_participants');
	ul.html('');
	var n;
	var p;
	for (n in r.participants) {
		p = r.participants[n];	
		ul.append("<li id="+p.id_utilisateur+" id_utilisateur="+p.id_utilisateur+">"+p.nom+" "+p.prenom+"</li>");
	}
}

function BoiteChoixDateEdit(id,cback) {
	//this.prototype = new BoiteChoixDate();
	BoiteChoixDate.call(this);
	this.init_date(id);
	this.init_cback(cback);
}

function BoiteChoixDateNew(table_espace, id_espace, tag) {
	BoiteChoixDate.call(this);
	this.init_new(table_espace, id_espace, tag);
}
for (var m in BoiteChoixDate.prototype) {
	BoiteChoixDateEdit.prototype[m] = BoiteChoixDate.prototype[m];
	BoiteChoixDateNew.prototype[m] = BoiteChoixDate.prototype[m];
}


</script>
{/literal}
<div class="boite_date_calendrier" id="z_date_calendrier">
	<h1>Programmation d'une sortie</h1>
	Date : <input type="text" size="10" id="i_date_calendrier"/><br/>
	Commentaire : <textarea style="width:500px; height:80px;" id="i_commentaire_calendrier"></textarea><br/>
	Participants : <a href="javascript:;" onClick="javascript:new BoiteRechercheObservateurs('i_date_participants');">modifier la liste</a>
	<ul id="i_date_participants"></ul>

	<br/>
	<div style="text-align:center;">
		<a href="javascript:;" id="dcal_b_enreg">Enregistrer</a> - 
		<a href="javascript:;" id="dcal_b_fermer">Fermer</a>
	</div>
</div>
{include file="partiels/recherche_observateurs.tpl"}
