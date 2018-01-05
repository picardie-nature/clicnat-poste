{include file="poste_head.tpl" titre_page="Réglement"}
<div style="max-height:300px; overflow:auto; font-size:12px; background-color:white; border-style:solid; border-width:1px; margin:3px; padding:35px;">
	{texte nom="reglement_reseau"}
</div>
<hr/>
{if $u->agreed_the_rules()}
	<p>Vous avez accepté le réglement intérieur le {$u->reglement_date_sig_tstamp|date_format:$format_date_complet}.</p>
	<p>Vous avez également fait le choix de placer vos données en {if $u->diffusion_restreinte}diffusion restreinte{else}diffusion libre{/if}.</p>
{else}
	<form method="post" action="?t=reglement">
	<fieldset>
		<legend>Signature du réglement intérieur</legend>
		Je soussigné, {$u->nom} {$u->prenom} déclare :
		<ul>
			<li>avoir pris connaissance du réglement intérieur des réseaux naturalistes et en accepter les termes,</li>
			<li>suivant l'article 3 de ce règlement je souhaite que mes données soit considéréres comme :<br/>
				<p class="directive">
					<input type="radio" name="d_restreintes" id="no" value="0" {if !$u->diffusion_restreinte} checked {/if}>
					<label for="no">libres <small>(le choix préféré de l'association)</small></label>
				</p>
				<p class="directive">
					<input type="radio" name="d_restreintes" id="yes" value="1" {if $u->diffusion_restreinte} checked {/if}>
					<label for="yes">restreintes</label>
				</p>
				<p>
					<small>L'observateur reste dans tous les cas libre propriétaire de ses données et peut donc les utiliser
					pour un usage extérieur à l'association</small>
				</p>
			</li>
		</ul>
		<div align="center">
			<input type="hidden" name="accept" value="1"/> 
			<input id="sub" type="submit" value="Signer et accepter le réglement des réseaux naturalistes">	
		</div>
	</fieldset>
	</form>
	<script>J('#sub').button();</script>
{/if}
{include file="poste_foot.tpl"}
