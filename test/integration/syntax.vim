source <sfile>:p:h:h/bootstrap.vim

let g:jb_enable_italic = 1
colorscheme jb

call assert_equal('1', JBTestAttr('JBDocComment', 'italic'))
call assert_equal('1', JBTestAttr('JBConstant', 'italic'))

enew
silent! setlocal filetype=markdown
call setline(1, ['# Heading', '`inline`'])

call assert_equal('#303235', JBTestAttr('markdownCode', 'bg'))
call assert_equal('#BCBEC4', JBTestAttr('markdownCode', 'fg'))
call assert_notequal('', JBTestAttr('markdownH1', 'fg'))

call JBTestFinish()
