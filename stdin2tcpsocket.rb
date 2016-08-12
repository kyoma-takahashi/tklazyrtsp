#!/usr/bin/ruby

require './log.rb'

host, port = *ARGV

require 'socket'

server = TCPSocket.open(host, port)
server.binmode
Log.log "Sendig to #{server.inspect}"

buffer = ' '

$stdin.binmode

while $stdin.read(1, buffer)
  server.write(buffer)
end

server.close

Log.log "Exitting #{$0}"
