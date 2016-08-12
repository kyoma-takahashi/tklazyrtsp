#!/usr/bin/ruby

require 'webrick'
require 'base64'

port, length = *ARGV
if length
  length = length.to_i
end

content = ''

server = WEBrick::HTTPServer.new({:BindAddress => 'localhost',
                                  :Port => port})

server.mount_proc('/', Proc.new do |request, response|
                    response.body = content
                  end)

httpd_thread = Thread.new do
  server.start
end

if length

  $stdin.binmode
  while bytes = $stdin.read(length)
    content = Base64.encode64(bytes)
  end

else

  while line = $stdin.gets
    content = line.chomp
  end

end

server.shutdown
