#!/usr/bin/ruby

abort 'Not implemented yet'

=begin

Output format:

    TIMESTAMP RESULT

      Delimited by one or more space characters. Note that RESULT may
      contain space characters.

      The first field is when the calculation was finished according
      to the local clock.

  TIMESTAMP

    %FT%T,%N%z

  RESULT

    A JSON object.
    UTF-8 encoded.
    No CR or LF.

    The root JSON object must have the following keys.
      "method". Its value is a string indicating the calculation
        method.
      "result". Of the calculation.
    The root JSON object must not have the following key.
      "finish". It has to be given as TIMESTAMP outside the JSON
        object.
    The root JSON object may have the following keys.
      "params". Conditions of the calculation.
      "sample". Its value is a JSON object describing the data to be
        calculated.

    The "sample" JSON object may have the following keys.
      "begin". The date and time of the former end of the sample
        data, in %FT%T,%N%z
      "end". The date and time of the latter end of the sample
        data, in %FT%T,%N%z

=end
