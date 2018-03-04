require 'rails_helper'
include API

RSpec.describe 'Faqs', type: :request do

  describe 'GET /faqs' do
    it 'works! (now write some real specs)' do
      get faqs_path, :headers => headers
      expect(response).to have_http_status(200)
    end
  end
end
