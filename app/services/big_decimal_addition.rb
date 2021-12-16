# frozen_string_literal: true

class BigDecimalAddition
  def initialize(object)
    @object = object
    define_writers
  end

  delegate :save!, to: :object

  private

  attr_reader :object

  def define_writers
    object.attributes.each do |attr, value|
      next unless value.is_a?(Float)

      self.class.define_method("#{attr} +=") do |val|
        object.send("#{attr}=", calc(object.send(attr), val, :+))
      end

      self.class.define_method("#{attr} -=") do |val|
        object.send("#{attr}=", calc(object.send(attr), val, :-))
      end
    end
  end

  def calc(val_a, val_b, method)
    BigDecimal(val_a.to_s).send(method, BigDecimal(val_b.to_s))
  end
end
