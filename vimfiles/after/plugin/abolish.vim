if !exists(":Abolish")
  finish
endif

" Use the plugin Vim-abolish to simplify abbreviation handling
"
" The following command:
" Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}
"
" Produces 48 abbreviations including:
" iabbrev  seperation  separation
" iabbrev desparation desperation
" iabbrev  seperately  separately
" iabbrev desparately desperately
" iabbrev  Seperation  separation
" iabbrev Desparation Desperation
" iabbrev  Seperately  Separately
" iabbrev Desparately Desperately
" iabbrev  SEPERATION  SEPARATION
" iabbrev DESPARATION DESPERATION
" iabbrev  SEPERATELY  SEPARATELY
" iabbrev DESPARATELY DESPERATELY
"
" Abolish also automatically handles the case where the first letter or the
" whole word is uppercase.
Abolish teh                                           the
Abolish taht                                          that
Abolish alos                                          also
Abolish aslo                                          also
Abolish wether                                        whether
Abolish inherant{,ly}                                 inherent{}
Abolish {,un}nec{ce,ces,e}sar{y,ily}                  {}nec{es}sar{}
Abolish {despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}  {despe,sepa}rat{}
Abolish throu{,g,ght}put                              throughput
Abolish functionnalit{y,ies}                          functionalit{}

" Abbreviations
Abolish dtf       de toute façon
Abolish s{t,v}p   s'il {te,vous} plaît
Abolish tal       tout à l'heure
Abolish tjrs      toujours
Abolish lidsa     lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
Abolish dnouz     dès Noël où un zéphyr haï me vêt de glaçons würmiens, je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !
Abolish qqun      quelqu'un
Abolish qqchose   quelque chose
Abolish qqchoses  quelques choses
" Abolish doesn't abbreviate words with hypens correctly
iabbrev rdv       rendez-vous
iabbrev Rdv       Rendez-vous
iabbrev RDV       RENDEZ-VOUS
iabbrev ptet      peut-être
iabbrev Ptet      Peut-être
iabbrev PTET      PEUT-ÊTRE

" Fix accents
Abolish ca               ça
Abolish tot              tôt
Abolish apres            après
Abolish etre             être
Abolish alle{,e,s,es}    allé{}
Abolish foret            forêt
Abolish coincidence{,s}  coïncidence{}
