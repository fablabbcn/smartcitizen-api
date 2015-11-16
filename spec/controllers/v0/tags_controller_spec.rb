require 'rails_helper'

RSpec.describe V0::TagsController do
  it { is_expected.to permit(:name,:description).for(:create) }
end
