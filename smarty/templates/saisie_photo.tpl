{include file=poste_head.tpl titre_page="Saisie photo"}
<ul>
{foreach from=$u->inbox_docs() item=d}
	<li>
		{assign var=doc value=$d.doc}
		{if $doc->get_type() eq "image"}
			{$doc->get_doc_id()}
			<img src="?t=img&id={$doc->get_doc_id()}&w=320" style="float:right;">
			<ul>
				<li>Envoyée le {$d.date_creation|date_format:"%d-%m-%Y %H:%M:%S"}</li>
				{assign var=t_exif_data value=$doc->get_exif_data()}
				{if $t_exif_data}
				{foreach from=$t_exif_data item=exif_data key=exif_key}
				<li>
					<b>{$exif_key}</b>:
					{if $exif_data|is_array}
						<ul>
						{foreach from=$exif_data item=sub_exif_data key=sub_exif_key}
							<li><b>{$sub_exif_key}</b>: {$sub_exif_data}</li>
						{/foreach}
						</ul>
					{else}
						{$exif_data}
					{/if}
				</li>
				{/foreach}
				{else}
				<li>Pas de données EXIF</li>
				{/if}
				
			</ul>
			<div style="clear:both;"></div>
		{/if}
	</li>
{/foreach}
</ul>
{include file=poste_foot.tpl}
