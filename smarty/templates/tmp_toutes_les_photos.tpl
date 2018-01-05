<html>
<h1>Toutes les photos d'oiseaux</h1>
{assign var=esp_precedente value=-1}
{foreach from=$especes item=esp}
	{foreach from=$esp->documents_liste() item=img}
		{if $esp->id_espece != $esp_precedente}
			<h2>{$esp}</h2>
			{assign var=esp_precedente value=$esp->id_espece}
		{/if}
		{if $img->get_type() == 'image'}
			{if !$img->est_en_attente()}
				<img src="?t=img&id={$img->get_doc_id()}&w=250">
			{/if}
		{/if}
	{/foreach}
{/foreach}
</html>
