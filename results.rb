#!/usr/bin/ruby

require 'json'
require 'logger'

module CalculationResult

  CALC_IDS = ['method', 'params']

  LOG = Logger.new($stderr)
  LOG.level = Logger::DEBUG
  LOG.progname = $0

  def same_calc?(r)
    r.values_at(*CALC_IDS) == self.values_at(*CALC_IDS)
  end

  PATTERN = /^(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:,\d*)?(?:Z|[\+\-]\d{4}))\s+(\S.*)$/

  def self.parse(line)
    unless line =~ PATTERN
      LOG.warn("Unknown format #{line}")
      return nil
    end
    result = JSON.parse($2)
    LOG.warn("Parsed one has key \"finish\" already #{line}") if result.has_key?('finish')
    result['finish'] = $1
    result.extend self
    result
  end

end
