#!/usr/bin/ruby

require 'json'
require './log.rb'

module CalculationResults

  PATTERN = /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:,\d*)?(?:Z|[\+\-]\d{4}))\s+(\S+)\s+(\S.*)$/

  @@results = {}

  def self.parse(line)
    unless line =~ PATTERN
      Log.log("Unknown format #{line}")
      return nil
    end
    @@results[:finish] = $1
    @@results[:results] = JSON.parse($3)

    yield($2, @@results)
  end

end
