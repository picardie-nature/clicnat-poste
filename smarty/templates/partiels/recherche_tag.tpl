{literal}
<style>
.boite_dialogue_tag h1 {
	font-size: 14px;
}
.boite_dialogue_tag {
	position:fixed;
	top: 50%;
	left:50%;
	width: 400px;
	height:600px;
	margin-left:-200px;
	margin-top:-300px;
	z-index:42;
	background-color:white;
	border-color: #ccc;
	border-style: solid;
	border-width: 3px;
	display:none;
	padding: 10px;
}
.tag_sel {
	background-color: #efe;
}
.tag_ele {
	cursor: pointer;
}

.tag_ele:hover {
	background-color: #eee;
}
.tag_ele:hover a {
	display: inline;
}
.tag_ele a {
	padding-left: 8px;
	display: none;
}
</style>
<script>
function BoiteRechercheTag(callback) {
	this.limite_r = 50;
	this.__cback = callback;
	this.sel_index = -1;
	this.div_id = "z_recherche_tag";

	this.cback = function (r) {
		J('#z_recherche_tag').hide();
		this.__cback(r);
	}

	this.query = function (s) {
		if (s.length > 2) {
			// abandonne la requête précédente au besoin
			if (this.currentXHR) {
				// http://www.w3.org/TR/XMLHttpRequest/#the-xmlhttprequest-interface
				// au dessous de 4 la requête n'est pas terminée
				if (this.currentXHR.readyState < 4) {
					this.currentXHR.abort();
				}
			}
			var url = 'index.php?'+J.param({term: s, t: 'tag_citations_autocomplete'});
			J('#z_rech_tag').html('recherche en cours');
			this.sel_index = -1;
			this.currentXHR = J.ajax({url: url, async: true, complete: function (xhr,txt) {
				var data = J.parseJSON(xhr.responseText);
				J('#z_rech_tag').html('');
				var limite = data.length;
				if (limite > this.limite_r) {
					limite = this.limite_r;
				}
				for (var i=0; i < limite; i++) {
					J('#z_rech_tag').append('<div class="tag_ele" id="tag'+data[i].id+'">'+data[i].label+' <a href="javascript:;">choisir</a></div>');
				}

				J('#z_rech_tag > div > a').click(function(e) { 
					var p = J(e.currentTarget).parent();
					J('#z_rech_tag').data('obj').cback(p[0].id.replace(/^tag/,''));
				});

				J('#z_rech_tag > div').click(function(e) { 
					var p = J(e.currentTarget);
					J('#z_rech_tag').data('obj').cback(p[0].id.replace(/^tag/,''));
				});

			}});
		}
	}

	var input = J('#z_recherche_tag_input');
	input.data('obj', this);

	this.up = 38;
	this.down = 40;
	this.enter = 13;

	input.unbind('keyup');
	input.keyup(
		function (e) {
			var brecherche = J(e.currentTarget).data('obj');
			switch (e.which) {
				case brecherche.enter:
					if (brecherche.sel_index >= 0) {
						var i = J(J('#z_rech_tag > div')[brecherche.sel_index]);
						brecherche.cback(i[0].id.replace(/^tag/,''));
					}
					break;
				case brecherche.down:
					l = J('#z_rech_tag > div');
					if (brecherche.sel_index < l.length - 1) {
						J('#z_rech_tag > div').removeClass('tag_sel');
						brecherche.sel_index++;
						J(J('#z_rech_tag > div')[brecherche.sel_index]).addClass('tag_sel');
					}
					break;
				case brecherche.up:
					if (brecherche.sel_index > 0) {
						J('#z_rech_tag > div').removeClass('tag_sel');
						brecherche.sel_index--;
						J(J('#z_rech_tag > div')[brecherche.sel_index]).addClass('tag_sel');
					}
					break;
				default:
					brecherche.query(e.currentTarget.value);
			}

		}
	);

	input.val(''); // vide le champ au cas où il ne serai pas vide	

	// initialise le bouton fermer
	J('#a_tag_fermer').click(function() { J('#z_recherche_tag').hide(); });

	// vide la zone de résultat
	J('#z_rech_tag').html('');
	J('#z_rech_tag').data('obj',this);

	// ouvre la boite
	J('#'+this.div_id).show();
	input.focus();
}
</script>
{/literal}
<div class="boite_dialogue_tag" id="z_recherche_tag">
	<h1>Recherche d'un code comportement ou d'une étiquette</h1>
	Recherche : <input type="text" id="z_recherche_tag_input"/>
	<div id="z_rech_tag" style="height:520px; overflow:scroll;"></div>
	<div style="clear:both;"></div>
	<div style="text-align:right;">
		<a href="javascript:;" id="a_tag_fermer">fermer</a>
	</div>
</div>
