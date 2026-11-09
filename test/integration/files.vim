source <sfile>:p:h:h/bootstrap.vim

execute 'silent edit ' . fnameescape(g:jb_test_root . '/test/fixtures/python_case.py')
silent! setlocal filetype=python
call cursor(1, 1)
call search('match')
call assert_equal('pythonConditional', synIDattr(synID(line('.'), col('.'), 1), 'name'))
call search('case')
call assert_equal('pythonConditional', synIDattr(synID(line('.'), col('.'), 1), 'name'))

execute 'silent edit ' . fnameescape(g:jb_test_root . '/test/fixtures/sample.cpp')
silent! setlocal filetype=cpp
call cursor(1, 1)
call search('int')
call assert_equal('cType', synIDattr(synID(line('.'), col('.'), 1), 'name'))

execute 'silent edit ' . fnameescape(g:jb_test_root . '/test/fixtures/sample.md')
silent! setlocal filetype=markdown
call cursor(1, 1)
call assert_equal('markdownH', strpart(synIDattr(synID(1, 1, 1), 'name'), 0, 9))
call assert_notequal('', JBTestAttr('markdownH1', 'fg'))

call JBTestFinish()
