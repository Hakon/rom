require 'rom/adapter/linter'

module ROM
  module Adapter
    module Lint
      class EnumerableDataset < ROM::Adapter::Linter
        attr_reader :dataset, :data

        def initialize(dataset, data)
          @dataset = dataset
          @data = data
        end

        def lint_each
          result = []
          dataset.each { |tuple| result << tuple }
          return if result == data

          fail Failure.new("each"),
               "#{dataset.class}#each must yield tuples"
        end

        def lint_to_a
          return if dataset.to_a == data

          fail Failure.new("to_a"),
               "#{dataset.class}#to_a must cast dataset to an array"
        end
      end
    end
  end
end
