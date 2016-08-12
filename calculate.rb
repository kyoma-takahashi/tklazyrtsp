#!/usr/bin/ruby

abort 'Not implemented yet'

=begin

Output format:

    TIMESTAMP CALCULATION RESULTS

      Delimited by one or more space characters and RESULTS. Note that
      RESULTS may contain space characters.

      The first field is when the calculation was finished according
      to the local clock.

      The second field is the identifier what is calculated.

  TIMESTAMP

    %FT%T,%N%z

  CALCULATION

    \S+

  RESULTS

    A JSON object.
    UTF-8 encoded.
    No CR or LF.

=end
