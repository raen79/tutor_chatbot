require 'rails_helper'

RSpec.describe QuestionMailer, type: :mailer do
  describe '#ask_lecturer' do
    before(:each) do
      allow(User).to receive(:find_by).with(:lecturer_id => 'C1529373').and_return(User.new(:email => 'peere@cardiff.ac.uk'))
    end

    subject { QuestionMailer.ask_lecturer(student_question) }
    let(:student_question) { FactoryBot.create :student_question, :id => 510, :lecturer_id => lecturer_id }
    let(:lecturer_id) { 'C1529373' }
    let(:to) { ['peere@cardiff.ac.uk'] }
    let(:m_subject) { "SQ##{student_question.id} | Tutor Chatbot Has a New Question for You" }
    let(:from) { [ENV['GM_USER']] }

    it 'includes appropriate headers' do
      expect(subject.to).to eq(to)
      expect(subject.subject).to eq(m_subject)
      expect(subject.from).to eq(from)
    end

    it 'renders the body with module id, coursework id, student question' do
      expect(subject.body.encoded).to include('Module ID:')
      expect(subject.body.encoded).to include(student_question.module_id)
      expect(subject.body.encoded).to include('Coursework ID:')
      expect(subject.body.encoded).to include(student_question.coursework_id)
      expect(subject.body.encoded).to include(student_question.text)
      expect(subject.body.encoded).to include('Reply to this email without altering its subject or recipients with a plaintext answer to the question.')
    end
  end

  # TODO: Send email to student
  describe '.receive_answers' do
    before(:each) do
      allow(User).to receive(:find_by).with(:email => 'peere@cardiff.ac.uk').and_return(User.new(:lecturer_id => 'C1529373'))
      allow(Datamuse).to receive(:words).and_return([{ 'word' => 'test' }])
      allow(Mail).to receive(:all)
                 .and_return([Mail.new {
                              to ENV['GM_USER'];
                              from 'peere@cardiff.ac.uk';
                              subject 'Re: SQ#510 | Tutor Chatbot Has a New Question for You';
                              body 'This is the reply to your question.'
                            },
                            Mail.new {
                              to ENV['GM_USER'];
                              from 'peere@cardiff.ac.uk';
                              subject 'Re: SQ#670 | Tutor Chatbot Has a New Question for You';
                              body 'This is another reply to your question.'
                            }])
      
      FactoryBot.create :student_question, :id => 510, :text => 'different question?', :lecturer_id => 'C1529373'
      FactoryBot.create :student_question, :id => 670, :lecturer_id => 'C1529373'
    end

    subject { QuestionMailer.receive_answers }

    it { expect { subject }.to change { StudentQuestion.count }.by(-2) }
    it { expect { subject }.to change { Faq.count }.by(2) }
  end
end
