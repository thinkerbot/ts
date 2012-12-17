require 'minitest/unit'
require 'ts/null_printer'

module Ts
  class Unit < MiniTest::Unit
    def output
      @output = NullPrinter.new
    end

    def record suite, method, assertions, time, error
      case error
      when nil
        descr   = suite
        status  = 'P'
        message = ''
      when MiniTest::Skip
        descr   = location(error)
        status  = 'X'
        message = "Skip - %s\n" % error.message
      when MiniTest::Assertion
        descr   = location(error)
        status  = 'F'
        message = error.message
      else
        descr   = location(error)
        status  = 'F'
        message = "%s - %s\n%s" % [error.class, error.message, error.backtrace.join("\n")]
      end
  
      $stdout.printf "[%s] %s\n%s %d\n%s" % [descr, method, status, message.length, message]
      $stdout.flush
    end
  end
end
