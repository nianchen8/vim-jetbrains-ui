source <sfile>:p:h:h/bootstrap.vim

let g:jb_manage_terminal_background = 1
let $TERM = 'xterm-256color'
let &t_RB = ''

call assert_equal(
      \ '',
      \ jb#ui#configure_terminal_background('#1E1F22'))

call JBTestFinish()
