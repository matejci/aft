# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Comment, type: :model do
  context 'taggable' do
    let(:comment) do
      create(:comment, text: '@apple is #red and @banana is yellow. @pineapple is not #orange')
    end

    before do
      %w[apple banana].each do |fruit|
        user = create(:user, username: fruit)
        create(:user_configuration, user: user)
      end
    end

    it 'extracts hashtags and mentions' do
      expect(comment.hashtags.pluck(:name)).to eq %w[red orange]
      expect(comment.mentions.map { |m| m.user.username }).to eq %w[apple banana]
      expect(Hashtag.count).to eq 2
      expect(Mention.count).to eq 2
    end

    it 're-extracts hashtags and mentions' do
      comment.update(text: '#orange is @orange')

      expect(comment.hashtags.pluck(:name)).to eq %w[orange]
      expect(comment.mentions).to be_empty
      expect(Hashtag.count).to eq 2 # does not create duplicate hashtag
      expect(Mention.count).to eq 0 # destroys previous mentions
    end
  end
end
