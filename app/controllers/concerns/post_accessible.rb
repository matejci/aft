module PostAccessible
  extend ActiveSupport::Concern

  private

  def post_access
    unless @post.available?(@current_user)
      render json: { base: 'Post is not available' }, status: :forbidden
    end
  end
end
