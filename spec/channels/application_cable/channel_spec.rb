# spec/channels/application_cable/channel_spec.rb
require 'rails_helper'

RSpec.describe ApplicationCable::Channel, type: :channel do
  it 'successfully subscribes to the channel' do
    # Simulate a subscription to the channel
    subscribe

    # Verify if the subscription is successful
    expect(subscription).to be_confirmed
  end
end
