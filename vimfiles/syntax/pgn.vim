" Vim Syntax file
" Language:       PGN
" Author:       Charles Ford <cford@eudoramail.com>
" pgn, or Portable Game Notation, is the standard
" notation for chess games.  Virtually all chess software
" read .pgn files, most can write .pgn files.

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim


syntax case ignore

syntax match pgnMove /[0-9]*\./
syntax match pgnSymbol /[x\+]/
syntax region pgnString start=/"/ end=/"/ contained
syntax region pgnTag start=/\[/ end=/\]/ contains=pgnString
syntax match pgnResult /[0-2]\/*[0-2]*[-][0-2]\/*[0-2]*/

highlight link pgnTag Type
highlight link pgnMove Comment
highlight link pgnString Statement
highlight link pgnSymbol Special
highlight link pgnResult String

let b:current_syntax = "pgn"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
