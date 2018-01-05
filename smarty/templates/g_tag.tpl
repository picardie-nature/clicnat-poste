{php}
$id_tag = $this->get_template_vars('id_tag');
$obj = $this->get_template_vars('obj');
$tag = new bobs_tags($this->db, $id_tag);
$this->assign_by_ref('tag', $tag);
{/php}
<p class="directive">{$tag->lib}</p>
{assign var=tv value=$obj->get_tag($id_tag)}
<p class="valeur">
	<select name="tag_{$tag->id_tag}">
	{foreach from=$tag->get_v_text_values($table) item=v}
		<option value="{$v.v_text}" {if $v.v_text==$tv.v_text}selected=true{/if}>{$v.v_text}</option>
	{/foreach}
	</select>
</p>
