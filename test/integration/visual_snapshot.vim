source <sfile>:p:h:h/bootstrap.vim

function! s:snapshot_lines(style) abort
  let g:jb_style = a:style
  colorscheme jb
  let l:groups = [
        \ 'Normal',
        \ 'CursorLine',
        \ 'Visual',
        \ 'LineNr',
        \ 'CursorLineNr',
        \ 'SpecialKey',
        \ 'MatchParen',
        \ 'Search',
        \ 'Pmenu',
        \ 'StatusLine',
        \ ]
  let l:lines = []
  for l:group in l:groups
    let l:fg = JBTestAttr(l:group, 'fg')
    let l:bg = JBTestAttr(l:group, 'bg')
    call add(l:lines, printf("%s\t%s\t%s", l:group, empty(l:fg) ? '-' : l:fg, empty(l:bg) ? '-' : l:bg))
  endfor
  return l:lines
endfunction

for s:style in ['dark', 'light']
  let s:fixture = readfile(g:jb_test_root . '/test/fixtures/visual/' . s:style . '.tsv')
  call assert_equal(s:fixture, s:snapshot_lines(s:style))
endfor

call JBTestFinish()
