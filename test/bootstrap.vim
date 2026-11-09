set nocompatible
set termguicolors
silent! filetype plugin indent on
silent! syntax on

let s:root = expand('<sfile>:p:h:h')
execute 'set runtimepath^=' . fnameescape(s:root)
let g:jb_test_root = s:root

function! JBTestAttrMode(group, attr, mode) abort
  return synIDattr(synIDtrans(hlID(a:group)), a:attr, a:mode)
endfunction

function! JBTestAttr(group, attr) abort
  return JBTestAttrMode(a:group, a:attr, 'gui')
endfunction

function! JBTestFinish() abort
  if !empty(v:errors)
    for s:error in v:errors
      echomsg s:error
    endfor
    cquit
  endif
  quit!
endfunction
