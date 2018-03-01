ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {  
  :address => 'smtp.gmail.com',  
  :port => 587,  
  :domain => 'gmail.com',
  :user_name => ENV['GM_USER'],
  :password => ENV['GM_PWD'],
  :authentication => 'plain',  
  :enable_starttls_auto => true  
}

Mail.defaults do
  retriever_method :pop3, :address    => "pop.gmail.com",
                          :port       => 995,
                          :user_name  => ENV['GM_USER'],
                          :password   => ENV['GM_PWD'],
                          :enable_ssl => true
end
