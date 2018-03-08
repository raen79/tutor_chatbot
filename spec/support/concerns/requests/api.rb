require 'active_support/concern'

module API
  extend ActiveSupport::Concern

  def default_headers
    {
      'ACCEPT' => 'application/json',
      'HTTP_ACCEPT' => 'application/json',
      'Authorization' => jwt_token(user_attributes)
    }
  end

  def user_attributes
    {
      :email => 'eran.peer79@gmail.com',
      :lecturer_id => 'C1529345',
      :student_id => 'C1529373'
    }
  end

  def a_hash_of(instance)
    a_hash_including instance.attributes.except('created_at', 'updated_at')
  end

  def attributes_of(instance)
    instance.attributes.except('created_at', 'updated_at')
  end

  def jwt_token(user_attributes)
    JWT.encode user_attributes, private_key, 'RS512'
  end

  def public_key
    OpenSSL::PKey::RSA.new(ENV['RSA_PUBLIC_KEY'].gsub('\n', "\n"))
  end

  def private_key
    OpenSSL::PKey::RSA.new(ENV['RSA_PRIVATE_KEY'].gsub('\n', "\n"))
  end
end
