require 'rails_helper'

RSpec.describe "Lists", type: :request do
  let(:user) { create(:user) }

  before do
    login_as(user)
  end

  describe 'GET /lists' do
    let!(:lists) do
      [
        create(:list, permissions: [ListPermission.new(user: user)]),
        create(:list, permissions: [ListPermission.new(user: user)]),
        create(:list, permissions: [ListPermission.new(user: create(:user))])
      ]
    end

    it 'returns lists' do
      get lists_path
      expect(response).to have_http_status(200)
      expect(response).to render_template(:index)
      expect(response.body).to match("<td>#{lists[0].name}</td")
      expect(response.body).to match("<td>#{lists[1].name}</td")
      expect(response.body).not_to match("<td>#{lists[2].name}</td")
    end
  end

  # TODO: the rest of the tests
end
