" JetBrains-like editor display configuration for Vim.

function! jb#ui#defaults() abort
  return {
        \ 'enabled': 1,
        \ 'leading': 1,
        \ 'inner': 1,
        \ 'trailing': 1,
        \ 'nbsp': 1,
        \ 'tab': 'arrow',
        \ 'space_char': '·',
        \ 'nbsp_char': '␣',
        \ 'extends': '›',
        \ 'precedes': '‹',
        \ 'extra': '',
        \ }
endfunction

function! jb#ui#normalize_config(raw) abort
  if type(a:raw) == v:t_number
    let l:raw = { 'enabled': a:raw }
  elseif type(a:raw) == v:t_dict
    let l:raw = a:raw
  else
    let l:raw = {}
  endif
  return extend(jb#ui#defaults(), l:raw, 'force')
endfunction

function! s:flag(config, key) abort
  return get(a:config, a:key, 0) ? 1 : 0
endfunction

function! s:tab_marker(config) abort
  if get(a:config, 'tab', 'arrow') ==# 'triangle'
    return '▸ '
  elseif get(a:config, 'tab', 'arrow') ==# 'line'
    return '─ '
  elseif get(a:config, 'tab', 'arrow') ==# 'none'
    return '  '
  endif
  return '→ '
endfunction

function! jb#ui#build_listchars(config) abort
  let l:dot = get(a:config, 'space_char', '·')
  let l:tab = s:tab_marker(a:config)
  let l:items = [
        \ 'leadmultispace:' . (s:flag(a:config, 'leading') ? l:dot : ' '),
        \ 'space:' . (s:flag(a:config, 'inner') ? l:dot : ' '),
        \ 'trail:' . (s:flag(a:config, 'trailing') ? l:dot : ' '),
        \ 'leadtab:' . (s:flag(a:config, 'leading') ? l:tab : '  '),
        \ 'tab:' . (s:flag(a:config, 'inner') ? l:tab : '  '),
        \ 'nbsp:' . (s:flag(a:config, 'nbsp') ? get(a:config, 'nbsp_char', '␣') : ' '),
        \ 'extends:' . get(a:config, 'extends', '›'),
        \ 'precedes:' . get(a:config, 'precedes', '‹'),
        \ ]

  let l:extra = get(a:config, 'extra', '')
  if !empty(l:extra)
    call add(l:items, l:extra)
  endif

  return join(l:items, ',')
endfunction

function! jb#ui#get_config() abort
  return jb#ui#normalize_config(get(g:, 'jb_whitespace', {}))
endfunction

function! jb#ui#apply() abort
  let l:config = jb#ui#get_config()
  if s:flag(l:config, 'enabled')
    set list
    let &listchars = jb#ui#build_listchars(l:config)
  else
    set nolist
  endif

  if get(g:, 'jb_cursorline', 1)
    set cursorline
    if exists('+cursorlineopt')
      set cursorlineopt=both
    endif
  else
    set nocursorline
  endif

  let l:margin = get(g:, 'jb_right_margin', 0)
  if type(l:margin) == v:t_number && l:margin > 0
    let &colorcolumn = string(l:margin)
  else
    set colorcolumn=
  endif
endfunction

function! jb#ui#apply_buffer() abort
  let l:config = get(g:, 'jb_soft_wrap', {})
  if type(l:config) != v:t_dict || !get(l:config, 'enabled', 0)
    return
  endif

  let l:filetypes = get(l:config, 'filetypes', ['markdown'])
  if index(l:filetypes, &filetype) < 0
    setlocal nolinebreak
    setlocal showbreak=
    return
  endif

  setlocal wrap linebreak
  if exists('+breakindent')
    setlocal breakindent
  endif
  let &l:showbreak = get(l:config, 'showbreak', '↳ ')
endfunction

function! jb#ui#set(key, value) abort
  let l:config = jb#ui#get_config()
  let l:config[a:key] = a:value
  let g:jb_whitespace = l:config
  call jb#ui#apply()
endfunction

function! jb#ui#toggle() abort
  call jb#ui#set('enabled', !s:flag(jb#ui#get_config(), 'enabled'))
endfunction

function! jb#ui#status() abort
  let l:config = jb#ui#get_config()
  echo printf(
        \ 'jb whitespace: enabled=%d leading=%d inner=%d trailing=%d nbsp=%d tab=%s',
        \ s:flag(l:config, 'enabled'),
        \ s:flag(l:config, 'leading'),
        \ s:flag(l:config, 'inner'),
        \ s:flag(l:config, 'trailing'),
        \ s:flag(l:config, 'nbsp'),
        \ get(l:config, 'tab', 'arrow'))
endfunction

function! s:normalize_hex_component(value) abort
  if strlen(a:value) >= 2
    return tolower(strpart(a:value, 0, 2))
  endif
  return tolower(repeat(a:value, 2))
endfunction

function! jb#ui#parse_terminal_background(response) abort
  if type(a:response) != v:t_string || empty(a:response)
    return ''
  endif

  let l:rgb = matchlist(
        \ a:response,
        \ '\c]11;rgb:\(\x\+\)/\(\x\+\)/\(\x\+\)')
  if !empty(l:rgb)
    return '#' .
          \ s:normalize_hex_component(l:rgb[1]) .
          \ s:normalize_hex_component(l:rgb[2]) .
          \ s:normalize_hex_component(l:rgb[3])
  endif

  let l:hex = matchlist(a:response, '\c]11;#\(\x\{6}\)')
  if !empty(l:hex)
    return '#' . tolower(l:hex[1])
  endif

  return ''
endfunction

function! jb#ui#terminal_background_sequence(color) abort
  return "\<Esc>]11;" . a:color . "\<Esc>\\"
endfunction

function! jb#ui#terminal_background_update(target, response) abort
  let l:original = jb#ui#parse_terminal_background(a:response)
  if empty(l:original) || a:target ==? l:original
    return ''
  endif
  return jb#ui#terminal_background_sequence(a:target)
endfunction

let s:original_background = ''
let s:terminal_target = ''
let s:terminal_managed = 0
let s:terminal_applied_color = ''

function! s:terminal_response() abort
  if get(v:, 'testing', 0) && exists('g:jb_test_terminal_background_response')
    return g:jb_test_terminal_background_response
  endif
  return get(v:, 'termrbgresp', '')
endfunction

function! s:terminal_emit(sequence) abort
  if get(v:, 'testing', 0) && exists('g:JBTestTerminalBackgroundEmitter')
    call call(g:JBTestTerminalBackgroundEmitter, [a:sequence])
    return
  endif
  call echoraw(a:sequence)
endfunction

function! s:can_manage_terminal_background() abort
  if !get(g:, 'jb_manage_terminal_background', 1)
    return 0
  endif
  if get(v:, 'testing', 0)
    return 1
  endif
  return !has('gui_running') &&
        \ exists('*echoraw') &&
        \ $TERM !=# 'dumb'
endfunction

function! jb#ui#configure_terminal_background(target) abort
  if !s:can_manage_terminal_background()
    let s:terminal_target = ''
    return ''
  endif

  let s:terminal_target = a:target
  if s:terminal_managed && s:terminal_applied_color ==? a:target
    return ''
  endif
  let l:response = s:terminal_response()
  if empty(l:response)
    if !empty(&t_RB)
      call s:terminal_emit(&t_RB)
    endif
    return ''
  endif

  let l:original = jb#ui#parse_terminal_background(l:response)
  if empty(l:original)
    return ''
  endif
  if empty(s:original_background)
    let s:original_background = l:original
  endif

  let l:sequence = jb#ui#terminal_background_update(a:target, l:response)
  if !empty(l:sequence)
    call s:terminal_emit(l:sequence)
    let s:terminal_managed = 1
    let s:terminal_applied_color = a:target
  endif
  return l:sequence
endfunction

function! jb#ui#restore_terminal_background() abort
  if !s:terminal_managed || empty(s:original_background)
    return ''
  endif
  let l:sequence = jb#ui#terminal_background_sequence(s:original_background)
  call s:terminal_emit(l:sequence)
  let s:terminal_managed = 0
  let s:terminal_applied_color = ''
  return l:sequence
endfunction

function! jb#ui#handle_terminal_response(kind) abort
  if a:kind !=# 'background'
    return
  endif
  if get(g:, 'colors_name', '') ==# 'jb' && !empty(s:terminal_target)
    call jb#ui#configure_terminal_background(s:terminal_target)
  endif
endfunction

function! jb#ui#handle_color_scheme() abort
  if get(g:, 'colors_name', '') ==# 'jb'
    if !empty(s:terminal_target)
      call jb#ui#configure_terminal_background(s:terminal_target)
    endif
  else
    call jb#ui#restore_terminal_background()
  endif
endfunction
