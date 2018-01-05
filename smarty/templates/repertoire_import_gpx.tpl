<br/>

<h1>Chargement d'un fichier GPX.</h1>

<p>Les fichiers GPX contiennent des coordonnées de localisations.
Ils sont souvent produits par des systèmes équipées d'une 
puce GPS comme les GPS de randonnées.</p>
<p>Si votre téléphone portable est équipé d'un GPS il
existe certainement une application permettant de créer
ce type de fichier.</p>
<p>Pour le moment seul les Points d'intérets ou "Waypoints"
sont extraits du fichier.</p>

<form method="POST" action="index.php?t=v2_saisie_charge_gpx" enctype="multipart/form-data">
	<input type="hidden" name="MAX_FILE_SIZE" value="500000">
    <input type="file" name="gpx">
	<input type="submit" name="envoyer" value="Envoyer le fichier">
</form> 
