source <sfile>:p:h:h/bootstrap.vim

let s:defaults = jb#ui#normalize_config({})
call assert_equal(1, s:defaults.enabled)
call assert_equal(1, s:defaults.leading)
call assert_equal(1, s:defaults.inner)
call assert_equal(1, s:defaults.trailing)
call assert_equal(1, s:defaults.nbsp)
call assert_equal('arrow', s:defaults.tab)

call assert_equal(0, jb#ui#normalize_config(0).enabled)
call assert_equal(1, jb#ui#normalize_config('invalid').enabled)
call assert_equal(0, jb#ui#normalize_config({'leading': 0}).leading)

let s:arrow = jb#ui#build_listchars(s:defaults)
call assert_match('leadmultispace:·', s:arrow)
call assert_match('space:·', s:arrow)
call assert_match('trail:·', s:arrow)
call assert_match('leadtab:→ ', s:arrow)
call assert_match('tab:→ ', s:arrow)
call assert_match('nbsp:␣', s:arrow)

let s:partial = jb#ui#normalize_config({
      \ 'leading': 0,
      \ 'inner': 1,
      \ 'trailing': 0,
      \ 'nbsp': 0,
      \ 'tab': 'triangle',
      \ })
let s:partial_chars = jb#ui#build_listchars(s:partial)
call assert_match('leadmultispace: ', s:partial_chars)
call assert_match('space:·', s:partial_chars)
call assert_match('trail: ', s:partial_chars)
call assert_match('leadtab:  ', s:partial_chars)
call assert_match('tab:▸ ', s:partial_chars)
call assert_match('nbsp: ', s:partial_chars)

call assert_match(
      \ 'tab:─ ',
      \ jb#ui#build_listchars(jb#ui#normalize_config({'tab': 'line'})))
call assert_match(
      \ 'tab:  ',
      \ jb#ui#build_listchars(jb#ui#normalize_config({'tab': 'none'})))
call assert_match(
      \ 'conceal:…',
      \ jb#ui#build_listchars(jb#ui#normalize_config({'extra': 'conceal:…'})))

call JBTestFinish()
