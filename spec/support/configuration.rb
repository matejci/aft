# frozen_string_literal: true

RSpec.shared_context 'configuration', shared_context: :metadata do
  before do
    session = create(:session)
    app = session.app
    create(:configuration, app: app)
    app_token = jwt_encode(app.attributes.slice('app_id', 'public_key'), session)

    header 'USER-AGENT',       session.user_agent
    header 'APP-ID',           app.app_id
    header 'HTTP-X-APP-TOKEN', app_token
  end
end
