# frozen_string_literal: true

module Posts
  class DeletePostService
    def initialize(post:, with_takkos:)
      @post = post
      @with_takkos = with_takkos
    end

    def call
      delete_post
    end

    private

    attr_reader :post, :with_takkos

    def delete_post
      user = post.user
      archive_post(post)

      if !post.takko? && with_takkos.to_s == 'true'
        post.takkos.active.where(user: user).each do |takko|
          archive_post(takko)
        end
      elsif post.takko? && with_takkos.to_s == 'true'
        post.parent.takkos.active.where(user: user).each do |takko|
          archive_post(takko)
        end
      end

      { errors: post.errors }
    end

    def archive_post(post)
      post.archiving = true
      post.archived = true
      post.archived_at = Time.current
      post.save(validate: false) # will run callbacks
    end
  end
end
