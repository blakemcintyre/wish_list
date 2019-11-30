require 'rails_helper'

RSpec.describe Item, type: :model do

  describe "scopes" do
    let(:item) { create(:item, quantity: 1) }

    context "claimed" do
      it "items that have been claimed for the user" do
        create(:item_claim, item: item, quantity: 1)
        create(:item_claim, quantity: 1, item: create(:item, quantity: 2))
        create(:item)


        items = described_class.claimed(item.user_id)
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

  describe ".claimed_grouping" do
    it "returns items grouped as claimed and unclaimed" do
      item_user = create(:user)
      claim_user = create(:user)
      items_with_claims = create_list(:item, 2, quantity: 2, user: item_user)
      unclaimed_item = create(:item, user: item_user)
      create(:item_claim, item: items_with_claims.first, user: claim_user, quantity: 2)
      create(:item_claim, item: items_with_claims.last, quantity: 1)
      expected = {
        claimed: [items_with_claims.first.id, items_with_claims.last.id],
        unclaimed: [unclaimed_item.id, items_with_claims.last.id].sort
      }

      results = described_class.claimed_grouping(item_user.id, claim_user.id)
      results[:unclaimed].sort!
      expect(results).to eq(expected)
    end
  end
end
