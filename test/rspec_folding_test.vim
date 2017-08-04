" TEST BODY ====================================================================
" This is a regression test for a custom fold expression.
" Use `:source %` to run the test.

" Initialize test data ---------------------------------------------------------
let s:test_file = expand('%:h') . '/sample_spec.rb'
let s:plugin_file = expand('%:h:h') . '/ftplugin/ruby.vim'
let s:test_function = matchstr(filter(readfile(s:plugin_file), 'v:val =~ ''foldexpr''')[0], '''\@<=.*''\@=')
silent execute '0read ' . s:test_file
silent execute 'normal '']ma'

let s:foldlevels = { 'expected': split(getline('.')) }
let s:foldlevels.actual = copy(s:foldlevels.expected)

" Run test ---------------------------------------------------------------------
call map(s:foldlevels.actual,
      \ substitute(s:test_function, 'v:lnum', 'v:key + 1', ''))

let s:results = copy(s:foldlevels.actual)
call map(s:results, 'v:val == s:foldlevels[''expected''][v:key]')

" Report results ---------------------------------------------------------------
if count(s:results, 0) > 0
  let s:test_lines = readfile(s:test_file)

  call map(s:results, 'v:val == 0 ? v:key : 0')
  call filter(s:results, 'v:val > 0')
  echo s:results

  echo 'Errors found on the following lines: '
  for i in range(0, len(s:results) - 1)
    echo s:error_message(get(s:results, i) + 1)
  endfor
else
  echo 'Success!'
endif

" Clean up ---------------------------------------------------------------------
silent execute 'normal ''adgg'
silent normal u

" HELPER FUNCTIONS =============================================================

function! s:error_message(lnum)
  let l:lineref  = s:pad_string(a:lnum, 5)
  let l:expected = s:pad_string(s:foldlevels.expected[a:lnum - 1], 2)
  let l:actual   = s:pad_string(s:foldlevels.actual[a:lnum - 1], 2)
  return l:lineref . ': expected ' . l:expected . ', but was ' . l:actual . '.'
        \ . ' » ' . get(s:test_lines, a:lnum - 1)
endfunction

" Accepts two optional arguments: left or right padding, and padding character
function! s:pad_string(string, width, ...)
  let l:pad_char = a:0 > 1 ? a:2 : ' '
  let l:pad_dir  = a:0 > 0 ? a:1 : 'right'

  if l:pad_dir == 'left'
    return a:string . repeat(l:pad_char, a:width - strdisplaywidth(a:string))
  else
    return repeat(l:pad_char, a:width - strdisplaywidth(a:string)) . a:string
  endif
endfunction
