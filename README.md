pleyada
=======

simPLE ruby wrapper for YAndex Disk Api


# Note

This wrapper curently in development. Be careful.

# Instalation

At this time only 'git clone'

# Usage

```ruby
require 'pleyada'

disk = Pleyada.new('mylogin', 'mypass')

disk.put('file_path_in_server', 'local_file_path')
# return true if all ok

disk.delete('file_path_in_server')
# return true if all ok
```

# Contributing

1. Fork
2. Branch
3. Commit
4. Push
5. Pull