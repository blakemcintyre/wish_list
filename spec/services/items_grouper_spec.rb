require 'rails_helper'

# --- Test Setup ---
# Claim user indicator:
# a - viewing user
# b - another user who made claims
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
#   - Item 7 (a)
#   - Sub Cat 1-1
#     - Item 8 (b)
# - Cat 2 -
#   - Item 4 (b 1/2)
#   - Item 9 (a)
# - Cat 4 -
#   - Item 10 (b)
#   - Sub Cat 4-1
#     Item 11 (b)
#
# -- Deleted --
# - Cat 1 -
#   - Item 12 (recent)
#   - Item 13 (not recent)

RSpec.describe ItemsGrouper, type: :model do
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

  subject(:instance) { described_class.new(list, viewing_user) }

  describe '#unclaimed_categories' do
    it 'returns categories with showable items' do
      expect(instance.unclaimed_categories).to match_array([cat1, cat2, cat3])
    end
  end

  describe '#claimed_categories' do
    it 'returns categories with showable items' do
      expect(instance.claimed_categories).to match_array([cat1, cat2, cat4])
    end
  end

  describe '#@unclaimed_sub_categories' do
    it 'returns sub categories with showable items' do
      expect(instance.unclaimed_sub_categories).to eq(
        cat1.id => SortedSet.new([cat1_sub1]),
        cat3.id => SortedSet.new([cat3_sub1, cat3_sub2])
      )
    end
  end

  describe '#@claimed_sub_categories' do
    it 'returns sub categories with showable items' do
      expect(instance.claimed_sub_categories).to eq(
        cat1.id => SortedSet.new([cat1_sub1]),
        cat4.id => SortedSet.new([cat4_sub1])
      )
    end
  end

  describe '#recently_deleted_items' do
    it 'returns delete items' do
      expect(instance.recently_deleted_items).to eq([item12])
    end
  end

  describe '#empty?' do
    it 'returns false' do
      expect(instance.empty?).to be_falsy
    end

    it 'returns true' do
      Item.destroy_all
      expect(instance.empty?).to be_truthy
    end
  end

  describe '#items_by_category' do
    subject(:items_by_category) { instance.items_by_category }

    it 'returns items grouped by category and tag' do
      expected = {
        [cat1.id, :claimed] => [item7],
        [cat1.id, :unclaimed] => [item1],
        [cat1_sub1.id, :claimed] => [item8],
        [cat1_sub1.id, :unclaimed] => [item2],
        [cat2.id, :claimed] => [item3, item4, item9],
        [cat2.id, :unclaimed] => [item3, item4],
        [cat3_sub1.id, :unclaimed] => [item5],
        [cat3_sub2.id, :unclaimed] => [item6],
        [cat4.id, :claimed] => [item10],
        [cat4_sub1.id, :claimed] => [item11]
      }
      expect(items_by_category.keys).to match_array(expected.keys)

      items_by_category.each do |key, items|
        expect(items).to match_array(expected[key])
      end
    end
  end
end
