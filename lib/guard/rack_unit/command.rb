require 'open3'
require_relative './run_result'
module Guard
  class RackUnit
    class Command

      DEFAULT_CMD_STR = 'raco test'.freeze

      def initialize(last_run_result = Pending.new, command_string = DEFAULT_CMD_STR)
        @command_string = command_string
        @last_run_result = last_run_result
      end

      def execute(paths)
        paths = (@last_run_result.paths | paths).to_a
        cmd = sprintf('%s %s', DEFAULT_CMD_STR, paths.join(' '))
        with_environment do
          Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
            pid = wait_thr.pid
            RunResult.create(wait_thr.value, stdout, stderr)
          end
        end
      end

      def with_environment
        if defined?(::Bundler)
          ::Bundler.with_clean_env { yield }
        else
          yield
        end
      end
    end
  end
end
