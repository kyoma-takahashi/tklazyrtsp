#!/usr/bin/ruby

processes = ARGV
if processes.empty?
  abort "Usage #{$0} process [...]"
end

process_ios = processes.collect do |p|
  IO.popen(p, 'wb')
end

$stdout.binmode
$stdin.binmode

until $stdin.eof?
  s = $stdin.read(1)
  $stdout.write(s)
  process_ios.each do |p|
    p.write(s)
  end
end

process_ios.each do |p|
  p.close
end


=begin

This is for the environment where the process substitution is not
available. If yes by bash, do

  tee >(process)

=end
