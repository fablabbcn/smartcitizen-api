require 'rails_helper'

RSpec.describe V0::DevicesController do
  skip { is_expected.to permit(:name,:description,:mac_address,:latitude,:longitude,:elevation,:exposure,:meta,:kit_id,:user_tags).for(:create) }


end
