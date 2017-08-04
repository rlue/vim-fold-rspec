if expand('%:t:r') =~ '_spec$'
  let &l:foldenable = 1
  if exists('g:rspec_folding_default_level')
    let &l:foldlevel  = g:rspec_folding_default_level
  endif
  let &l:foldmethod = 'expr'
  let &l:foldexpr   = 'rspec_folding#fold_expr(v:lnum)'
  let &l:foldtext   = 'rspec_folding#fold_text()'
endif
