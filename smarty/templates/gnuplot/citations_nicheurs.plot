{assign var=moy value=$espece->citations_n_moyen_par_semaine()}
{assign var=bornes value=$espece->bornes_moyenne_chanteurs()}

set terminal png

set xlabel "Semaine"
set ylabel "Citations"
set xrange [1:54]

set arrow from {$bornes.moy_premiere_date}/7,{$moy} to {$bornes.moy_derniere_date}/7,{$moy};
plot "-" using 1:2 with boxes title "nombre de citations chanteurs"
{foreach from=$espece->citations_chanteurs_par_semaine() item=s}
{$s.semaine}	{$s.n}
{/foreach}
e
