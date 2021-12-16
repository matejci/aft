class TakkoValidator < ActiveModel::Validator
  def validate(record)
    parent = record.parent
    user   = record.user

    if parent.nil?
      record.errors.add(:parent_id, 'no parent found')
    elsif !parent.can_takko?(user) || user.blocked_or_blocked_by?(parent.user)
      record.errors.add(:parent_id, 'not allowed')
    end
  end
end
