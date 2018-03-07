require 'rails_helper'

RSpec.describe FaqsController, type: :routing do
  describe 'routing' do

    it 'routes to #index' do
      expect(:get => 'api/coursework/1/faqs').to route_to('faqs#index', :coursework_id => '1')
    end


    it 'routes to #show' do
      expect(:get => 'api/coursework/1/faqs/1').to route_to('faqs#show', :id => '1', :coursework_id => '1')
    end


    it 'routes to #create' do
      expect(:post => 'api/coursework/1/faqs').to route_to('faqs#create', :coursework_id => '1')
    end

    it 'routes to #update via PUT' do
      expect(:put => 'api/coursework/1/faqs/1').to route_to('faqs#update', :id => '1', :coursework_id => '1')
    end

    it 'routes to #update via PATCH' do
      expect(:patch => 'api/coursework/1/faqs/1').to route_to('faqs#update', :id => '1', :coursework_id => '1')
    end

    it 'routes to #destroy' do
      expect(:delete => 'api/coursework/1/faqs/1').to route_to('faqs#destroy', :id => '1', :coursework_id => '1')
    end

    it 'routes to #find_answer' do
      expect(:get => 'api/coursework/1/find_answer?question=test').to route_to('faqs#find_answer', :coursework_id => '1', :question => 'test')
    end
  end
end
