class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  EXCLUDED_ATTRIBUTES_DESCRIPTION = %w[id created_at updated_at].freeze

  def self.attributes_description
    attribute_types.except(*EXCLUDED_ATTRIBUTES_DESCRIPTION).map do |name, klass|
      result = { name:, type: klass.type }

      if klass.is_a?(ActiveRecord::Enum::EnumType)
        result[:type] = :enum
        result[:enum_values] = klass.send(:mapping)
      end

      result
    end
  end
end
