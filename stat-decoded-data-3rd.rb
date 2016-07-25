#!/usr/bin/ruby

require 'time'

WITH_ERROR = true

LONG_INTERVAL = 1.0
LINE_LENGTH_WO_ERROR = WITH_ERROR ? 1308..1308 : 1261..1304
INTERVAL_CLASS_FACTOR = 200.0 # not int but float

def strftime(time)
  time.strftime('%Y-%m-%dT%T,%LZ')
end

@time = nil
@samples = 0
@shortest = nil
@longest = nil
@length_counts = {}
@interval_counts = {}

while(line = gets)
  @samples += 1

  # error

  error = false
  if WITH_ERROR and '::' != line.split(/\s+/)[1, 2].join('')
    error = true
    puts "[#{@samples}] errors #{line.split(/\s+/)[1, 2].join(' ')}"
  end

  # time

  begin
    time = Time.strptime(line.split(/\s+/).first, '%Y-%m-%dT%T,%LZ')
  rescue ArgumentError
    puts "[#{@samples}] time stamp in wrong format"
    puts line.chomp
  end

  if @time
    interval = time - @time
    if not WITH_ERROR or not error
      if interval > LONG_INTERVAL
        puts "[#{@samples}] interval #{interval} > #{LONG_INTERVAL} s: #{strftime(time)} after #{strftime(@time)}"
      end
      @shortest, dd, @longest = *[@shortest || interval, interval, @longest || interval].sort
      ic = (interval * INTERVAL_CLASS_FACTOR).floor
      @interval_counts[ic] ||= 0
      @interval_counts[ic] += 1
    end
  else
    puts "start: #{strftime(time)}"
  end

  @time = time

  # length

  length = line.chomp.length

  if not WITH_ERROR or not error
    unless LINE_LENGTH_WO_ERROR.include? length
      puts "[#{@samples}] line length #{length} not in #{LINE_LENGTH_WO_ERROR}"
      print line
    end

    @length_counts[length] ||= 0
    @length_counts[length] += 1
  end

end

puts "end: #{strftime(@time)}"

puts "samples incl. those w/ errors: #{@samples}"

puts 'interval wo/ errors:'
puts "  longest: #{@longest} s"
@interval_counts.keys.sort.reverse.each do |i|
  puts "  #{i/INTERVAL_CLASS_FACTOR}--#{(i+1)/INTERVAL_CLASS_FACTOR} s: #{@interval_counts[i]}"
end
puts "  shortest: #{@shortest} s"

puts 'line length wo/ errors:'
@length_counts.keys.sort.reverse.each do |l|
  puts "  #{l} chars: #{@length_counts[l]}"
end
