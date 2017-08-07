if expand('%:t:r') =~ '_spec$'
  if exists('g:fold_rspec_default_enable')
    let &l:foldenable = g:fold_rspec_default_enable
  else
    let &l:foldenable = 1
  endif
  if exists('g:fold_rspec_default_level')
    let &l:foldlevel  = g:fold_rspec_default_level
  endif
  let &l:foldmethod = 'expr'
  let &l:foldexpr   = 'fold_rspec#foldexpr(v:lnum)'
  let &l:foldtext   = 'fold_rspec#foldtext()'
endif
