source <sfile>:p:h:h/bootstrap.vim

let v:testing = 1
let g:jb_manage_terminal_background = 1
let g:jb_test_terminal_background_response =
      \ "\e]11;rgb:1a1a/1b1b/2626\e\\"
let g:jb_test_terminal_background_emitted = []
let g:JBTestTerminalBackgroundEmitter = {
      \ sequence -> add(g:jb_test_terminal_background_emitted, sequence) }

call jb#ui#configure_terminal_background('#1E1F22')
call assert_equal(
      \ ["\e]11;#1E1F22\e\\"],
      \ g:jb_test_terminal_background_emitted)

call jb#ui#restore_terminal_background()
call assert_equal(
      \ ["\e]11;#1E1F22\e\\", "\e]11;#1a1b26\e\\"],
      \ g:jb_test_terminal_background_emitted)

call jb#ui#restore_terminal_background()
call assert_equal(2, len(g:jb_test_terminal_background_emitted))

unlet g:jb_test_terminal_background_response
unlet g:jb_test_terminal_background_emitted
unlet g:JBTestTerminalBackgroundEmitter
unlet g:jb_manage_terminal_background

call JBTestFinish()
