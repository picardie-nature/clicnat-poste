<style>
	{literal}
		div.autocomplete {
			position:absolute;
			width:250px;
			background-color:white;
			border:1px solid #888;
			margin:0;
			padding:0;
		}

		div.autocomplete ul {
			list-style-type:none;
			margin:0;
			padding:0;
		}

		div.autocomplete ul li.selected {
			 background-color: #ffb;
		}

		div.autocomplete ul li {
			 list-style-type:none;
			 display:block;
			 margin:0;
			 padding:2px;
			 height:32px;
			 cursor:pointer;
		}
		.informal {
			font-size: smaller;
		}
	{/literal}
</style>

Nom de l'espèce :
<input type="hidden" id="extr_id_espece" name="id_espece" value=""/>
<input type="hidden" name="classe" value="bobs_ext_c_espece"/>

<input type="text" name="espece" id="espece" size="50"/><br/>
<div id="espece_choix" class="autocomplete"></div>
<div id="recherche_en_cours">Recherche en cours</div>

{literal}
<script>
function extr_sel(txt, li) {
    document.getElementById('extr_id_espece').value = li.id;
}
new Ajax.Autocompleter('espece', 'espece_choix', '?t=espece_autocomplete', {
				afterUpdateElement: extr_sel,
				indicator: 'recherche_en_cours'
				});
</script>
{/literal}