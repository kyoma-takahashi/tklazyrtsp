#!/usr/bin/ruby

require 'time'
require 'tempfile'
require 'csv'
require 'json'
require './log.rb'

IN_VALUES_AT = {:sng => [1, 11, 14, 15].collect {|i| i + 1}}

IN_DELIMITER = ' '
IN_STRPTIME = '%Y-%m-%dT%H:%M:%S,%N%z'

OUT_STRFTIME = IN_STRPTIME
OUT_DELIMITER = ' '
OUT_JSON_STATE = JSON::State.new({ :indent => '',
                                   :space => '',
                                   :space_before => '',
                                   :object_nl => '',
                                   :array_nl => '',
                                   :check_circular => false,
                                   :allow_nan => true,
                                   :max_nesting => false
                                 })


class Calculator

  TIME_SPRINTF = '%.3f'

  def init_data2cmd
    @datetime_begin = nil
    @datetime = nil
    @time_afer_beginning = nil
    @tmpfile2cmd = Tempfile.new([self.class.name, 'csv'])
    @csv2cmd = CSV.new(@tmpfile2cmd)
    Log.log('Made a tempfile to prepare data to an external command')
  end

  def initialize
    init_data2cmd()
  end

  def <<(record)
    @datetime_begin ||= record.first
    @datetime = record.first
    @time_afer_beginning = @datetime - @datetime_begin
    @csv2cmd << [sprintf(TIME_SPRINTF, @time_afer_beginning), *record[1, record.length - 1]]
    unless wait_cmd()
      return
    end
    start_cmd()
  end

  def start_cmd
    if @time_afer_beginning < @duration_s
      return
    end
    @datetime_begin_calc = @datetime_begin
    @csv2cmd.flush
    before_cmd()
    @tmpfile2cmd.close
    @calculator_pid = spawn(*@cmd_arg_opt)
    Log.log("Started #{@cmd_arg_opt}")
    @results_out = {
      'method' => @method,
      'sample' => {
        'begin' => @datetime_begin.strftime(OUT_STRFTIME),
        'end' => @datetime.strftime(OUT_STRFTIME)
      }
    }
    init_data2cmd() # for the next calc
  end

  def wait_cmd
    unless @calculator_pid
      # no cmd running
      return true
    end
    pid, status = *Process.waitpid2(@calculator_pid, Process::WNOHANG)
    unless pid
      # running
      return false
    end
    # finished
    abort unless pid == @calculator_pid
    abort unless status.pid == @calculator_pid
    @calculator_pid = nil
    if status.success? and cmd_success?()
      Log.log("Finished #{@cmd_arg_opt}")
      $stdout.print Time.now.strftime(OUT_STRFTIME)
      $stdout.print OUT_DELIMITER
      after_cmd()
      $stdout.print JSON.generate(@results_out, OUT_JSON_STATE)
      $stdout.puts
      $stdout.flush
    else
      Log.log("Failed in #{@cmd_arg_opt}")
    end
    return true
  end
end


class SngCalculator < Calculator

  DIRECTORY = '../sng.work'
  FILE_TO_CMD = File.join(DIRECTORY, 'rdata.csv')
  FILE_FROM_CMD = File.join(DIRECTORY, 'wdata.csv')
  FILE_FROM_CMD_TIME_INCREMENT = 1

  def initialize
    super
    @method = 'sng'
    @duration_s = 900
    @cmd_arg_opt = ['octave', 'CMC.m', {:chdir => DIRECTORY}]
  end

  def before_cmd
    File.rename(@tmpfile2cmd.path, FILE_TO_CMD)
    Log.log("Moved to #{FILE_TO_CMD} from a tempfile")
  end

  def cmd_success?
    FileTest.exists?(FILE_FROM_CMD)
  end

  def after_cmd
    @results_out['result'] = []
    t = 0
    CSV.foreach(FILE_FROM_CMD) do |row|
      @results_out['result'] << [(@datetime_begin_calc + t).strftime(OUT_STRFTIME), *row]
      t += FILE_FROM_CMD_TIME_INCREMENT
    end
    Log.log("Finished reading #{FILE_FROM_CMD}")
    File.delete(FILE_FROM_CMD)
    Log.log("Deleted #{FILE_FROM_CMD}")
  end
end


sng_calc = SngCalculator.new

while(line = $stdin.gets)
  record = line.split(IN_DELIMITER)
  record_time = Time.strptime(record.shift, IN_STRPTIME)
  sng_calc << [record_time, *record.values_at(*IN_VALUES_AT[:sng])]
end

Log.log('The standard input reached to EOF')

until sng_calc.wait_cmd()
  Thread.pass
end

# The followings are just for test.

sng_calc.start_cmd

until sng_calc.wait_cmd()
  Thread.pass
end


=begin

This reads data from the standard input.

This calls a external program giving a CSV file with a fixed name in a
specified directory.

The CSV file does not have the header row. The first column in the CSV
file contains time [s] in the float format. The subsequent columns have
the specified parameters. The time is 0 [s] in the first row. The time
interval is not constant. The CSV file contains data no shorter than a
specified time length.

The external program writes another CSV file with a fixed name in a
specified directory, and this reads it. The CSV file does not have any
columns of time but each row is for a time 0, 1, 2, ... [s].

This writes the calculation results to the standard output. The
contents are defined as the followings.

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
