class VersionController < ApplicationController
  def index
    render json: {
      revision: APP_REVISION,
      version: VERSION,
      ruby: RUBY_VERSION,
      rails: Rails::VERSION::STRING
    }
  end
end
