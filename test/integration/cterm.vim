source <sfile>:p:h:h/bootstrap.vim

set notermguicolors
set t_Co=256
colorscheme jb

call assert_equal('146', JBTestAttrMode('Normal', 'fg', 'cterm'))
call assert_equal('16', JBTestAttrMode('Normal', 'bg', 'cterm'))
call assert_equal('235', JBTestAttrMode('CursorLine', 'bg', 'cterm'))
call assert_equal('24', JBTestAttrMode('Visual', 'bg', 'cterm'))
call assert_equal('239', JBTestAttrMode('LineNr', 'fg', 'cterm'))
call assert_equal('243', JBTestAttrMode('SpecialKey', 'fg', 'cterm'))

call JBTestFinish()
