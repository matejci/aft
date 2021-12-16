class TakkoPermissionValidator < ActiveModel::Validator
  def validate(record)
    cannot_set_permission record
    should_match_parent   record
  end

  private

  def cannot_set_permission(record)
    (%w(viewer_ids takkoer_ids) & record.changes.keys).each do |field|
      record.errors.add(field, "can't alter #{field}") if record.send(field).present?
    end
  end

  def should_match_parent(record)
    (%w(view_permission takko_permission) & record.changes.keys).each do |field|
      if record.send(field) != record.parent.send(field)
        record.errors.add(field, "can't alter #{field}")
      end
    end
  end
end
