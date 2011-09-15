require 'rspec/core/formatters/base_text_formatter'

module RSpec
  module Core
    module Formatters
      class SweetVimRspecFormatter < BaseTextFormatter
        def example_failed(example)
          data = ""
          data << "+-+ "
          data << "[FAIL] #{example.description}\n"

          exception = example.execution_result[:exception]
          regex = %r{^(.*\bspec/.*_spec\.rb:\d+)(.*)$}
          data << exception.backtrace.find do |frame|
            frame =~ regex
          end.gsub(regex, "\\1") + ": in `#{example.description}'\n" rescue nil

          data << exception.message
          data << "\n+-+ Backtrace\n"
          data << exception.backtrace.join("\n")
          data << "\n-+-\n" * 2
          output.puts data
        end

        def example_pending(example)
          data = ""
          data << "+-+ "
          data << "[PEND] #{example.description}\n"

          pending = example.execution_result[:pending_message]
          data << example.location + ": in `#{example.description}'"
          data << "\n\n-+-\n"
          output.puts data
        end

        def example_passed(example)
          if ENV['SWEET_VIM_RSPEC_SHOW_PASSING'] == 'true'
            output.puts "[PASS] #{example.full_description}\n"
          end
        end

        def dump_failures *args; end

        def dump_pending *args; end

        def message msg; end

        def dump_summary(*);end

        def close
          super
          summary = summary_line example_count, failure_count, pending_count
        end

        private

        def format_message(*); end

      end
    end 
  end 
end 

