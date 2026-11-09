source <sfile>:p:h:h/bootstrap.vim

let g:jb_soft_wrap = {
      \ 'enabled': 1,
      \ 'filetypes': ['markdown'],
      \ 'showbreak': '↳ ',
      \ }
let g:jb_right_margin = 120
let g:jb_cursorline = 0

runtime plugin/jb_ui.vim
colorscheme jb
call jb#ui#apply()

call assert_equal(0, &cursorline)
call assert_equal('120', &colorcolumn)

enew
setlocal filetype=markdown
call assert_equal(1, &l:wrap)
call assert_equal(1, &l:linebreak)
call assert_equal(1, &l:breakindent)
call assert_equal('↳ ', &l:showbreak)

enew
setlocal filetype=python
call assert_equal(0, &l:linebreak)
call assert_equal('', &l:showbreak)

let g:jb_cursorline = 1
call jb#ui#apply()
call assert_equal(1, &cursorline)

let g:jb_right_margin = 0
call jb#ui#apply()
call assert_equal('', &colorcolumn)

call JBTestFinish()
