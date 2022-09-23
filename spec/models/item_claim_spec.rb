require 'rails_helper'

RSpec.describe ItemClaim, type: :model do
  let(:list) { create(:list) }
  let(:item) { create(:item, list: list) }
  let(:user) { create(:user) }

  describe '#clear_blanks via before_save' do
    subject(:instance) { build(:item_claim, item: item, user: user, notes: notes) }

    before do
      instance.save
      instance.reload
    end

    context 'when notes is empty' do
      let(:notes) { '' }

      it 'sets it to nil' do
        expect(instance.notes).to be_nil
      end
    end

    context 'when notes has a value' do
      let(:notes) { 'a value' }

      it 'keeps it as is' do
        expect(instance.notes).to eq(notes)
      end
    end
  end
end
