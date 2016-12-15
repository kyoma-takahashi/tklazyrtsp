#!/usr/bin/ruby

require './log.rb'

port, host = *ARGV

at_exit do
  Log.log "Exitting #{$0}"
end

# http://docs.ruby-lang.org/ja/2.0.0/class/TCPServer.html

require 'socket'

server = TCPServer.open(host, port)

addr = server.addr
addr.shift
Log.log sprintf("Server is on %s", addr.join(":"))

$stdout.binmode

loop do
  Thread.start(server.accept) do |s|
    Log.log sprintf("%s is accepted", s)
    s.binmode
    b = ' '
    while s.read(1, b)
      $stdout.write(b)
      $stdout.flush
    end
    Log.log sprintf("%s is gone", s)
    s.close
  end
end
