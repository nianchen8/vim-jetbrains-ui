source <sfile>:p:h:h/bootstrap.vim

if empty($JB_COC_RUNTIME)
  call JBTestFinish()
endif

execute 'set runtimepath^=' . fnameescape($JB_COC_RUNTIME)
filetype plugin indent on
runtime plugin/coc.vim
colorscheme jb
enew
setfiletype python
call coc#start()

let s:attempts = 0
while empty(JBTestAttr('CocErrorSign', 'sp')) && s:attempts < 50
  sleep 100m
  let s:attempts += 1
endwhile

call assert_equal('#F75464', JBTestAttr('CocErrorSign', 'sp'))
call assert_equal('#2B2D30', JBTestAttr('CocPumMenu', 'bg'))
call assert_equal('#4B5059', JBTestAttr('CocInlayHint', 'fg'))

call JBTestFinish()
