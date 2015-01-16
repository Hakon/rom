module ROM
  module Adapter
    class Linter
      Failure = Class.new(StandardError) do
        attr_reader :lint_name

        def initialize(lint_name)
          @lint_name = lint_name
        end
      end

      def self.lints
        public_instance_methods(true).grep(/^lint_/).map(&:to_s)
      end

      def self.each_lint
        return to_enum unless block_given?
        lints.each { |lint| yield lint, self }
      end

      def lint(name)
        public_send name
      end
    end
  end
end
