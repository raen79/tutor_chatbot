Rails.application.routes.draw do
  mount Swaggard::Engine, at: '/api_docs/swagger/'

  scope 'api' do
    scope 'coursework/:coursework_id' do
      resources :faqs
      get '/find_answer', :to => 'faqs#find_answer'
    end
    # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  end
end
