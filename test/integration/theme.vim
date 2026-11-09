source <sfile>:p:h:h/bootstrap.vim

let g:jb_style = 'dark'
colorscheme jb

call assert_equal('#1E1F22', JBTestAttr('Normal', 'bg'))
call assert_equal('#26282E', JBTestAttr('CursorLine', 'bg'))
call assert_equal('#2E436E', JBTestAttr('Visual', 'bg'))
call assert_equal('#4B5059', JBTestAttr('LineNr', 'fg'))
call assert_equal('#A1A3AB', JBTestAttr('CursorLineNr', 'fg'))
call assert_equal('#6F737A', JBTestAttr('SpecialKey', 'fg'))
call assert_equal('#43454A', JBTestAttr('MatchParen', 'bg'))
call assert_equal('#2B2D30', JBTestAttr('Pmenu', 'bg'))

let g:jb_style = 'light'
colorscheme jb
call assert_equal('light', &background)
call assert_equal('#FFFFFF', JBTestAttr('Normal', 'bg'))

let g:jb_style = 'dark'
let g:jb_enable_unicode = 1
colorscheme jb
call assert_match('vert:│', &fillchars)
call assert_equal('┃', g:gitgutter_sign_added)

call JBTestFinish()
