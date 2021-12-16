# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  include Twitter::TwitterText::Extractor

  included do
    class_attribute :fields_with_tags

    has_and_belongs_to_many :hashtags
    has_many :mentions, as: :mentionable, dependent: :destroy

    after_save :extract_hashtags_mentions
  end

  class_methods do
    def taggable_fields(fields)
      raise 'Taggable fields value must be array!' unless fields.is_a?(Array)

      self.fields_with_tags = fields
    end
  end

  private

  def extract_hashtags_mentions
    return if (changes.keys & fields_with_tags).empty?

    # clear existing hashtags and mentions associations
    self.hashtags = []
    self.mentions = []

    # re-extract hashtags and metions from updated fields
    fields_with_tags.each do |field|
      str = send(field)
      extract_hashtags(str)
      extract_mentions(str)
    end
  end

  def extract_hashtags(str)
    Twitter::TwitterText::Extractor.extract_hashtags(str).each do |hashtag|
      tag = Hashtag.create_with(name: hashtag, created_by: user).find_or_create_by(link: hashtag.downcase.parameterize)

      hashtags << tag
    end
  end

  def extract_mentions(str)
    Twitter::TwitterText::Extractor.extract_mentioned_screen_names(str).each do |username|
      next unless (mentioned = User.valid.find_by(username: /^#{username}$/i))
      next if mentioned.id == user.id

      mention = mentions.create!(user: mentioned, mentioned_by: user, body: str)

      PushNotifications::ProcessorService.new(action: :mentioned, notifiable: mention.mentionable, actor: user, recipient: mentioned).call
    end
  end
end
