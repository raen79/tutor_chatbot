require 'active_support/concern'

module API
  extend ActiveSupport::Concern

  def headers
    {
      'CONTENT_TYPE' => 'application/json',
      'ACCEPT' => 'application/json',
      'HTTP_ACCEPT' => 'application/json'
    }
  end
end