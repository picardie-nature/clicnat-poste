{literal}
<style> .ok {background-color: green; color:white;} .err {background-color: red; color:white;} </style>
{/literal}
<table>
	<tr>
		<th>État</th>
		<th>Message</th>
	</tr>
{foreach from=$tests item=test key=test_classe}
	<tr>
		<td valign="top">{if $test.passe}<span class="ok" title="{$test_classe}">valide</span>{else}<span title="{$test_classe}" class="err">échec</span>{/if}</td>
		<td valign="top">{$test.message}</td>
	</tr>
{/foreach}
</table>
<small>Attention : ces tests déterminent si l'observation doit être étudiée avec une attention particulière. Ils ne disent pas si l'observation est valide ou non.</small>
