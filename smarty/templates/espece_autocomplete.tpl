<ul>
	{foreach from=$especes item=e}
		<li id="{$e.id_espece}">
			<img src="image/30x30_g_{$e.classe|lower}.png"/>
			{$e.nom_f} 
			<span class="informal">{$e.nom_s}</span>
		</li>
	{/foreach}
</ul>
