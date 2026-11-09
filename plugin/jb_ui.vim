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
  autocmd ColorScheme * call jb#ui#handle_color_scheme()
  autocmd FileType * call jb#ui#apply_buffer()
  autocmd TermResponseAll * call jb#ui#handle_terminal_response(expand('<amatch>'))
  autocmd VimLeavePre * call jb#ui#restore_terminal_background()
  autocmd VimSuspend * call jb#ui#restore_terminal_background()
  autocmd VimResume * call jb#ui#handle_color_scheme()
augroup END

call jb#ui#apply()
