require_relative "linter"

module ROM
  class Adapter
    module Lint

      def self.lint(adapter, uri)
        linter = Linter.new(adapter, uri)
        linter.lint
      end

      # This is a simple lint-test for an adapter class to ensure the basic
      # interfaces are in place
      #
      # @example
      #
      #   class MyAdapterTest < Minitest::Test
      #     include ROM::Adapter::Lint::TestAdapter
      #
      #     def setup
      #       @adapter = MyAdapter
      #       @uri = "super_db://something"
      #     end
      #   end
      #
      # @public
      module TestAdapter
        attr_reader :adapter, :uri

        # Create test methods
        ROM::Adapter::Lint::Linter.linter_methods.each do |name|
          define_method "test_#{name}" do
            linter.public_send name
          end
        end

        private

        def linter
          ROM::Adapter::Lint::Linter.new(adapter, uri)
        end
      end

      # This is a simple lint-test for an adapter dataset class to ensure the
      # basic behavior is correct
      #
      # @example
      #
      #  class MyDatasetLintTest < Minitest::Test
      #    include ROM::Adapter::Lint::TestEnumerableDataset
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
