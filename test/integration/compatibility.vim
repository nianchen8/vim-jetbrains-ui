source <sfile>:p:h:h/bootstrap.vim

colorscheme jb

call assert_match('gui=undercurl', execute('highlight JBError'))
call assert_equal('#549159', JBTestAttr('Added', 'fg'))

call JBTestFinish()
