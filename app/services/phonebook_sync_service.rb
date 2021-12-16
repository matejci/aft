# frozen_string_literal: true

class PhonebookSyncService
  def initialize(contacts:, viewer:)
    @contacts = contacts
    @viewer = viewer
  end

  def call
    sync_contacts
  end

  private

  attr_reader :contacts, :viewer

  # rubocop: disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def sync_contacts
    raise ActionController::BadRequest, 'Contacts param is missing' if contacts.blank?

    users = User.active.to_a

    contacts.each_with_object([]) do |contact, results|
      user = users.find do |u|
        contact[:emails]&.include?(u.email) || includes_phone_number?(contact[:phones], u.phone)
      end

      following = if user
        viewer.followees_ids.include?(user.id.to_s)
      else
        false
      end

      results << { uuid: contact[:uuid], username: user.present? ? user.username : nil, already_following: following }
    end
  end
  # rubocop: enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

  def includes_phone_number?(contact_phones, user_phone)
    return false if contact_phones.blank? || user_phone.blank?

    contact_phones.include?(user_phone) || contact_phones.include?(user_phone.split('-').last)
  end
end
