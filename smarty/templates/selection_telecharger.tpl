{include file="poste_head.tpl" titre_page="Téléchargement - $s"}
{assign var=n_max value=350}
<h1>Téléchargement de "{$s->nom_selection}" - {$s->n()} citations</h1>
{if $s->n() >= $n_max}
Cette sélection contient au moins {$n_max} données et peut prendre du temps. Son extraction sera mise en file d'attente dans une "tache".
Vous pourrez télécharger le résultat dans le <a href="?t=fichiers">gestionnaire de fichiers</a> et vous pouvez également
suivre l'avancement des taches <a href="?t=taches">ici</a>. Ces deux interfaces sont accessible via le menu "Mon compte".

<fieldset>
	<legend>Téléchargements CSV : texte séparé avec des virgules</legend>
	<form method="get" action="index.php">
		<input type="checkbox" name="xy" value="1" id="xy"/>
		<label for="xy">Inclure coordonnées XY</label><br/>
		Champs enquête <select name="enq">
			<option value="">Extraire toutes les données</option>
			{foreach from=$s->enquetes_versions() item=e}
				<option value="{$e->id_enquete}.{$e->version}">{$e->enquete()}</option>
			{/foreach}

		</select><br/>
		<input type="hidden" name="t" value="selection_telecharger">
		<input type="hidden" name="sel" value="{$s->id_selection}">
		<input type="hidden" name="do" value="tache_csv">
		<button>Demander extraction CSV</button>
	</form>
	<hr/>
	<form method="get" action="index.php">
		<input type="hidden" name="t" value="selection_telecharger">
		<input type="hidden" name="sel" value="{$s->id_selection}">
		<input type="hidden" name="do" value="tache_csv_full">
		<button>Demander extraction CSV en fichiers séparés</button>
	</form>
</fieldset>
<fieldset>
	<legend>Téléchargement fichiers format SIG</legend>
	<form method="get" action="index.php">
		<input type="hidden" name="t" value="selection_telecharger">
		<input type="hidden" name="sel" value="{$s->id_selection}">
		<input type="hidden" name="do" value="tache_shp">
		Projection :
		<select name="epsg">
			<option value="2154">Lambert 93</option>
			<option value="27582">Lambert II étendue</option>
			<option value="4326">WGS 84</option>
		</select>
		<input type="checkbox" name="extra_chiro" value="1" id="l_chk"/>
		<label for="l_chk">ajouter les colonnes dédiées aux chiroptères.</label>
		<button type="submit">Demander extraction format SIG (SHP)</button>
	</form>
</fieldset>
{else}
<div class="bobs-liste">
    <ul class="bobs-liste bobs-liste-decor">
      <li>
	<div class="bobs-liste-titre">CSV pour import dans un tableur</div>
	<div class="bobs-liste-commtr">
		<form method="get" action="index.php">
			<input type="hidden" name="t" value="selection_telecharger_csv"/>
			<input type="hidden" name="sel" value="{$s->id_selection}"/>
			<input type="checkbox" name="latin1" value="1" id="c_latin1" checked="1"/>
			<label for="c_latin1">Encoder le fichier en latin1 à la place d'UTF-8 (préféré par les systèmes sous windows)</label><br/>
			<input type="checkbox" name="toponyme" value="1" id="c_topo"/>
			<label for="c_topo">Ajouter une colonne avec les toponymes</label><br/>
			<input type="checkbox" name="xy" value="1" id="c_xy"/>
			<label for="c_xy">Ajouter une colonne avec les coordonnées GPS des points</label><br/>
			Champs enquête <select name="enq">
			<option value="">Extraire tout les données</option>
			{foreach from=$s->enquetes_versions() item=e}
				<option value="{$e->id_enquete}.{$e->version}">{$e->enquete()}</option>
			{/foreach}
		</select><br/>

			<input type="submit" value="Télécharger au format CSV"/>
		</form>
	</div>
      </li>
      <li>
	<div class="bobs-liste-titre">Shapefile pour ouvrir dans un SIG</div>
	<div class="bobs-liste-commtr">
		<form method="get" action="index.php">
			<input type="hidden" name="t" value="selection_telecharger_shp" />
			<input type="hidden" name="sel" value="{$s->id_selection}" />
			Projection :
			<select name="epsg_id">
				<option value="2154">Lambert 93</option>
				<option value="27582">Lambert II étendue</option>
				<option value="4326">WGS 84</option>
			</select>
			<input type="submit" value="Télécharger"/><br/>
			<input type="checkbox" name="extra_chiro" value="1" id="l_chk"/>
			<label for="l_chk">ajouter les colonnes dédiées aux chiroptères.</label>

		</form>
	</div>
      </li>
      <li>
	  <div class="bobs-liste-titre">XLS pour import dans un tableur</div>
	  <div class="bobs-liste-commtr">
	      <a href="?t=selection_telecharger_xls&sel={$s->id_selection}">télécharger xls</a><br/>
	  </div>
      </li>
      <li>
          <div class="bobs-liste-titre">Export en fichiers CSV séparés</div>
	  <div class="bobs-liste-commtr">
	  {if !$zip_ready}
	     	<a href="?t=selection_telecharger_full&sel={$s->id_selection}">télécharger une archive</a><br/>
	  {else}
	  	<a href="?t=selection_telecharger_full&sel={$s->id_selection}">télécharger l'archive déjà préparée (plus rapide si vous n'avez pas modifier la sélection)</a><br/>
		<a href="?t=selection_telecharger_full&sel={$s->id_selection}&force=1">télécharger une nouvelle archive (nécessaire si le contenu de la sélection a changé)</a>
	  {/if}
	  </div>
      </li>
    </ul>
</div>
<div class="bobs-commtr">
	<a href="http://wiki.picardie-nature.org/doku.php?id=docclicnat:extractions#telechargement_de_selection" target="_blank">En savoir plus sur les différents exports proposés</a>
	<p>Le format CSV est un fichier texte contenant la liste de vos citations. Vous pouvez importer
	ce fichier dans un tableur pour le traiter</p>
	<p>Les fichiers au format Shapefile sont destinés aux logiciels pouvant traiter
	les données géographique, vous pouvez utiliser <a href="http://www.qgis.org">QGis</a> libre et gratuit.</p>
</div>
{/if}
{include file="poste_foot.tpl"}
