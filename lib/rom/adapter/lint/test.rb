require 'rom/adapter/lint/repository'
require 'rom/adapter/lint/enumerable_dataset'

module ROM
  module Adapter
    module Lint
      # This is a simple lint-test for adapter's repository class to ensure the
      # basic interfaces are in place
      #
      # @example
      #
      #   class MyAdapterTest < Minitest::Test
      #     include ROM::Adapter::Lint::TestRepository
      #
      #     def setup
      #       @repository = MyRepository
      #       @uri = "super_db://something"
      #     end
      #   end
      #
      # @public
      module TestRepository
        attr_reader :repository, :uri

        # Create test methods
        ROM::Adapter::Lint::Repository.each_lint do |name, linter|
          define_method "test_#{name}" do
            begin
              linter.new(repository, uri).lint(name)
            rescue ROM::Adapter::Linter::Failure => f
              raise Minitest::Assertion, f.message
            end
          end
        end
      end

      # This is a simple lint-test for an repository dataset class to ensure the
      # basic behavior is correct
      #
      # @example
      #
      #  class MyDatasetLintTest < Minitest::Test
      #    include ROM::Repository::Lint::TestEnumerableDataset
      #
      #     def setup
      #       @data  = [{ name: 'Jane', age: 24 }, { name: 'Joe', age: 25 }]
      #       @dataset = MyDataset.new(@data, [:name, :age])
      #     end
      #   end
      # @public
      module TestEnumerableDataset
        attr_reader :dataset, :data

        ROM::Adapter::Lint::EnumerableDataset.each_lint do |name, linter|
          define_method "test_#{name}" do
            begin
              linter.new(dataset, data).lint(name)
            rescue ROM::Adapter::Linter::Failure => f
              raise Minitest::Assertion, f.message
            end
          end
        end
      end
    end
  end
end
