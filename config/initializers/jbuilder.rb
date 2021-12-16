class Jbuilder
  # https://github.com/rails/jbuilder/blob/bec0d6c840c3486ee589d5de0ba9c348ccbc27ee/lib/jbuilder.rb

  def _set_value(key, value)
    raise NullError.build(key) if @attributes.nil?
    raise ArrayError.build(key) if ::Array === @attributes
    return if @ignore_nil && value.nil? or _blank?(value)
    @attributes = {} if _blank?
    @attributes[_key(key)] = value.is_a?(::BSON::ObjectId) ? value.to_s : value
  end
end
