vim-rspec-folding
=================

This plugin provides automatic folding for RSpec files (`*_spec.rb`).

Conforms to RSpec DSL as of v3.6. Depends on strict, consistent, two-space indentation of context and example blocks, and supports Capybara keywords.

Installation
------------

There are lots of vim plugin managers out there. I like [vim-plug](https://github.com/junegunn/vim-plug).

Configuration
-------------

To set a default `foldlevel` for RSpec files, add a line like the one below to your `vimrc`:

```viml
let g:rspec_folding_default_level = 2
```

See `:h 'foldlevel'` for more.

License
-------

The MIT License (MIT)

Copyright © 2017 Ryan Lue
