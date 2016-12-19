#!/usr/bin/ruby

require './log.rb'

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
    begin
      p.write(s)
    rescue Errno::EPIPE
      Log.log("Broken pipe #{p}")
      process_ios.delete(p)
    end
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
