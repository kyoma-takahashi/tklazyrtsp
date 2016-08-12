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

latest_results = {}

File.open(file_path, 'w') do |file|

  while line = $stdin.gets
    CalculationResults.parse(line.chomp) do |k, v|
      file.rewind
      latest_results[k] = v
      file.puts JSON.generate(latest_results, JSON_STATE)
      file.flush
    end
  end

end
