source <sfile>:p:h:h/bootstrap.vim

let v:testing = 1
let g:jb_manage_terminal_background = 1
let g:jb_test_terminal_background_response =
      \ "\e]11;rgb:1a1a/1b1b/2626\e\\"
let g:jb_test_terminal_background_emitted = []
let g:JBTestTerminalBackgroundEmitter = {
      \ sequence -> add(g:jb_test_terminal_background_emitted, sequence) }

let s:original_t_rb = &t_RB
let g:jb_test_terminal_background_response = ''
let &t_RB = "\e]11;?\e\\"
call jb#ui#configure_terminal_background('#1E1F22')
call assert_equal(["\e]11;?\e\\"], g:jb_test_terminal_background_emitted)

let g:jb_test_terminal_background_response = 'invalid'
call jb#ui#configure_terminal_background('#1E1F22')
call assert_equal(1, len(g:jb_test_terminal_background_emitted))

let g:jb_test_terminal_background_response =
      \ "\e]11;rgb:1a1a/1b1b/2626\e\\"
call jb#ui#configure_terminal_background('#1E1F22')
call assert_equal(
      \ ["\e]11;?\e\\", "\e]11;#1E1F22\e\\"],
      \ g:jb_test_terminal_background_emitted)

let g:colors_name = 'jb'
call jb#ui#handle_terminal_response('background')
call jb#ui#handle_terminal_response('foreground')
call assert_equal(
      \ ["\e]11;?\e\\", "\e]11;#1E1F22\e\\"],
      \ g:jb_test_terminal_background_emitted)

call jb#ui#handle_color_scheme()
call assert_equal(2, len(g:jb_test_terminal_background_emitted))

let g:colors_name = 'other'
call jb#ui#handle_color_scheme()
call assert_equal(
      \ "\e]11;#1a1b26\e\\",
      \ g:jb_test_terminal_background_emitted[-1])

call jb#ui#restore_terminal_background()
call assert_equal(3, len(g:jb_test_terminal_background_emitted))

unlet g:jb_test_terminal_background_response
unlet g:jb_test_terminal_background_emitted
unlet g:JBTestTerminalBackgroundEmitter
unlet g:jb_manage_terminal_background
unlet g:colors_name
let &t_RB = s:original_t_rb

call JBTestFinish()
