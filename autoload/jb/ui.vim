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
