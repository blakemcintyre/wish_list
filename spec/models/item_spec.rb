require 'rails_helper'

RSpec.describe Item, type: :model do

  describe "scopes" do
    let(:item) { create(:item, quantity: 1) }

    context "claimed_with_quantity_sum" do
      it "items that have claim records for the list" do
        create(:item_claim, item: item, quantity: 1)
        create(:item_claim, quantity: 1, item: create(:item, quantity: 2))
        create(:item)


        items = described_class.claimed_with_quantity_sum(item.list_id)
        expect(items.length).to eq(1)
        expect(items.first.id).to eq(item.id)
      end
    end

    context "undeleted" do
      it "returns items that don't have deleted_at set" do
        create(:item, deleted_at: Time.zone.now)

        expect(described_class.undeleted).to eq([item])
      end
    end

    context "recently_deleted" do
      it "returns items that were deleted within a given date range" do
        create(:item) # not deleted
        create(:item, deleted_at: 1.week.ago) # deleted outside the range
        item = create(:item, deleted_at: 1.day.ago)

        expect(described_class.recently_deleted(2.days.ago)).to eq([item])
      end
    end
  end

  describe "#remove" do
    it "destroys items that were created less than an hour ago" do
      item = create(:item)

      expect { item.remove }.to change { described_class.count }.by(-1)
    end

    it "sets deleted_at for items created more than an hour ago" do
      item = build(:item)
      travel_to(2.hours.ago) { item.save }

      expect { item.remove }.not_to change { described_class.count }
      expect(item.reload.deleted_at).not_to be_nil
    end

    it "sets deleted_at for items that have claims" do
      item = create(:item, item_claims: [build(:item_claim)])

      expect { item.remove }.not_to change { described_class.count }
      expect(item.reload.deleted_at).not_to be_nil
    end
  end

  describe "#claimed_quantity" do
    it "returns 0 when quantity is nil" do
      item = described_class.new(quantity: nil)
      expect(item.claimed_quantity).to eq(0)
    end

    it "returns the sum of the quantity of the claimed items" do
      item = create(:item, quantity: 4)
      create(:item_claim, item: item, quantity: 1)
      create(:item_claim, item: item, quantity: 2)

      expect(item.claimed_quantity).to eq(3)
    end
  end
end
