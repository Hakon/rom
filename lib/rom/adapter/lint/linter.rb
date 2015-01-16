module ROM
  module Adapter
    module Lint
      class Linter
        Failure = Class.new(StandardError) do
          # ship some extra information in the error
          attr_reader :lint_name

          def initialize(lint_name)
            @lint_name = lint_name
          end
        end

        attr_reader :repository, :uri

        def initialize(repository, uri)
          @repository = repository
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
               "#{repository} is always failing here"
        end

        def lint_schemes
          return if repository.respond_to? :schemes

          fail Failure.new("schemes"),
               "#{repository}#schemes must be implemented"
        end

        def lint_schemes_is_an_array
          return if repository.schemes.instance_of? Array

          fail Failure.new("schemes is an array"),
               "#{repository}#schemes must return an array with supported URI schemes"
        end

        def lint_schemes_returns_any_supported_scheme
          return if repository.schemes.any?

          fail Failure.new("schemes returns any supported scheme"),
               "#{repository}#schemes must return at least one supported URI scheme"
        end

        def lint_repository_setup
          return if repository_instance.instance_of? repository

          fail Failure.new("repository setup"),
               "#{repository}::setup must return an repository instance"
        end

        def lint_dataset_reader
          return if repository_instance.respond_to? :[]

          fail Failure.new("dataset reader"),
               "#{repository_instance} must respond to []"
        end

        def lint_dataset_predicate
          return if repository_instance.respond_to? :dataset?

          fail Failure.new("dataset predicate"),
               "#{repository_instance} must respond to dataset?"
        end

        def repository_instance
          Repository.setup(uri)
        end
      end
    end
  end
end
