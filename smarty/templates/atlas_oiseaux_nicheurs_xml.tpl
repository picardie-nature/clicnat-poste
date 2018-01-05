<data>
  <msg></msg>
  {foreach from=$annees item=annee}	
    <year value="{$annee}">
    <cells>
      {foreach from=$comptes.$annee key=carre item=data}
      {if $data.n > 0}
      <cell name="{$carre}" pressure="A">
        {foreach from=$data.esps.$annee item=esp}
          {if strlen($esp.statut)>0}
          {if $esp.statut == 'certain'}
            {assign var=statut value='confirmed'}
          {else}
            {assign var=statut value=$esp.statut}
          {/if}			
          {assign var=id_visio value=$esp.objet->get_id_referentiel_tiers('visionature')}
          {if $id_visio}
          <specie id="{$id_visio}" atlas="{$statut}"/>
          {else}
          <!-- pas de correspondance pour #{$esp.objet->id_espece} -->
          {/if}
          {/if}												
        {/foreach}
      </cell>
      {/if}
    {/foreach}
    </cells>
    </year>
{/foreach}
</data>