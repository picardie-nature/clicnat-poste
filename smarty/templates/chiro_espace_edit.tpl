<b>{$espace->nom}</b>
<form id="f_espace_chiro_{$espace->id_espace}">
    <input type="hidden" name="id_espace" value="{$espace->id_espace}"/>

    {include file="g_tag.tpl" id_tag=413 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=420 obj=$espace table="espace_tags"}

    {include file="g_tag.tpl" id_tag=555 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=551 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=526 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=513 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=518 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=545 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=540 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=533 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=495 obj=$espace table="espace_tags"}
    {include file="g_tag.tpl" id_tag=501 obj=$espace table="espace_tags"}
</form>