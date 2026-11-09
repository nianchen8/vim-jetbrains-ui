set nocompatible
set termguicolors

let s:root = expand('<sfile>:p:h:h')
execute 'set runtimepath^=' . fnameescape(s:root)

function! JBTestAttr(group, attr) abort
  return synIDattr(synIDtrans(hlID(a:group)), a:attr, 'gui')
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
