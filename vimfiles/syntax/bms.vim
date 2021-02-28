" Vim syntax plugin.
" Language: bms
" Maintainer: %USER% <%MAIL%>
" Version:  0.1
" Description:  Be-Music Source format syntax file.
" Last Change:  2019-09-18
" License:  Vim License (see :help license)
" Location: syntax/bms.vim
"

scriptencoding utf-8

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" Allow use of line continuation.
let s:save_cpo = &cpo
set cpo&vim

syntax match bmsComment /.*/
syntax match bmsInformation /^@[a-zA-Z0-9]\+/ nextgroup=bmsValue
syntax match bmsHeader /^#[a-zA-Z0-9]\+/ nextgroup=bmsValue
syntax match bmsInstruction /^#[0-9]\{3}[0-9A-Z]\{2}:/ nextgroup=bmsValue
syntax match bmsValue /.*/ contained

" Define the default highlighting.
" Only used when an item doesn't have highlighting yet
highlight def link bmsComment Comment
highlight def link bmsInformation Define
highlight def link bmsHeader Define
highlight def link bmsInstruction Identifier
highlight! def link bmsValue Ignore

let b:current_syntax = "bms"

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set sw=2 sts=2 et fdm=marker:
