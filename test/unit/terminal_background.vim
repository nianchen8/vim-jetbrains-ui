source <sfile>:p:h:h/bootstrap.vim

call assert_equal(
      \ '#1a1b26',
      \ jb#ui#parse_terminal_background("\e]11;rgb:1a1a/1b1b/2626\e\\"))
call assert_equal(
      \ '#abc123',
      \ jb#ui#parse_terminal_background("\e]11;#ABC123\e\\"))
call assert_equal(
      \ '#aabbcc',
      \ jb#ui#parse_terminal_background("\e]11;rgb:a/b/c\e\\"))
call assert_equal('', jb#ui#parse_terminal_background('invalid'))
call assert_equal('', jb#ui#parse_terminal_background([]))

call assert_equal(
      \ "\e]11;#1E1F22\e\\",
      \ jb#ui#terminal_background_sequence('#1E1F22'))
call assert_equal(
      \ '',
      \ jb#ui#terminal_background_update(
      \   '#1E1F22',
      \   "\e]11;rgb:1e1e/1f1f/2222\e\\"))
call assert_equal(
      \ "\e]11;#1E1F22\e\\",
      \ jb#ui#terminal_background_update(
      \   '#1E1F22',
      \   "\e]11;rgb:1a1a/1b1b/2626\e\\"))
call assert_equal(
      \ '',
      \ jb#ui#terminal_background_update(
      \   '#1E1F22',
      \   'invalid'))

call JBTestFinish()
