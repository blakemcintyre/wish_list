require 'rails_helper'

RSpec.describe ItemClaim, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:item) }
    it { is_expected.to belong_to(:user) }
  end
end
