#!/usr/bin/ruby

IN = $stdin
OUT = $stdout

DELIMITER = ' '

PATTERN = 'seeeeeeeeeeeeeeebeebeebbbbbbbbbbbebbbseeeeeeeeeeeeeeeeeeeeeee'
PACK = 'v7' + 'v' + PATTERN.gsub('x','x4').gsub('e','g').gsub('b','b8b24').gsub('s','nb16')

DATETIME_REGEXP = /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2}),(\d{3})Z$/

DATA_LENGTH = 244

while(line = IN.gets)
  decoded = line.chomp.split(DELIMITER)
  vals2encode = []

  abort 'Unknown datetime format' unless DATETIME_REGEXP =~ decoded.shift
  vals2encode << $~[1, 7].collect {|v| v.to_i}

  vals2encode << DATA_LENGTH

  pattern = PATTERN.clone
  until pattern.empty?
    abort "Pattern broken #{pattern}" unless pattern =~ /^([^\d])(.*)$/
    type, pattern = $1, $2
    case type
    when 's'
      vals2encode << decoded.shift.to_i
      vals2encode << decoded.shift
    when 'e'
      vals2encode << decoded.shift.to_f
    when 'b'
      vals2encode << decoded.shift
      vals2encode << decoded.shift
    else
      abort "Unknown #{type}"
    end
  end
  abort 'Too many decoded values' unless decoded.empty?

  OUT.print vals2encode.flatten.pack(PACK)
end
