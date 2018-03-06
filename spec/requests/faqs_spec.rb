require 'rails_helper'
include API

RSpec.describe 'Faqs', type: :request do
  before(:each) do
    allow(Datamuse).to receive(:words).and_return([])
  end

  let(:lecturer_id) { user_attributes[:lecturer_id] }
  
  describe 'GET /coursework/:coursework_id/faqs' do
    let!(:faq_to_be_found) { FactoryBot.create :faq, :coursework_id => 'CW135', :lecturer_id => lecturer_id }
    let!(:faq_to_be_found2) { FactoryBot.create :faq, :question => 'New one?', :coursework_id => 'CW135', :lecturer_id => lecturer_id }
    let!(:faq_to_not_find) { FactoryBot.create :faq, :question => 'New one?', :coursework_id => 'CW132', :lecturer_id => lecturer_id }

    let!(:request) { get faqs_path(:coursework_id => 'CW135'), :headers => default_headers }
    subject { JSON.parse(response.body) }

    it { expect(response).to have_http_status(:ok) }
    it { is_expected.to include a_hash_of(faq_to_be_found) }
    it { is_expected.to include a_hash_of(faq_to_be_found2) }
    it { is_expected.not_to include a_hash_of(faq_to_not_find) }
  end

  describe 'GET /coursework/:coursework_id/faqs/:id' do
    let(:faq) { FactoryBot.create :faq, lecturer_id: lecturer_id }
    let!(:request) { get faq_path(:coursework_id => faq.coursework_id, :id => faq_id), :headers => default_headers }
    subject { JSON.parse(response.body) }
    
    context 'when faq exists' do
      let(:faq_id) { faq.id }
      let(:faq_attrs) { attributes_of(faq).merge('url' => "http://#{@request.host}/coursework/#{faq.coursework_id}/faqs/#{faq.id}.json") }
      it { expect(response).to have_http_status(:ok) }
      it { is_expected.to include(faq_attrs) }
    end

    context 'when faq doesn\'t exist' do
      let(:faq_id) { faq.id + 10 }
      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'POST /coursework/:coursework_id/faqs' do
    let(:request) do
      post faqs_path(:coursework_id => faq_attrs[:coursework_id]),
           :params => { :faq => faq_attrs },
           :headers => default_headers
    end

    subject { JSON.parse(response.body) }
    
    context 'when parameters valid' do
      let(:faq_attrs) { FactoryBot.attributes_for(:faq, :lecturer_id => nil).with_indifferent_access }
      
      it { request; expect(response).to have_http_status(:created) }
      it { request; is_expected.to include faq_attrs.merge(:lecturer_id => user_attributes[:lecturer_id]) }
      it { expect { request }.to change { Faq.count }.by(1) }
    end

    context 'when parameters invalid' do
      let(:faq_attrs) { FactoryBot.attributes_for(:faq, :question => nil) }
      
      it { request; expect(response).to have_http_status(:unprocessable_entity) }
      it { expect { request }.to change { Faq.count }.by(0) }
    end      
  end

  describe 'PUT /coursework/:coursework_id/faqs/:id' do
    let(:faq) { FactoryBot.create :faq, :question => 'An old question?', :lecturer_id => user_attributes[:lecturer_id] }
    let!(:request) do
      put faq_path(:coursework_id => faq.coursework_id, :id => faq.id),
          :params => { :faq => faq_attrs },
          :headers => default_headers
    end

    subject { JSON.parse(response.body) }
    
    context 'when faq attributes valid' do
      let(:faq_attrs) { { :question => 'A new question?' }.with_indifferent_access }
      it { expect(response).to have_http_status(:ok) }
      it { is_expected.to include(faq_attrs) }
      it { expect(Faq.find(faq.id)).to have_attributes(faq_attrs) }
    end

    context 'when faq attributes invalid' do
      let(:faq_attrs) { { :question => 'A new question' }.with_indifferent_access }
      it { expect(response).to have_http_status(:unprocessable_entity) }
      it { is_expected.to include('question') }
    end

    context 'when faq does not exist' do
      let(:faq) { FactoryBot.build :faq, :id => 100, :lecturer_id => user_attributes[:lecturer_id] }
      let(:faq_attrs) { { :question => 'A new question?' } }
      it { expect(response).to have_http_status(:not_found) }
    end
  end

  describe 'DELETE /coursework/:coursework_id/faqs/:id' do
    let(:faq) { FactoryBot.create :faq, :lecturer_id => user_attributes[:lecturer_id] }
    let(:request) do
      delete faq_path(:coursework_id => faq.coursework_id, :id => faq.id),
             :headers => default_headers
    end

    subject { JSON.parse(response.body) }

    context 'when faq exists' do
      it { request; expect(response).to have_http_status(:no_content) }
      it { faq; expect { request }.to change { Faq.count }.by(-1) }
    end

    context 'when faq doesn\'nt exist' do
      let(:faq) { FactoryBot.build :faq, :id => 100, :lecturer_id => user_attributes[:lecturer_id] }
      it { request; expect(response).to have_http_status(:not_found) }
      it { expect { request }.to change { Faq.count }.by(0) }
    end
  end
  
  describe 'GET /coursework/:coursework_id/faqs/find_answer' do
    before(:each) do
      allow(Datamuse).to receive(:words) do |opts|
        case opts[:ml]
        when 'film'
          [{ 'word' => 'movie', 'score' => 56808, 'tags' => ['syn', 'n'] }]
        when 'color'
          [{ 'word' => 'panchromatic', 'score' => 97284,'tags' => ['syn','adj'] }]
        when 'available'
          [{ 'word' => 'availability', 'score' => 97284,'tags' => ['syn','adj'] }]
        else
          []
        end
      end
    end

    let(:question) { 'test?' }
    let!(:faq) { FactoryBot.create :faq, :question => 'This film is available in color?' }
    let(:request) do
      get find_answer_path(
            :coursework_id => faq.coursework_id,
            :module_id => faq.module_id,
            :lecturer_id => faq.lecturer_id,
            :question => question
          ),
          :headers => default_headers
    end

    subject { JSON.parse(response.body) }

    it { request; expect(response).to have_http_status(:ok) }
    it { request; is_expected.to include('answer') }

    context 'when faq found' do
      let(:question) { 'This movie availability panchromatic?' }
      before { request }
      it { is_expected.to include('answer' => faq.answer) }
    end

    context 'when faq not found' do
      let(:question) { 'This is totally random?' }
      it { request; is_expected.to include('answer' => 'I have found no answer to your question, I\'ll ask my supervisor and reply to you by email.') }
      it { expect { request }.to change { ActionMailer::Base.deliveries.size }.by(1) }
    end
  end
end
