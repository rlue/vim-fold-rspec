" Public Functions =============================================================
function! fold_rspec#foldexpr(lnum)
  call s:memoize_where_first_block_is(a:lnum)

  if s:an_rspec_block_opens_on(a:lnum)
    return '>' . s:indent_level(a:lnum)
  elseif s:the_first_block_opens_before(a:lnum)
    return s:indent_level(s:last_block_boundary(a:lnum))
  endif
endfunction

function! fold_rspec#foldtext()
  let s:line = getline(v:foldstart)
  let s:preview_maxwidth = 80 - 1 - (strdisplaywidth(s:stats())) - 2

  let s:preview = s:drop_trailing_do(s:line)[0:(s:preview_maxwidth - 1)]
  let s:preview = substitute(s:preview, '^\( *\)  ', '\1- ', '')

  let s:padding = repeat('-', s:preview_maxwidth - strdisplaywidth(s:preview) + 1)
  let s:padding = substitute(s:padding, '\(^.\|.$\)', ' ', 'g')

  return s:preview . s:padding . s:stats() . ' -'
endfunction

" Helper Functions =============================================================

" foldexpr ---------------------------------------------------------------------
function! s:memoize_where_first_block_is(lnum)
  " foldexpr is run every time the text is changed —
  " on the line where the change occurred + the lines directly above/below.
  " If any of their foldlevels changes, foldexpr is run on every following line.
  "
  " This function keeps some document metadata in memory momentarily (1s)
  " to prevent foldexpr from having to repeat the same scan every time it runs.
  "
  " This scan should only occur when the document is first opened,
  " and again for any changes that could affect the location of the first block.

  if s:timeout('elapsed?') && !s:the_first_block_opens_before(a:lnum)
    call s:find_first_block()
    call s:timeout('reset')
  endif
endfunction

function! s:the_first_block_opens_before(lnum)
  return exists('b:fold_rspec_first_block') && a:lnum > b:fold_rspec_first_block
endfunction

function! s:find_first_block()
  silent! unlet b:fold_rspec_first_block

  for i in range(1, line('$'))
    if s:an_rspec_block_opens_on(i)
      let b:fold_rspec_first_block = i | break
    endif
  endfor
endfunction

function! s:an_rspec_block_opens_on(lnum)
  if !exists('s:rspec_keywords')
    let s:rspec_keywords = ['\(before\|let\|subject\)\((.\+)\)\=',
          \ 'x\=it', 'it\(_behaves_like\|_should_behave_like\)',
          \ '\(RSpec\.\)\=\([xf]\=\(describe\|context\)\|example_group\|shared_\(examples\|context\)\)']
    let s:capybara_keywords = ['feature', 'background', 'scenario', '\(giv\|wh\|th\)en']
  endif

  return (getline(a:lnum) =~ '^\s*\(' . join(s:rspec_keywords, '\|') . '\) .*do\( |.\+|\)\=$') ||
        \ (getline(a:lnum) =~ '^\s*\(\(' . join(s:capybara_keywords[:-2], '\|') . '\) .*do\( |.\+|\)\=\|' . get(s:capybara_keywords, -1) . '.*\)$')
endfunction

function! s:an_rspec_block_closes_on(lnum)
  " If the current line is a block `end`
  " but the preceding RSpec block heading is at a lower level of indentation,
  " the current block `end` must belong to a non-RSpec block.
  return s:a_ruby_block_closes_on(a:lnum) &&
        \ s:rel_indent(s:last_block_heading(a:lnum), a:lnum) >= 0
endfunction

function! s:a_ruby_block_closes_on(lnum)
  return getline(a:lnum) =~ '^\s*end$'
endfunction

function! s:last_block_boundary(lnum, ...)
  " Accepts an optional second argument to specify that the function
  " should succeed only at the start (or end) of a block. (Start = 1 / End = 2)
  if a:lnum < 1 | return 0 | endif

  if (!(a:0 && a:1 == 2) && s:an_rspec_block_opens_on(a:lnum)) ||
        \ (!(a:0 && a:1 == 1) && s:an_rspec_block_closes_on(a:lnum))
    return a:lnum
  else
    return s:last_block_boundary(a:lnum - 1)
  endif
endfunction

function! s:last_block_heading(lnum)
  return s:last_block_boundary(a:lnum, 1)
endfunction

function! s:indent_level(lnum)
  return ((match(getline(a:lnum), '\S') / 2) + 1)
endfunction

function! s:rel_indent(a, b)
  " Compares indent levels of line numbers a and b.
  " Returns a number (-1, 0, 1), like Ruby's spaceship operator (<=>).
  if s:indent_level(a:a) < s:indent_level(a:b)
    return -1
  else
    return s:indent_level(a:a) > s:indent_level(a:b)
  endif
endfunction

function! s:timeout(action)
  if a:action == 'elapsed?'
    return (!exists('s:timeout_marker') || (localtime() - s:timeout_marker > 1))
  elseif a:action == 'reset'
    let s:timeout_marker = localtime()
  endif
endfunction

" foldtext ---------------------------------------------------------------------

function! s:stats()
  let l:inner_block = range(v:foldstart + 1, prevnonblank(v:foldend) - 1)

  " don't count blank lines or comments
  call filter(l:inner_block, "getline(v:val) !~# '^\\(\\W*$\\|\\s*\#\\)'")
  return '[' . len(l:inner_block) . ']'
endfunction

function! s:drop_trailing_do(str)
  return substitute(str, '\s+do$', '', '')
endfunction
