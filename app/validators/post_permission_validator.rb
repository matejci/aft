# frozen_string_literal: true

class PostPermissionValidator < ActiveModel::Validator
  def validate(record)
    archived = record.archived?

    cannot_change_permission(record, :takko) if archived

    cannot_change_permission(record, :view) if archived || record.takkos.not(user: record.user).exists?

    check_custom_fields(record, :takko)
    check_custom_fields(record, :view)
  end

  private

  def cannot_change_permission(record, action)
    (["#{action}_permission", "#{action}er_ids"] & record.changes.keys).each do |field|
      record.errors.add(field, "can't alter #{field}")
    end

    permission_group = "#{action}er_group_ids"
    record.errors.add(permission_group, "can't alter #{permission_group}") if record.send(permission_group)
  end

  def check_custom_fields(record, action)
    permission = "#{action}_permission"
    ids_field  = "#{action}er_ids"
    group_field = "#{action}er_group_ids"

    if record.send(permission) == :custom
      record.errors.add(ids_field, 'select some users') if record.send(ids_field).nil? && record.send(group_field).nil?
    else
      record.errors.add(ids_field, 'not allowed to be set') unless record.send(ids_field).nil?
      record.errors.add(group_field, 'not allowed to be set') unless record.send(group_field).nil?
    end
  end
end
