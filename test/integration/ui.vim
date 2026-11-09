source <sfile>:p:h:h/bootstrap.vim

let g:jb_whitespace = {
      \ 'enabled': 1,
      \ 'leading': 1,
      \ 'inner': 1,
      \ 'trailing': 1,
      \ 'nbsp': 1,
      \ 'tab': 'arrow',
      \ }

runtime plugin/jb_ui.vim
colorscheme jb

call assert_equal(1, &list)
call assert_equal(
      \ jb#ui#build_listchars(jb#ui#get_config()),
      \ &listchars)
call assert_equal('#6F737A', JBTestAttr('SpecialKey', 'fg'))

JBWhitespaceOff
call assert_equal(0, &list)
call assert_equal(0, g:jb_whitespace.enabled)

JBWhitespaceOn
call assert_equal(1, &list)
call assert_equal(1, g:jb_whitespace.enabled)

JBWhitespaceToggle
call assert_equal(0, &list)
JBWhitespaceToggle
call assert_equal(1, &list)

call assert_match('enabled=1', execute('JBWhitespaceStatus'))

call JBTestFinish()
