# frozen_string_literal: true

RSpec.shared_examples "a webhook" do
  # required_let_definitions :notify_webhook, :url

  let(:stub_request) { WebMock.stub_request(:any, url) }

  context "when the API responds with a 400 error" do
    before do
      stub_request.to_return(body: "invalid_request", status: 400)
    end

    it "raises a ClientError" do
      expect { notify_webhook }.to raise_error(Flipper::Notifications::Webhooks::ClientError)
    end
  end

  context "when the API responds with a 500 error" do
    before do
      stub_request.to_return(body: "server_error", status: 500)
    end

    it "raises a ServerError" do
      expect { notify_webhook }.to raise_error(Flipper::Notifications::Webhooks::ServerError)
    end
  end

  context "when a network error occurs" do
    before do
      stub_request.to_timeout
    end

    it "raises a NetworkError" do
      expect { notify_webhook }.to raise_error(Flipper::Notifications::Webhooks::NetworkError)
    end
  end
end
