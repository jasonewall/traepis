class ApplicationRecord
  include ActiveModel::Model
  include ActiveModel::Conversion
  include ActiveModel::Dirty

  def self.model_attr(*attrs)
    define_attribute_methods *attrs
    attrs.each do |attribute|
      attribute = attribute.to_s
      fields << attribute
      define_method(attribute) do
        attributes[attribute]
      end

      define_method("#{attribute}=") do |val|
        send("#{attribute}_will_change!") unless val == attributes[attribute]
        attributes[attribute] = val
      end
    end
  end

  def self.fields
    @fields ||= []
  end

  def attributes
    @attributes ||= {}
  end

  def commit
    changes_applied
  end
end
