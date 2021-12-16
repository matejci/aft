# frozen_string_literal: true

RSpec.shared_context 'authenticated request', shared_context: :metadata do |user_session: false, curated_posts: false, posts: false|
  let(:user) { User.first || create(:user) } if user_session
  let(:curated_posts) { curated_posts }
  let(:posts) { posts }

  before do
    session = create(:session)
    app = session.app
    app_token = jwt_encode(app.attributes.slice('app_id', 'public_key'), session)

    header 'USER-AGENT',       session.user_agent
    header 'APP-ID',           app.app_id
    header 'HTTP-X-APP-TOKEN', app_token

    prepare_user_session(user) if user_session
    create_curated_posts(app) if curated_posts
  end
end

def prepare_user_session(user)
  session = Session.last
  session.update(user: user)
  access_token = jwt_encode({ access_token: session.access_token }, session)
  header 'HTTP-ACCESS-TOKEN', access_token

  create_posts(user) if posts
end

def jwt_encode(payload, session)
  JWT.encode(payload, session.app.secret + session.user_agent, 'HS512')
end

def create_curated_posts(app)
  curated_posts = create_list(:post, 5, title: 'CURATED_POST')
  conf = app.create_configuration
  conf.curated_posts << curated_posts.pluck(:id)
  conf.curated_posts.flatten!
  conf.save
end

def create_posts(user)
  user2 = create(:user)
  create(:post, :public, user: user2)
  user.follow!(user2)
  Post.reindex
end
