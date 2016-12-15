#!/usr/bin/ruby

require 'json'
require './results.rb'

# this is just an example
PACK = 'g2'

latest_results = []

$stdout.binmode

while line = $stdin.gets
  result = CalculationResult.parse(line.chomp)
  latest_results.delete_if {|r| r.same_calc?(result)}
  latest_results << result
  # this is just an example
  $stdout.write (latest_results.select {|r|
                   'sng' == r['method'] && nil == r['params']
                 }.first['result'][0][1, 2] + Array.new(2)).
    collect {|v|
      v ? v.to_f : Float::NAN
    }.
    flatten.pack(PACK)
  $stdout.flush
end
