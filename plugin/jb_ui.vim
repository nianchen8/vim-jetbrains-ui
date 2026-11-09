" Configurable editor-display companion for the JB colour scheme.

if exists('g:loaded_jb_ui')
  finish
endif
let g:loaded_jb_ui = 1

command! JBWhitespaceOn call jb#ui#set('enabled', 1)
command! JBWhitespaceOff call jb#ui#set('enabled', 0)
command! JBWhitespaceToggle call jb#ui#toggle()
command! JBWhitespaceStatus call jb#ui#status()

augroup JBEditorUI
  autocmd!
  autocmd ColorScheme * call jb#ui#apply()
augroup END

call jb#ui#apply()
