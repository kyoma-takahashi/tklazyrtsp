#!/usr/bin/ruby

module Log
  STRFTIME = '%FT%T,%N%z'

  def self.log(s)
    $stderr.printf("[%s %s] %s", Time.now.getutc.strftime(STRFTIME), $0, s)
  end
end
