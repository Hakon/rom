require "concord"

module ROM
  class Adapter
    module Lint
      class Linter
        Failure = Class.new(StandardError) do
          # ship some extra information in the error
          attr_reader :lint_name

          def initialize(lint_name)
            @lint_name = lint_name
          end
        end

        attr_reader :adapter, :uri

        def initialize(adapter, uri)
          @adapter = adapter
          @uri = uri
        end

        def self.linter_methods
          public_instance_methods(true).grep(/^lint_/).map(&:to_s)
        end

        def lint
          self.class.linter_methods.each do |name|
            public_send name
            puts "#{name}: ok"
          end
        end

        def TODO_lint_failure
          fail Failure.new("test failure"),
               "#{adapter} is always failing here"
        end

        def lint_schemes
          return if adapter.respond_to? :schemes

          fail Failure.new("schemes"),
               "#{adapter}#schemes must be implemented"
        end

        def lint_schemes_is_an_array
          return if adapter.schemes.instance_of? Array

          fail Failure.new("schemes is an array"),
               "#{adapter}#schemes must return an array with supported URI schemes"
        end

        def lint_schemes_returns_any_supported_scheme
          return if adapter.schemes.any?

          fail Failure.new("schemes returns any supported scheme"),
               "#{adapter}#schemes must return at least one supported URI scheme"
        end

        def lint_adapter_setup
          return if adapter_instance.instance_of? adapter

          fail Failure.new("adapter setup"),
               "#{adapter}::setup must return an adapter instance"
        end

        def lint_dataset_reader
          return if adapter_instance.respond_to? :[]

          fail Failure.new("dataset reader"),
               "#{adapter_instance} must respond to []"
        end

        def lint_dataset_predicate
          return if adapter_instance.respond_to? :dataset?

          fail Failure.new("dataset predicate"),
               "#{adapter_instance} must respond to dataset?"
        end

        def adapter_instance
          Adapter.setup(uri)
        end
      end
    end
  end
end
