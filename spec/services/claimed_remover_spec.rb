require 'rails_helper'

RSpec.describe ClaimedRemover, type: :model do
  subject(:instance) { described_class.new(user) }

  let(:user) { create(:user) }

  describe '#process' do
    let!(:item1) { create(:item, quantity: 2, user: user) }
    let(:item2) { create(:item, quantity: 2, user: user) }
    let(:item3) { create(:item, quantity: 2, user: user) }
    let(:item4) { create(:item, quantity: nil, user: user) }
    let!(:item5) { create(:item, deleted_at: 1.day.ago, user: user) }

    before do
      create_list(:item_claim, 2, item: item2, quantity: 1)
      create(:item_claim, item: item3, quantity: 1)

      instance.process
    end

    it 'removes items with claimed quantity matching item quantity' do
      expect(Item.where(id: item2.id)).to be_empty
    end

    it 'reduces quantity of items partially claimed' do
      expect(item3.reload.quantity).to equal(1)
    end

    it "doesn't change quantity on unclaimed items" do
      expect(item1.reload.quantity).to equal(2)
    end

    it 'deletes all associated claims' do
      expect(ItemClaim.count).to eq(0)
    end

    it 'removes soft deleted items' do
      expect(Item.where(id: item5.id)).to eq([])
    end
  end
end
