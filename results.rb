#!/usr/bin/ruby

require 'json'
require './log.rb'

module CalculationResult

  CALC_IDS = ['method', 'params']

  def same_calc?(r)
    r.values_at(*CALC_IDS) == self.values_at(*CALC_IDS)
  end

  PATTERN = /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:,\d*)?(?:Z|[\+\-]\d{4}))\s+(\S.*)$/

  def self.parse(line)
    unless line =~ PATTERN
      Log.log("Unknown format #{line}")
      return nil
    end
    result = JSON.parse($2)
    Log.log("Parsed one has key \"finish\" already #{line}") if result.has_key?('finish')
    result['finish'] = $1
    result.extend self
    result
  end

end
