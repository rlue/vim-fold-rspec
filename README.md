vim-fold-rspec
==============

This plugin provides automatic folding for RSpec files (`*_spec.rb`).

Conforms to RSpec DSL as of v3.6. Depends on strict, consistent, two-space indentation of context and example blocks, and supports Capybara keywords.

### Before

```ruby
require File.expand_path("spec_helper", File.dirname(File.dirname(__FILE__)))     
                                                                                  
describe 'response.cache_control' do                                              
  it 'sets the Cache-Control header' do                                           
    app(:caching) do |r|                                                          
      response.cache_control :public=>true, :no_cache=>true, :max_age => 60       
    end                                                                           
    header('Cache-Control').split(', ').sort.must_equal ['max-age=60', 'no-cache'>
  end                                                                             
                                                                                  
  it 'does not add a Cache-Control header if it would be empty' do                
    app(:caching) do |r|                                                          
      response.cache_control({})                                                  
    end                                                                           
    header('Cache-Control').must_be_nil                                           
  end                                                                             
end                                                                               
                                                                                  
describe 'response.expires' do                                                    
  it 'sets the Cache-Control and Expires header' do                               
    app(:caching) do |r|                                                          
# ...
```

### After

```ruby
require File.expand_path("spec_helper", File.dirname(File.dirname(__FILE__)))
                                                                                
describe 'response.cache_control' do
- it 'sets the Cache-Control header' ------------------------------------- [4] -
- it 'does not add a Cache-Control header if it would be empty' ---------- [4] -
end
                                                                                
describe 'response.expires' do
- it 'sets the Cache-Control and Expires header' ------------------------- [5] -
- it 'can be called with only one argument' ------------------------------ [5] -
end
                                                                                
describe 'response.finish' do
- it 'removes Content-Type and Content-Length for 304 responses' --------- [6] -
- it 'does not change non-304 responses' --------------------------------- [6] -
end
                                                                                
describe 'request.last_modified' do
- it 'ignores nil' ------------------------------------------------------- [4] -
- it 'does not change a status other than 200' --------------------------- [7] -
end
# ...
```

(Sample spec lifted from [roda](https://github.com/jeremyevans/roda).)

Installation
------------

There are lots of vim plugin managers out there. I like [vim-plug](https://github.com/junegunn/vim-plug).

Configuration
-------------

To set a default `foldlevel` for RSpec files, add a line like the one below to your `vimrc`:

```viml
let g:fold_rspec_default_level = 2
```

See `:h 'foldlevel'` for more.

To disable folding by default for Rspec files, add a line like the one below to your `vimrc`:

```viml
let g:fold_rspec_default_enable = 0
```

See `:h 'foldenable'` for more.

License
-------

The MIT License (MIT)

Copyright © 2017 Ryan Lue
