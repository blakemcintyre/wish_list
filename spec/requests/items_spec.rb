require 'rails_helper'

RSpec.describe "Items", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe 'PATCH /items/:id/' do
    let(:lists) { create_list(:list, 2) }
    let(:item) { create(:item, list: lists.first, name: 'One') }

    before do
      lists.each do |list|
        list.permissions.create(user: user)
      end
    end

    it 'updates name and redirects to list index' do
      patch item_path(item.id), params: { item: { name: 'Not One'} }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(list_items_path(lists.first.id))
      expect(item.reload.name).to eq('Not One')
    end

    it 'list if and redirects to previous list index' do
      patch item_path(item.id), params: { item: { list_id: lists.last.id } }
      expect(response).to have_http_status(302)
      expect(response).to redirect_to(list_items_path(lists.first.id))
      expect(item.reload.list_id).to eq(lists.last.id)
    end
  end
end
