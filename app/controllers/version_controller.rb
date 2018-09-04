class VersionController < ApplicationController
  def index
    render json: {
      env: Rails.env,
      revision: APP_REVISION,
      version: VERSION,
      ruby: RUBY_VERSION,
      rails: Rails::VERSION::STRING
    }
  end
end
