module Pixelfont
  VERSION = {{ `shards version`.chomp.stringify }}
end

require "./pixelfont/font"
