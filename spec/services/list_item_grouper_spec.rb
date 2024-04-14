# frozen_string_literal: true

require 'rails_helper'

# --- Test Setup ---
# Claim user indicator:
# v - viewing user
# o - another user who made claims
# --- ---
#
# -- Unclaimed --
# - Cat 1 -
#   - Item 1
#   - Sub Cat 1-1 -
#     - Item 2
# - Cat 2 -
#   - Item 3 (unlimited)
#   - Item 4 (1/2 qty)
# - Cat 3 -
#   - Sub Cat 3-1 -
#     - Item 5
#   - Sub Cat 3-2 -
#     - Item 6
#
# -- Claimed --
# - Cat 1 -
#   - Item 7 (v)
#   - Sub Cat 1-1
#     - Item 8 (o)
# - Cat 2 -
#   - Item 3 (o 2/*)
#   - Item 4 (o 1/2)
#   - Item 9 (v)
# - Cat 4 -
#   - Item 10 (o)
#   - Sub Cat 4-1
#     Item 11 (o)
#
# -- Deleted --
# - Cat 1 -
#   - Item 12 (recent)
#   - Item 13 (not recent)

RSpec.describe ListItemGrouper do
  subject(:instance) { described_class.new(list, viewing_user) }

  let(:list) { create(:list) }
  let(:viewing_user) { create(:user) }
  let(:claim_only_user) { create(:user) }
  let!(:cat1) { create(:category, list: list, name: 'Cat1') }
  let!(:cat1_sub1) { create(:category, list: list, parent_category: cat1, name: 'Cat1 Sub1') }
  let!(:cat2) { create(:category, list: list, name: 'Cat2') }
  let!(:cat3) { create(:category, list: list, name: 'Cat3') }
  let!(:cat3_sub1) { create(:category, list: list, parent_category: cat3, name: 'Cat3 Sub1') }
  let!(:cat3_sub2) { create(:category, list: list, parent_category: cat3, name: 'Cat3 Sub2') }
  let!(:cat4) { create(:category, list: list, name: 'Cat4') }
  let!(:cat4_sub1) { create(:category, list: list, parent_category: cat4, name: 'Cat4 Sub1') }
  let!(:item1) { create(:item, list: list, category: cat1) }
  let!(:item2) { create(:item, list: list, category: cat1_sub1) }
  let!(:item3) { create(:item, list: list, category: cat2, quantity: nil) }
  let!(:item4) { create(:item, list: list, category: cat2, quantity: 2) }
  let!(:item5) { create(:item, list: list, category: cat3_sub1) }
  let!(:item6) { create(:item, list: list, category: cat3_sub2) }
  let!(:item7) { create(:item, list: list, category: cat1) }
  let!(:item8) { create(:item, list: list, category: cat1_sub1) }
  let!(:item9) { create(:item, list: list, category: cat2) }
  let!(:item10) { create(:item, list: list, category: cat4) }
  let!(:item11) { create(:item, list: list, category: cat4_sub1) }
  let!(:item12) { create(:item, list: list, category: cat1, deleted_at: Time.zone.now) }
  let!(:item13) { create(:item, list: list, category: cat1, deleted_at: 2.months.ago) }

  before do
    create(:item_claim, item: item3, user: claim_only_user, quantity: 2)
    create(:item_claim, item: item4, user: claim_only_user, quantity: 1)
    create(:item_claim, item: item7, user: viewing_user)
    create(:item_claim, item: item8, user: claim_only_user)
    create(:item_claim, item: item9, user: viewing_user)
    create(:item_claim, item: item10, user: claim_only_user)
    create(:item_claim, item: item11, user: claim_only_user)
  end

  describe '#process' do
    let(:results) { instance.process }
    let(:claimed) { results.first }
    let(:unclaimed) { results.last }

    context 'with claimed' do
      it 'sets parent categories' do
        expect(claimed.keys).to eq([[cat1.id, cat1.name], [cat2.id, cat2.name], [cat4.id, cat4.name]])
      end

      it 'sets sub-categories' do
        expect(claimed[[cat1.id, cat1.name]][:sub_categories].keys).to eq([[cat1_sub1.id, cat1_sub1.name]])
        expect(claimed[[cat2.id, cat2.name]][:sub_categories]).to be_empty
        expect(claimed[[cat3.id, cat3.name]][:sub_categories]).to be_empty
        expect(claimed[[cat4.id, cat4.name]][:sub_categories].keys).to eq([[cat4_sub1.id, cat4_sub1.name]])
      end

      it 'sets parent items' do
        expect(claimed[[cat1.id, cat1.name]][:items].size).to eq(1)
        item = claimed[[cat1.id, cat1.name]][:items].first
        expect(item.id).to eq(item7.id)
        expect(item.user_claimed_quantity).to eq(1)
        expect(item.total_claimed_quantity).to eq(1)
        expect(item.quantity_remaining).to eq(0)

        expect(claimed[[cat2.id, cat2.name]][:items].size).to eq(3)
        item_first, item_mid, item_last = claimed[[cat2.id, cat2.name]][:items]
        expect(item_first.id).to eq(item3.id)
        expect(item_first.user_claimed_quantity).to eq(0)
        expect(item_first.total_claimed_quantity).to eq(2)
        expect(item_first.quantity_remaining).to be_nil
        expect(item_mid.id).to eq(item4.id)
        expect(item_mid.user_claimed_quantity).to eq(0)
        expect(item_mid.total_claimed_quantity).to eq(1)
        expect(item_mid.quantity_remaining).to eq(1)
        expect(item_last.id).to eq(item9.id)
        expect(item_last.user_claimed_quantity).to eq(1)
        expect(item_last.total_claimed_quantity).to eq(1)
        expect(item_last.quantity_remaining).to eq(0)
      end

      it 'sets sub-category items' do
        key = [[cat1.id, cat1.name], :sub_categories, [cat1_sub1.id, cat1_sub1.name]]
        expect(claimed.dig(*key).size).to eq(1)
        item = claimed.dig(*key).first
        expect(item.id).to eq(item8.id)
        expect(item.user_claimed_quantity).to eq(0)
        expect(item.total_claimed_quantity).to eq(1)
        expect(item.quantity_remaining).to eq(0)

        key = [[cat4.id, cat4.name], :sub_categories, [cat4_sub1.id, cat4_sub1.name]]
        expect(claimed.dig(*key).size).to eq(1)
        item = claimed.dig(*key).first
        expect(item.id).to eq(item11.id)
        expect(item.user_claimed_quantity).to eq(0)
        expect(item.total_claimed_quantity).to eq(1)
        expect(item.quantity_remaining).to eq(0)
      end
    end

    context 'with unclaimed' do
      it 'sets parent categories' do
        expect(unclaimed.keys).to eq([[cat1.id, cat1.name], [cat2.id, cat2.name], [cat3.id, cat3.name]])
      end

      it 'sets sub-categories' do
        expect(unclaimed[[cat1.id, cat1.name]][:sub_categories].keys).to eq([[cat1_sub1.id, cat1_sub1.name]])
        expect(unclaimed[[cat2.id, cat2.name]][:sub_categories]).to be_empty
        expect(unclaimed[[cat3.id, cat3.name]][:sub_categories].keys).to eq(
          [[cat3_sub1.id, cat3_sub1.name], [cat3_sub2.id, cat3_sub2.name]]
        )
        expect(unclaimed[[cat4.id, cat4.name]][:sub_categories]).to be_empty
      end

      it 'sets parent items' do
        expect(unclaimed[[cat1.id, cat1.name]][:items].size).to eq(1)
        item = unclaimed[[cat1.id, cat1.name]][:items].first
        expect(item.id).to eq(item1.id)
        expect(item.user_claimed_quantity).to eq(0)
        expect(item.total_claimed_quantity).to eq(0)
        expect(item.quantity_remaining).to eq(1)

        expect(unclaimed[[cat2.id, cat2.name]][:items].size).to eq(2)
        item_first, item_last = unclaimed[[cat2.id, cat2.name]][:items]
        expect(item_first.id).to eq(item3.id)
        expect(item_first.user_claimed_quantity).to eq(0)
        expect(item_first.total_claimed_quantity).to eq(2)
        expect(item_first.quantity_remaining).to be_nil
        expect(item_last.id).to eq(item4.id)
        expect(item_last.user_claimed_quantity).to eq(0)
        expect(item_last.total_claimed_quantity).to eq(1)
        expect(item_last.quantity_remaining).to eq(1)

        expect(unclaimed[[cat3.id, cat3.name]][:items]).to be_empty
      end

      it 'sets sub-category items' do
        key = [[cat1.id, cat1.name], :sub_categories, [cat1_sub1.id, cat1_sub1.name]]
        expect(unclaimed.dig(*key).size).to eq(1)
        item = unclaimed.dig(*key).first
        expect(item.id).to eq(item2.id)
        expect(item.user_claimed_quantity).to eq(0)
        expect(item.total_claimed_quantity).to eq(0)
        expect(item.quantity_remaining).to eq(1)

        key = [[cat3.id, cat3.name], :sub_categories, [cat3_sub1.id, cat3_sub1.name]]
        expect(unclaimed.dig(*key).size).to eq(1)
        item = unclaimed.dig(*key).first
        expect(item.id).to eq(item5.id)
        expect(item.user_claimed_quantity).to eq(0)
        expect(item.total_claimed_quantity).to eq(0)
        expect(item.quantity_remaining).to eq(1)

        key = [[cat3.id, cat3.name], :sub_categories, [cat3_sub2.id, cat3_sub2.name]]
        expect(unclaimed.dig(*key).size).to eq(1)
        item = unclaimed.dig(*key).first
        expect(item.id).to eq(item6.id)
        expect(item.user_claimed_quantity).to eq(0)
        expect(item.total_claimed_quantity).to eq(0)
        expect(item.quantity_remaining).to eq(1)
      end
    end
  end
end
