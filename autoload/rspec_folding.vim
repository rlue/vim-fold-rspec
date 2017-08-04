" Public Functions =============================================================
function! rspec_folding#fold_expr(lnum)
  call s:memoize_landmarks(a:lnum)

  if s:an_rspec_block_opens_on(a:lnum)
    return '>' . s:indent_level(a:lnum)
  elseif s:the_first_block_opens_before(a:lnum)
    return s:indent_level(s:last_block_boundary(a:lnum))
  endif
endfunction

function! rspec_folding#fold_text()
  let fold_stats = '[' . len(filter(range(v:foldstart + 1, v:foldend), "getline(v:val) !~# '^\\(\\W*$\\|\" \\)'")) . ']'
  let first_line = len(getline(v:foldstart)) < 80 ?
              \ getline(v:foldstart) . repeat(' ', 80 - len(getline(v:foldstart))) :
              \ getline(v:foldstart)
  let truncate_right = len(fold_stats) + 4
  return first_line[:(truncate_right * -1)] . ' ' . fold_stats . ' -'
endfunction

" Helper Functions =============================================================

" foldexpr ---------------------------------------------------------------------
function! s:memoize_landmarks(lnum)
  " on first run, scan for the line where the first block begins
  " (for use by s:the_first_block_opens_before())
  "
  " on subsequent runs,
  " only repeat the scan if a:lnum <= b:rspec_folding_first_block

  if (a:lnum == 1 || (exists('b:rspec_folding_first_block') && b:rspec_folding_first_block >= a:lnum)) &&
        \ s:timeout('elapsed?')
    call s:find_first_block()
    call s:timeout('reset')
  endif
endfunction

function! s:find_first_block()
  silent! unlet b:rspec_folding_first_block

  for i in range(1, line('$'))
    if s:an_rspec_block_opens_on(i)
      let b:rspec_folding_first_block = i | break
    endif
  endfor

  let b:rspec_folding_block_found = exists('b:rspec_folding_first_block')
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
  return s:a_ruby_block_closes_on(a:lnum) &&
        \ s:indent_level(s:last_block_boundary(a:lnum, 1)) >= s:indent_level(a:lnum)
endfunction

function! s:a_ruby_block_closes_on(lnum)
  return getline(a:lnum) =~ '^\s*end$'
endfunction

function! s:indent_level(lnum)
  return ((match(getline(a:lnum), '\S') / 2) + 1)
endfunction

function! s:the_first_block_opens_before(lnum)
  return b:rspec_folding_block_found && a:lnum > b:rspec_folding_first_block
endfunction

" Accepts an optional second argument to specify that the function
" should succeed only at the start (or end) of a block.
function! s:last_block_boundary(lnum, ...)
  if a:lnum < 1 | return 0 | endif

  if (!(a:0 && a:1 == 2) && s:an_rspec_block_opens_on(a:lnum)) ||
        \ (!(a:0 && a:1 == 1) && s:an_rspec_block_closes_on(a:lnum))
    return a:lnum
  else
    return s:last_block_boundary(a:lnum - 1)
  endif
endfunction

function! s:timeout(action)
  if a:action == 'elapsed?'
    return (!exists('s:timeout_marker') || (localtime() - s:timeout_marker > 1))
  elseif a:action == 'reset'
    let s:timeout_marker = localtime()
  endif
endfunction
