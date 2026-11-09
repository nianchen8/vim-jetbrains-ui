source <sfile>:p:h:h/bootstrap.vim

let s:defaults = jb#ui#normalize_config({})
call assert_equal(1, s:defaults.enabled)
call assert_equal(1, s:defaults.leading)
call assert_equal(1, s:defaults.inner)
call assert_equal(1, s:defaults.trailing)
call assert_equal(1, s:defaults.nbsp)
call assert_equal('arrow', s:defaults.tab)
call assert_equal('ascii', s:defaults.markers)

call assert_equal(0, jb#ui#normalize_config(0).enabled)
call assert_equal(1, jb#ui#normalize_config('invalid').enabled)
call assert_equal(0, jb#ui#normalize_config({'leading': 0}).leading)

let s:arrow = jb#ui#build_listchars(
      \ jb#ui#normalize_config({'markers': 'unicode'}))
call assert_match('leadmultispace:·', s:arrow)
call assert_match('space:·', s:arrow)
call assert_match('trail:·', s:arrow)
call assert_match("leadtab:→\u00a0", s:arrow)
call assert_match("tab:→\u00a0", s:arrow)
call assert_match('nbsp:␣', s:arrow)

let s:partial = jb#ui#normalize_config({
      \ 'markers': 'unicode',
      \ 'leading': 0,
      \ 'inner': 1,
      \ 'trailing': 0,
      \ 'nbsp': 0,
      \ 'tab': 'triangle',
      \ })
let s:partial_chars = jb#ui#build_listchars(s:partial)
call assert_match("leadmultispace:\u00a0", s:partial_chars)
call assert_match('space:·', s:partial_chars)
call assert_match("trail:\u00a0", s:partial_chars)
call assert_match("leadtab:\u00a0\u00a0", s:partial_chars)
call assert_match("tab:▸\u00a0", s:partial_chars)
call assert_match("nbsp:\u00a0", s:partial_chars)

call assert_match(
      \ "tab:─\u00a0",
      \ jb#ui#build_listchars(
      \   jb#ui#normalize_config({'markers': 'unicode', 'tab': 'line'})))
call assert_match(
      \ "tab:\u00a0\u00a0",
      \ jb#ui#build_listchars(
      \   jb#ui#normalize_config({'markers': 'unicode', 'tab': 'none'})))
let s:ascii = jb#ui#build_listchars(
      \ jb#ui#normalize_config({
      \   'leading': 0,
      \   'trailing': 0,
      \   'markers': 'ascii',
      \ }))
call assert_match('leadmultispace: ', s:ascii)
call assert_match('space:.', s:ascii)
call assert_match('trail: ', s:ascii)
call assert_match('tab:> ', s:ascii)
let s:ascii_line = jb#ui#build_listchars(
      \ jb#ui#normalize_config({'markers': 'ascii', 'tab': 'line'}))
let s:ascii_none = jb#ui#build_listchars(
      \ jb#ui#normalize_config({'markers': 'ascii', 'tab': 'none'}))
call assert_match('tab:- ', s:ascii_line)
call assert_match('tab:  ', s:ascii_none)
let s:auto = jb#ui#build_listchars(
      \ jb#ui#normalize_config({'markers': 'auto'}))
call assert_match('space:', s:auto)
call assert_match(
      \ 'space:·',
      \ jb#ui#build_listchars(
      \   jb#ui#normalize_config({'markers': 'unicode'})))
let s:original_ambiwidth = &ambiwidth
set ambiwidth=double
call assert_match(
      \ 'space:.',
      \ jb#ui#build_listchars(jb#ui#normalize_config({})))
let &ambiwidth = s:original_ambiwidth
call assert_match(
      \ 'conceal:…',
      \ jb#ui#build_listchars(jb#ui#normalize_config({'extra': 'conceal:…'})))

call JBTestFinish()
