source <sfile>:p:h:h/bootstrap.vim

call assert_true(v:version >= 901)
call assert_equal('utf-8', &encoding)
call assert_match('utf-\=8', tolower(v:ctype))
call assert_true(has('syntax'))
call assert_true(has('termguicolors'))
call assert_true(has('profile'))
call assert_true(exists('*json_decode'))
call assert_true(exists('*assert_equal'))
call assert_true(exists('+cursorlineopt'))

if v:version >= 902
  call assert_true(exists('##TermResponseAll'))
endif

call JBTestFinish()
