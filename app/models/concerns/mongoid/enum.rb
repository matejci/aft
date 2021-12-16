module Mongoid
  module Enum
    extend ActiveSupport::Concern

    module ClassMethods
      def enum(name, values, options={})
        # ex: Feed.types == [:home, :discover]
        const_name = name.to_s.pluralize
        define_singleton_method(const_name) { values }

        # create field
        field name, type: Symbol, default: options[:default]

        # validate field values
        validates name, inclusion: {
          in: values.map(&:to_sym),
          message: :not_in, values: values.join(', ')
        }, if: -> { self[name].present? }

        # define scopes and accessors
        prefix = "#{options[:prefix]}_" if options[:prefix]

        values.each do |value|
          value_method_name = "#{prefix}#{value}"
          scope value_method_name, -> { where(name => value) }
          scope "not_#{value_method_name}", -> { where.not(name => value) }

          define_method("#{value_method_name}?") { self[name] == value }
          define_method("#{value_method_name}!") { self.update!("#{name}": value) }

          if options[:timestamps]
            define_method("was_#{value_method_name}?") { send("#{name}_was") == value }
            field "#{value_method_name}_at", type: DateTime
          end
        end
      end
    end
  end
end
