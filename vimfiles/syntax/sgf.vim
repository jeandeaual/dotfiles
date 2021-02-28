if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim


syn case ignore

syn region sgfComment start=/C\[/ end=/\]/ skip=/\\[\[\]]/
            \ contained
syn region sgfOptions start=/\[/ end=/\]/ skip=/\\[\[\]]/
            \ contained
syn match sgfArgument /[^()"]+/
            \ contained
" See http://www.red-bean.com/sgf/proplist.html for the official list of
" properties
syn keyword sgfKeyword
            \ B W LB N BL WL OB OW TB TW
            \ LN " FF[4] properties
syn keyword sgfMainKeyword
            \ FF GM SZ AP
            \ CA ST " FF[4] properties
syn keyword sgfEntryKeyword
            \ PB PW KM DT TM BR WR RE PC PL HA RO RU ON AN AB AW SZ OT
syn region sgfArguments start=/\s*(/ end=/)/
           \ contains=ALLBUT,sgfArguments

if version >= 508
  command -nargs=+ HiLink hi def link <args>

  HiLink sgfOptions Underlined
  HiLink sgfKeyword Operator
  HiLink sgfMainKeyword String
  HiLink sgfEntryKeyword Type

  HiLink sgfArguments Identifier
  HiLink sgfArgument Constant
  HiLink sgfComment Comment

  delcommand HiLink
endif

let b:current_syntax = "sgf"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
