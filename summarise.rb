#!/usr/bin/ruby

require 'json'
require './results.rb'

# this is just an example
PACK = 'g2'

latest_results = {}

$stdout.binmode

while line = $stdin.gets
  CalculationResults.parse(line.chomp) do |k, v|
    latest_results[k] = v
    # this is just an example
    $stdout.write [latest_results['a calculation'][:results]['a field'] || Float::NAN,
                   latest_results['another calculation'][:results]['another field'] || Float::NAN ].
      pack(PACK)
  end
end
