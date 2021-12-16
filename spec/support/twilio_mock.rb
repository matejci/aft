# frozen_string_literal: true

RSpec.shared_context 'twilio mock', shared_context: :metadata do
  let(:twilio_client) { double(:twilio_client) }
  let(:twilio_message) { double(:twilio_message, sid: SecureRandom.hex(5)) }

  before do
    allow(Twilio::REST::Client).to receive(:new).and_return(twilio_client)
    allow(twilio_client).to receive_message_chain('messages.create').and_return(twilio_message)
  end
end
