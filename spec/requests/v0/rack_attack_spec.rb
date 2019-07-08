require 'rails_helper'

describe 'throttle' do
  before(:each) do
    # Prevent throttle
    Rails.cache.clear
  end

  let(:limit) { 100 } # Should be the same as limit: in init/rack_attack

  context "number of requests is lower than the limit" do
    it "does not change the request status" do
      limit.times do
        get "/", params: {}, headers:{"REMOTE_ADDR" => "1.2.3.4"}
        expect(response.status).to_not eq(429)
      end
    end
  end

  context "number of requests is higher than the limit" do
    it "changes the request status to 429" do
      (limit + 5).times do |i|
        get "/", params: {}, headers:{ "REMOTE_ADDR" => "1.2.3.5"}

        #p "#{i} - #{limit}"
        if i >= limit
          #over the limit, being throttled
          expect(response.status).to eq(429)
        else
          expect(response.status).to eq(200)
        end
      end
    end
  end
end
