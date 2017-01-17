#!/usr/bin/ruby

require 'logger'

log = Logger.new($stderr)
log.level = Logger::DEBUG
log.progname = $0

port, host = *ARGV

at_exit do
  log.info("Exitting #{$0}")
end

# http://docs.ruby-lang.org/ja/2.0.0/class/TCPServer.html

require 'socket'

server = TCPServer.open(host, port)

addr = server.addr
addr.shift
log.info(sprintf("Server is on %s", addr.join(":")))

$stdout.binmode

loop do
  Thread.start(server.accept) do |s|
    log.info(sprintf("%s is accepted", s))
    s.binmode
    b = ' '
    while s.read(1, b)
      $stdout.write(b)
      $stdout.flush
    end
    log.info(sprintf("%s is gone", s))
    s.close
  end
end
