source <sfile>:p:h:h/bootstrap.vim

if empty($JB_CPP_RUNTIME)
  call JBTestFinish()
endif

execute 'set runtimepath^=' . fnameescape($JB_CPP_RUNTIME)
execute 'set runtimepath+=' . fnameescape($JB_CPP_RUNTIME . '/after')
execute 'silent edit ' . fnameescape(g:jb_test_root . '/test/fixtures/sample.cpp')
silent! setlocal filetype=cpp
silent! setlocal syntax=cpp
call cursor(1, 1)
call search('std::vector')
call assert_equal('cppSTLtype', synIDattr(synID(line('.'), col('.') + 5, 1), 'name'))

call JBTestFinish()
