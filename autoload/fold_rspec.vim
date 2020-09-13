" Public Functions =============================================================
function! fold_rspec#foldexpr(lnum)
  if s:an_rspec_block_opens_on(a:lnum)
    return '>' . (s:indent_level(a:lnum) + 1)
  elseif !s:blank(a:lnum + 1) && s:an_rspec_block_closes_on(prevnonblank(a:lnum))
    return '<' . (s:indent_level(prevnonblank(a:lnum)) + 1)
  else
    return '='
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
function! s:an_rspec_block_opens_on(lnum)
  return (getline(a:lnum) =~ s:block_heading_regex('rspec')) ||
        \ (getline(a:lnum) =~ s:block_heading_regex('capybara'))
endfunction

function! s:block_heading_regex(keyword_type)
  if !exists('s:keywords')
    let s:keywords = { 'rspec':    ['(before|after|around|let!=|subject!=)(\(.+\))=',
          \                         'x=it(_behaves_like|_should_behave_like)=',
          \                         '(RSpec\.)=([xf]=(describe|context)|example_group|shared_(examples|context))'],
          \            'capybara': ['(background|(giv|wh|th)en)(\(.+\))=',
          \                         'x=scenario',
          \                         '(RSpec\.)=([xf]=(feature))'] }
  endif

  return '\v^\s*(' . join(s:keywords[a:keyword_type], '|') . ') .*do( |.+|)=$'
endfunction

function! s:an_rspec_block_closes_on(lnum)
  if !s:a_ruby_block_closes_on(a:lnum)
    return 0
  endif

  let l:cursor_bookmark = getcurpos()
  call cursor(a:lnum, 1)
  let l:body_start = searchpair('\<do\>', '', '\<end\>\zs', 'bW')
  call setpos('.', l:cursor_bookmark)

  return s:an_rspec_block_opens_on(l:body_start)
endfunction

function! s:a_ruby_block_closes_on(lnum)
  return getline(a:lnum) =~ '^\s*end$'
endfunction

function! s:indent_level(lnum)
  return (match(getline(a:lnum), '\S') / 2)
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

function! s:blank(lnum)
  return getline(a:lnum) =~ '^\s*$'
endfunction

" foldtext ---------------------------------------------------------------------

function! s:stats()
  let l:inner_block = range(v:foldstart + 1, prevnonblank(v:foldend) - 1)

  " don't count blank lines or comments
  call filter(l:inner_block, "getline(v:val) !~# '^\\(\\W*$\\|\\s*\#\\)'")
  return '[' . len(l:inner_block) . ']'
endfunction

function! s:drop_trailing_do(str)
  return substitute(a:str, '\s\+do\( |.\+|\)\=$', '', '')
endfunction
