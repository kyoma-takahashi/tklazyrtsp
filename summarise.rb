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
  $stdout.write [latest_results.select {|r|
                   r['method'] == 'a method' && r['params'] == nil
                 }.first['result']['a field'] || Flart::NAN,
                 latest_results.select {|r|
                   r['method'] == 'a method' && r['params'] == nil
                 }.first['result']['a field'] || Flart::NAN].
    pack(PACK)
end
