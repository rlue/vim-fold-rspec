if expand('%:t:r') =~ '_spec$'
  let &l:foldenable = 1
  if exists('g:fold_rspec_default_level')
    let &l:foldlevel  = g:fold_rspec_default_level
  endif
  let &l:foldmethod = 'expr'
  let &l:foldexpr   = 'fold_rspec#foldexpr(v:lnum)'
  let &l:foldtext   = 'fold_rspec#foldtext()'
endif
