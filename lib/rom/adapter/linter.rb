module ROM
  module Adapter
    class Linter
      Failure = Class.new(StandardError) do
        attr_reader :lint_name

        def initialize(lint_name)
          @lint_name = lint_name
        end
      end

      def self.linter_methods
        public_instance_methods(true).grep(/^lint_/).map(&:to_s)
      end

      def lint
        self.class.linter_methods.each do |name|
          lint name
          puts "#{name}: ok"
        end
      end
    end
  end
end
