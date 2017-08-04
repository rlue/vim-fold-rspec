" Public Functions =============================================================
function! rspec_folding#fold_expr(lnum)
  call s:memoize_landmarks(a:lnum)

  if s:a_block_opens_on(a:lnum)
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
    if s:a_block_opens_on(i)
      let b:rspec_folding_first_block = i | break
    endif
  endfor

  let b:rspec_folding_block_found = exists('b:rspec_folding_first_block')
endfunction

function! s:a_block_opens_on(lnum)
  if !exists('s:keywords')
    let s:keywords = ['\(RSpec\.\)\=\([xf]\=describe\|[xf]\=context\|example_group\|shared_examples\|shared_context\)',
                \     '\(before\|let\|subject\|given\|when\|then\)\((.\+)\)\=',
                \     'x\=it\(_behaves_like\|_should_behave_like\|_has_behavior\)\=',
                \     'feature', 'background', 'scenario']
  endif

  return getline(a:lnum) =~ '^\s*\(' . join(s:keywords, '\|') . '\) .\+ do$'
endfunction

function! s:a_block_closes_on(lnum)
  return getline(a:lnum) =~ '^\s*end$'
endfunction

function! s:indent_level(lnum)
  return ((match(getline(a:lnum), '\S') / 2) + 1)
endfunction

function! s:the_first_block_opens_before(lnum)
  return b:rspec_folding_block_found && a:lnum > b:rspec_folding_first_block
endfunction

function! s:last_block_boundary(lnum)
  if a:lnum < 1 | return 0 | endif

  if s:a_block_opens_on(a:lnum) || s:a_block_closes_on(a:lnum)
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
