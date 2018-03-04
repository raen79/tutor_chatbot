# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

if ['development', 'production'].include? Rails.env
  Thread.new do
    scheduler = Rufus::Scheduler.new

    scheduler.in '1s' do
      QuestionMailer.receive_answers.each do |mail|
        mail.deliver_now
      end
    end

    scheduler.every '5m' do
      QuestionMailer.receive_answers.each do |mail|
        mail.deliver_now
      end
    end

    scheduler.join
  end
end
