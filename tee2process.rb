#!/usr/bin/ruby

unless process = ARGV.shift
  abort "Usage #{$0} process"
end

process_io = IO.popen(process, 'wb') do |pout|

  $stdout.binmode
  $stdin.binmode

  until $stdin.eof?
    s = $stdin.read(1)
    $stdout.write(s)
    pout.write(s)
  end

end

=begin

This is for the environment where the process substitution is not
available. If yes by bash, do

  tee >(process)

=end
