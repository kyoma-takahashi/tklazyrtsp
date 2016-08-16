#!/usr/bin/ruby

file_path = ARGV.shift

require 'json'
require './results.rb'

JSON_STATE = JSON::state.new({ :indent => ' ' * 2,
                               :space => ' ',
                               :space_before => '',
                               :object_nl => $/,
                               :array_nl => $/,
                               :check_circular => false,
                               :allow_nan => true,
                               :max_nesting => false
                             })

latest_results = []

File.open(file_path, 'w') do |file|

  longest = 0

  while line = $stdin.gets
    result = CalculationResult.parse(line.chomp)
    latest_results.delete_if {|r| r.same_calc?(result)}
    latest_results << result
    file.rewind
    file.puts JSON.generate(latest_results, JSON_STATE)
    pos = file.pos
    if pos > longest
      longest = pos
    else
      file.print(' ' * (longest - pos))
    end
    file.flush
  end

end
