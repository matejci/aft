class UniqueValidator < ActiveModel::EachValidator
  def initialize(options)
    unless options[:across].present?
      raise ArgumentError, 'missing argument. `across:` maybe use uniqueness validator instead?'
    end

    options[:across].each do |attr_name, field|
      next if [Class, Proc].include? field[:model].class
      raise ArgumentError, "#{field[:model]} was passed as a model but is not valid. " \
        "Pass a class or a callable scope instead: `model: User or -> { User.valid }`"
    end

    super
  end

  def validate_each(record, attribute, value)
    return unless value.present?

    unique   = true
    relation = options[:conditions]&.call || record.class
    relation = relation.not(id: record.id)

    unique = false if relation.where(attribute => /^#{value}$/i).exists?

    if unique
      options[:across].each do |attr_name, field|
        relation = field[:model].is_a?(Proc) ? field[:model].call : field[:model]

        if field[:except].present?
          id, record_id = field[:except].first
          relation = relation.not(id => record.send(record_id))
        end

        if relation.where(attr_name => /^#{value}$/i).exists?
          unique = false
          break
        end
      end
    end
    
    record.errors.add(attribute, :not_unique, message: options[:message]) unless unique
  end
end
