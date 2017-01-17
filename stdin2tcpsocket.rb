#!/usr/bin/ruby

require 'logger'

log = Logger.new($stderr)
log.level = Logger::DEBUG
log.progname = $0

host, port = *ARGV

require 'socket'

server = TCPSocket.open(host, port)
server.binmode
log.info("Sendig to #{server.inspect}")

buffer = ' '

$stdin.binmode

while $stdin.read(1, buffer)
  server.write(buffer)
end

server.close

log.info("Exitting #{$0}")
