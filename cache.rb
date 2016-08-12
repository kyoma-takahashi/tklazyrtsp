#!/usr/bin/ruby

file_path = ARGV.shift

# this is just an example
LENGTH = 4 * 2

File.open(file_path, 'wb') do |file|

  while bytes = $stdin.read(LENGTH)
    file.rewind
    file.write(bytes)
    file.flush
  end

end
