class Downvote < Vote
  belongs_to :post
  field :type, default: 'down'
end
