require 'rails_helper'

RSpec.describe V0::KitsController do
  skip { is_expected.to permit(:name,:description,:slug, :sensor_map).for(:update) }
end
