var d = new Date();
var filtre_type = null;
var filtre_id = null;
var flux_timeline = null;
var flux_p_annee = d.getFullYear();
var flux_p_mois= d.getMonth()+1;
var mois = {
	1: "janvier",
	2: "février",
	3: "mars",
	4: "avril",
	5: "mai",
	6: "juin",
	7: "juillet",
	8: "août",
	9: "septembre",
	10: "octobre",
	11: "novembre",
	12: "décembre"
};

var age_list = undefined;
var gender_list = undefined;

function update_abbr_titles(class_prefix, list) {
	var eles = J('.'+class_prefix);
	for (var i=0; i<eles.length; i++) {
		var ele = J(eles[i]);
		if (ele.attr('title') == 'xxx') {
			if (list[ele.html()]) {
				ele.attr('title', list[ele.html()].lib);
			}
		}

	}
}

J('#z_commune').autocomplete({
	source: '?t=autocomplete_commune',
	select: function (event,ui) {
		document.location.href = '?t=flux&action=ajouter_commune&id_commune='+ui.item.value;
		event.target.value = '';
		return false;	    
	}
});
J('#z_espece').autocomplete({
	source: '?t=autocomplete_espece&nohtml=1',
	select: function (event,ui) {
		document.location.href = '?t=flux&action=ajouter_espece&id_espece='+ui.item.value;
		event.target.value = '';
		return false;
	}
});
function flux_affiche_timeline() {
	var tl = J('#timeline');
	var flux = J('#flux');

	var html_tl= '';
	var html_flux = '';
	var annees = false;
	try {
		annees = Object.keys(flux_timeline);
	} catch (e) {
		// FIX IE8
		annees = [];
		for (var annee in flux_timeline)
			if (flux_timeline.hasOwnProperty(annee))
				annees.push(annee);


	}
	for (var i=0; i<annees.length; i++) {
		annees[i] = parseInt(annees[i]);
	}
	
	annees.sort(function (a,b) { a=parseInt(a); b=parseInt(b); return a-b;});
	annees.reverse();
	
	for (var i=0; i<annees.length; i++) {
		html_tl += '<a href="#y'+annees[i]+'">'+annees[i]+'</a> ';
		html_flux += '<h1 id="y'+annees[i]+'">'+annees[i]+'</h1>';
		for (var j=flux_timeline[annees[i]].length-1;j>=0;j--) {
			html_flux += '<div class="flux_mois"><h2>'+mois[flux_timeline[annees[i]][j]]+'</h2>';
			html_flux += ' <div vide="1" annee='+annees[i]+' mois='+flux_timeline[annees[i]][j]+' class="flux-content flux-attente"></div>';
			html_flux += '</div>';
		}
	}
	tl.html(html_tl);
	flux.html(html_flux);
}

function element_est_visible(e) {
	var wh = J(window).height();
	var rect = e[0].getBoundingClientRect();
	return (rect.top >= 0 && rect.top <= wh);
}

function flux_chargement() {
	var params = {t:'flux_contenu',filtre_type:filtre_type,filtre_id:filtre_id};
	if (!flux_timeline) {
		J.ajax({
			url:'?'+J.param(params)+'&timeline=1',
			success: function (data, txtStatus, xhr) {
				flux_timeline = data;
				flux_affiche_timeline();
				flux_chargement();
			},
			error: function (data, txtStatus, xhr) {
				alert(data.responseJSON.err);
			}
		});
		return;
	}
	var listes_div = J('.flux-content.flux-attente');
	for (var i=0;i<listes_div.length;i++) {
		var div = J(listes_div[i]);
		if (element_est_visible(div)) {
			div.removeClass("flux-attente");
			div.html('Préparation des données du mois, patientez ...');
			var params_mois = {flux_p_mois:div.attr('mois'),flux_p_annee:div.attr('annee')};
			div.load('?'+J.param(params)+'&'+J.param(params_mois), function () {
				if (age_list == undefined) {
					J.ajax({
						url: '?t=json&a=age_list',
						success: function (data, txtstatus, xhr) {
							age_list = data;
							update_abbr_titles('age', age_list);
						}
					})
				} else {
					update_abbr_titles('age', age_list);
				}
				if (gender_list == undefined) {
					J.ajax({
						url: '?t=json&a=gender_list',
						success: function (data, txtstatus, xhr) {
							gender_list = data;
							update_abbr_titles('sexe', gender_list);
						}
					})
				} else {
					update_abbr_titles('sexe', gender_list);
				}

				window.setTimeout(flux_chargement, 500);
			});
			return;
		}
	}
	window.setTimeout(flux_chargement, 1000);
}
