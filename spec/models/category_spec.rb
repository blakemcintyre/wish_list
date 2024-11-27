require 'rails_helper'

RSpec.describe Category, type: :model do
  describe '#remove' do
    let!(:category) { create(:category) }

    context 'when items are empty' do
      before do
        create_list(:item, 3, category: category)
      end

      it 'deletes the record' do
        expect { category.remove }.to change { described_class.count }.by(-1)
      end
    end

    context 'when items are not empty' do
      before do
        create(:item, category: category, created_at: 2.hours.ago)
        create(:item, category: category)
      end

      it 'updates delete_at' do
        expect { category.remove }.not_to change { described_class.count }
        expect(category.deleted_at).not_to be_nil
      end
    end

    context 'when there are sub categories' do
      let(:sub_category) { create(:category, parent_category: category) }

      before do
        create(:item, category: sub_category)
      end

      it 'removes the sub category and its items' do
        expect { category.remove }.to change { described_class.count }.by(-2)
      end
    end
  end
end
