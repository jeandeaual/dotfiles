" Vim syntax plugin.
" Language: kif
" Maintainer: %USER% <%MAIL%>
" Version:  0.1
" Description:  Shogi kif format syntax file.
" Last Change:  2014-04-07
" License:  Vim License (see :help license)
" Location: syntax/kif.vim
"
" See %FILE%.txt for help. This can be accessed by doing:
"
" :helptags ~/.vim/doc
" :help %FILE%

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim


syntax match kifHeader /^.*：/
syntax match kifProgInfo "#.*$"
syntax match kifComment "\*.*$" contains=kifHeader
syntax match kifMove /^\s*\d+/
syntax match kifSpecialMove /同/
syntax match kifColumnMove /[０１２３４５６７８９]/
syntax match kifRowMove /[一二三四五六七八九十]/
syntax match kifPiece /[王玉飛角金銀桂香歩龍馬全圭杏とv]/
syntax match kifAction /[成打]/
syntax match kifAction /投了/
syntax match kifAction /詰み/
syntax match kifTime /(.\{-}\/.\{-})/
syntax match kifFrom /(\d\d)/
syntax region kifMovesHeader start=/手数/ end=/$/ oneline
syntax region kifConclusion start=/^まで/ end=/$/ oneline

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
highlight def link kifHeader Statement
highlight def link kifProgInfo Comment
highlight def link kifComment Comment
highlight def link kifMove Comment
highlight def link kifSpecialMove Number
highlight def link kifColumnMove Number
highlight def link kifRowMove Character
highlight def link kifPiece Type
highlight def link kifAction Special
highlight def link kifTime Function
highlight def link kifFrom Identifier
highlight def link kifMovesHeader Special
highlight def link kifConclusion Special

let b:current_syntax = "kif"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
