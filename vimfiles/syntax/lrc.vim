if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim


syntax case ignore

syntax match field /^\[[^\]]*\]/ contains=message
syntax match message contained /\[[^\]]*\]/hs=s+1,he=e-1 contains=keywords
syntax match keywords contained /\[[^:]*:/hs=s+1,he=e-1 contains=colon
syntax match colon contained /:/

syntax match times /^\(\[[0-9][0-9:.]*\]\)\+/ contains=time
syntax match time contained /\[[0-9][0-9:.]*\]/hs=s+1,he=e-1

syntax match timeinline /<[0-9][0-9:.]*>/ contains=time2
syntax match time2 contained /<[0-9][0-9:.]*>/hs=s+1,he=e-1

highlight link field      Statement
highlight link message    Identifier
highlight link keywords   Keyword
highlight link colon      Operator

highlight link times      Statement
highlight link time       Float

highlight link timeinline Statement
highlight link time2      Float

let b:current_syntax = "lrc"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
