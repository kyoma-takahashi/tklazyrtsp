#!ruby

IN = $stdin
OUT = $stdout

LENGTH_LENGTH = 2

# S0100851-TDO-002, Rev. 1
DATA_LENGTH = 244
UNPACK = 'seeeeeeeeeeeeeeebeebeebbbbbbbbbbbebbbsexxxxxxxxxxxxxxxxxxxxxx'.
  gsub('x','x4').gsub('e','e').gsub('s','sx2').gsub('b','b8x3')
  # e <=> g; s <=> S, n, v; b <=> B
SLICE = 0..38
## S0100851-TDO-002, Rev. 0
# UNPACK = 'sx2e59x4' # s <=> S, n, v; e <=> g
# SLICE = 0..59

while (length_b = IN.read(LENGTH_LENGTH))

  # hex dump
  # OUT.puts length_b.unpack('H*')
  length = length_b.unpack('v').first

  data_b = IN.read(length)

  OUT.print Time.now.strftime('%FT%T.%N%z') + ' '

  if (DATA_LENGTH == length)
    OUT.puts data_b.unpack(UNPACK)[SLICE].collect {|val|
      case val
      when Float
        sprintf('%.8e', val)
      when Integer
        sprintf('%+6d', val)
      when String
        val
        # val[0]
        # val[-1]
      else
        raise "Unknown type #{val.inspect}"
      end
    }.join(' ')
  else
    OUT.print length.to_s + ' '
    # hex dump
    OUT.puts data_b.unpack('H*')
  end

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
