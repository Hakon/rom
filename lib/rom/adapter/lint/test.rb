require_relative "linter"

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
        ROM::Adapter::Lint::Linter.linter_methods.each do |name|
          define_method "test_#{name}" do
            linter.public_send name
          end
        end

        def linter
          ROM::Adapter::Lint::Linter.new(repository, uri)
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

        def test_each
          result = []
          dataset.each { |tuple| result << tuple }
          assert_equal result, data,
            "#{dataset.class}#each must yield tuples"
        end

        def test_to_a
          assert_equal dataset.to_a, data,
            "#{dataset.class}#to_a must cast dataset to an array"
        end
      end
    end
  end
end
