# coding: utf-8
require 'trace_code/version'

module TraceCode
  @output = nil
  @result = nil
  @trace = nil
  @color = nil

  module_function

  def start(*classes, color: true, output: $stdout, &block)
    return if tracing?

    begin
      setup_trace(classes, color, output)
      start_trace
      block.call if block
    ensure
      finish if block
    end
  end

  def finish
    finish_trace
    print_trace
  end

  private
  module_function

  def tracing?
    @trace && @trace.enable?
  end

  def file_regexp(classes)
    files = classes.map do |cls|
      cls.instance_methods(false).map do |sym|
        location = cls.instance_method(sym).source_location
        location ? location[0] : nil
      end
    end

    patt = files.flatten.compact
      .uniq.map {|file| Regexp.quote(file) }.join('|')
    %r{\A(?:#{patt})\z}
  end

  def setup_trace(classes, color, output)
    file_regexp = file_regexp(classes)

    @color = color
    @output = output
    @result = {}
    @trace = TracePoint.new(:line) do |tp|
      path = tp.path
      next unless file_regexp =~ path

      @result[path] ||= Hash.new(0)
      @result[path][tp.lineno] += 1
    end
  end

  def start_trace
    @trace.enable
  end

  def finish_trace
    @trace.disable if @trace
    @trace = nil
  end

  def print_trace
    @result.each do |file, count|
      next if count.empty?
      @output.puts "#{file}:"
      Printer.print(@output, file, count, @color)
    end
  end

  require 'ripper'
  class Printer < Ripper::Filter
    def self.print(output, path, call_count, color)
      open(path, 'r') do |input|
        new(input, output).print(call_count, color)
      end
    end

    def initialize(input, output)
      super(input)
      @output = output
      @lineno = []
    end

    def print(call_count, color)
      @call_count = call_count
      @color =
        case color
        when :dark, :light
          color
        when true
          :dark
        else
          :none
        end

      data = parse([''])
      unless /\n\z/ =~ data.last
        print_lines(data)
      end
    end

    def print_lines(data)
      evaluated = @lineno.any? {|no| @call_count.include?(no) }

      postfix = ESC[@color][:reset]
      @lineno.each_with_index do |no, i|
        line = data[i]

        prefix =
          if @call_count.include?(no)
            ESC[@color][:exec]
          elsif /\A\s*\z/ =~ line
            ESC[@color][:blank]
          elsif evaluated
            ESC[@color][:fold]
          else
            ESC[@color][:skip]
          end

        @output.write format('%s %4d: %s%s', prefix, no, line, postfix)
      end
    end

    ESC = {
      dark: {
        exec: "\e[38;5;%dm"%0xff,
        fold: "\e[38;5;%dm"%0xf8,
        skip: "\e[38;5;%dm"%0xf0,
        blank: "\e[38;5;%dm"%0xf0,
        reset: "\e[0m",
      },
      light: {
        exec: "\e[38;5;%dm"%0xe8,
        fold: "\e[38;5;%dm"%0xf0,
        skip: "\e[38;5;%dm"%0xf8,
        blank: "\e[38;5;%dm"%0xf8,
        reset: "\e[0m",
      },
      none: {
        exec: 'o',
        fold: '-',
        skip: ' ',
        blank: ' ',
        reset: '',
      }
    }

    def on_nl(token, data)
      add_nl(token, data)

      print_lines(data)
      @lineno = []
      ['']
    end

    def on_ignored_nl(token, data)
      add_nl(token, data)
    end

    def on_comment(token, data)
      add_token(token, data, /\n\z/ =~ token)
    end

    def on_default(event, token, data)
      add_token(token, data, false)
    end

    def add_nl(token, data)
      add_token(token, data, true)
    end

    def add_token(token, data, newline)
      data.tap do |d|
        d.last << token
        if newline
          d << ''
          @lineno << lineno
        end
      end
    end
  end
end
