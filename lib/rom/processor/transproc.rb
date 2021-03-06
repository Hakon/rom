require 'transproc/all'

require 'rom/processor'

module ROM
  class Processor
    class Transproc < Processor
      include ::Transproc::Composer

      attr_reader :header, :model, :mapping, :row_proc

      EMPTY_FN = -> tuple { tuple }.freeze

      def self.build(header)
        new(header).to_transproc
      end

      def initialize(header)
        @header = header
        @model = header.model
        @mapping = header.mapping
        initialize_row_proc
      end

      def to_transproc
        compose(EMPTY_FN) do |ops|
          ops << header.groups.map { |attr| visit_group(attr, true) }
          ops << t(:map_array!, row_proc) if row_proc
        end
      end

      private

      def visit(attribute)
        type = attribute.class.name.split('::').last.downcase
        send("visit_#{type}", attribute)
      end

      def visit_attribute(attribute)
        if attribute.typed?
          t(:map_key!, attribute.name, t(:"to_#{attribute.type}"))
        end
      end

      def visit_hash(attribute)
        with_row_proc(attribute) do |row_proc|
          t(:map_key!, attribute.name, row_proc)
        end
      end

      def visit_array(attribute)
        with_row_proc(attribute) do |row_proc|
          t(:map_key!, attribute.name, t(:map_array!, row_proc))
        end
      end

      def visit_wrap(attribute)
        name = attribute.name
        keys = attribute.tuple_keys

        compose do |ops|
          ops << t(:nest!, name, keys)
          ops << visit_hash(attribute)
        end
      end

      def visit_group(attribute, preprocess = false)
        if preprocess
          name = attribute.name
          header = attribute.header
          keys = attribute.tuple_keys

          other = header.groups

          compose do |ops|
            ops << t(:group, name, keys)

            ops << other.map { |attr|
              t(:map_array!, t(:map_key!, name, visit_group(attr, true)))
            }
          end
        else
          visit_array(attribute)
        end
      end

      def initialize_row_proc
        @row_proc = compose do |ops|
          ops << t(:map_hash!, mapping) if header.aliased?
          ops << header.map { |attr| visit(attr) }
          ops << t(-> tuple { model.new(tuple) }) if model
        end
      end

      def with_row_proc(attribute)
        row_proc = new(attribute.header).row_proc
        yield(row_proc) if row_proc
      end

      def new(*args)
        self.class.new(*args)
      end
    end
  end
end
