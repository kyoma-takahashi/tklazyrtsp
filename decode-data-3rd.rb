#!ruby

IN = $stdin
OUT = $stdout

DELIMITER = ' '

WINDOWS_WORD_LENGTH = 2  # bytes
# https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751%28v=vs.85%29.aspx
SYSTEMTIME_LENGTH = WINDOWS_WORD_LENGTH * 7
SYSTEMTIME_UNPACK = 'v7'
SYSTEMTIME_PRINTF = '%04d-%02d-%02dT%02d:%02d:%02d,%03dZ'

LENGTH_LENGTH = 2

# S0100851-TDO-002, Rev. 1
DATA_LENGTH = 244
UNPACK = 'seeeeeeeeeeeeeeebeebeebbbbbbbbbbbebbbseeeeeeeeeeeeeeeeeeeeeee'.
  gsub('x','x4').gsub('e','g').gsub('b','b8b24').gsub('s','nb16')
  # e <=> g; s <=> S, n, v; b <=> B
## S0100851-TDO-002, Rev. 0
# UNPACK = 'sx2e59x4' # s <=> S, n, v; e <=> g
PRINTF = UNPACK.
  gsub(/x\d*/, '').gsub(/[eg]/,"#{DELIMITER}%.8e").gsub(/[sSnv]/,"#{DELIMITER}%+6d").gsub(/[bB]\d*/, "#{DELIMITER}%s")

def read_contents
  return false unless length_b = IN.read(LENGTH_LENGTH)
  length = length_b.unpack('v').first
  IN.read(length)
end

def read_error
  return false unless err_b = read_contents
  OUT.print("#{DELIMITER}:")
  OUT.printf("%+6d;%10d:" * (err_b.bytesize / 6),
             *err_b.unpack('s<L<' * (err_b.bytesize / 6)))
  true
end

while (true)

  break unless system_time = IN.read(SYSTEMTIME_LENGTH)
  OUT.printf(SYSTEMTIME_PRINTF, *system_time.unpack(SYSTEMTIME_UNPACK))

  break unless read_error

  break unless data_b = read_contents
  if (DATA_LENGTH == data_b.bytesize)
    OUT.printf(PRINTF, *data_b.unpack(UNPACK))
  else
    OUT.print DELIMITER
    OUT.print data_b.bytesize.to_s
    OUT.print DELIMITER
    # hex dump
    OUT.print data_b.unpack('H*')
  end

  break unless read_error

  OUT.puts
  OUT.flush
end

# bit/bool, 1 bit:
#   b, bit string (LSB first)
#   B, bit string (MSB first)
# byte, 8 bits:
#   c, 8-bit signed (signed char)
#   C, 8-bit unsigned (unsigned char)
# integer, 2 bytes:
#   s, 16-bit signed, native endian (int16_t)
#     little endian on pbdpmh26
#   S, 16-bit unsigned, native endian (uint16_t)
#   n, 16-bit unsigned, network (big-endian) byte order
#   v, 16-bit unsigned, VAX (little-endian) byte order
# dint, 4 bytes:
#   i, signed int, native endian
#     32 bit, little endian on pbdpmh26
# real, 4 bytes:
#   d, double-precision, native format
#     64 bit, little endian on pbdpmh26
#   f, single-precision, native format
#     32 bit, little endian on pbdpmh26
#   E, double-precision, little-endian byte order
#     64 bit on pbdpmh26
#   e, single-precision, little-endian byte order
#     32 bit on pbdpmh26
#   G, double-precision, network (big-endian) byte order
#     64 bit on pbdpmh26
#   g, single-precision, network (big-endian) byte order
#     32 bit on pbdpmh26
# null
#   x, skip forward one byte
