if expand('%:t:r') =~ '_spec$'
  let &l:foldmethod = 'expr'
  let &l:foldexpr   = 'fold_rspec#foldexpr(v:lnum)'

  if !exists('g:fold_rspec_enhanced_foldtext') || (exists('g:fold_rspec_enhanced_foldtext') && g:fold_rspec_enhanced_foldtext != 0)
    let &l:foldtext   = 'fold_rspec#foldtext()'
  endif
  if exists('g:fold_rspec_foldclose')
    let &l:foldclose = g:fold_rspec_foldclose
  endif
  if exists('g:fold_rspec_default_foldcolumn')
    let &l:foldcolumn  = g:fold_rspec_default_foldcolumn
  endif
  if exists('g:fold_rspec_foldenable')
    let &l:foldenable = g:fold_rspec_foldenable
  endif
  if exists('g:fold_rspec_foldlevel')
    let &l:foldlevel  = g:fold_rspec_foldlevel
  endif
  if exists('g:fold_rspec_foldminlines')
    let &l:foldminlines = g:fold_rspec_foldminlines
  endif
endif
