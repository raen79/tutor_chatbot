require 'rails_helper'

RSpec.describe QuestionMailer, type: :mailer do
  describe '.ask_lecturer' do
    before(:each) do
      allow(User).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound)
      allow(User).to receive(:find_by).with(:lecturer_id => 'C1529373').and_return({ :email => 'peere@cardiff.ac.uk' })
    end

    let!(:student_question) { FactoryBot.create :student_question, :id => 510, :lecturer_id => lecturer_id }
    subject { QuestionMailer.ask_lecturer(student_question) }

    context 'when lecturer email could not be found' do
      let(:lecturer_id) { 'BLANK' }
      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when lecturer email could be found' do
      let(:lecturer_id) { 'C1529373' }
      let(:to) { ['peere@cardiff.ac.uk'] }
      let(:m_subject) { "SQ##{student_question.id} | Tutor Chatbot Has a New Question for You" }
      let(:from) { [ENV['GM_USER']] }

      it { is_expected.to have_attributes(:to => to, :subject => m_subject, :from => from) }

      it 'renders the body with module id, coursework id, student question' do
        expect(subject.body.encoded).to include("Module ID: #{student_question.module_id}")
        expect(subject.body.encoded).to include("Coursework ID: #{student_question.coursework_id}")
        expect(subject.body.encoded).to include(student_question.text)
        expect(subject.body.encoded).to include('Reply to this email without altering its subject or recipients with a plaintext answer to the question.')
      end
    end
  end

  describe '.receive_answer' do
    before(:each) do
      allow(User).to receive(:find_by).and_raise(ActiveRecord::RecordNotFound)
      allow(User).to receive(:find_by).with(:email => 'peere@cardiff.ac.uk').and_return({ :lecturer_id => 'C1529373' })
      allow(Mail).to receive(:all)
                 .and_return([{
                              :to => [ENV['GM_USER']],
                              :from => ['peere@cardiff.ac.uk'],
                              :subject => 'Re: SQ#510 | Tutor Chatbot Has a New Question for You',
                              :body => 'This is the reply to your question.'
                            },
                            {
                              :to => [ENV['GM_USER']],
                              :from => ['peere@cardiff.ac.uk'],
                              :subject => 'Re: SQ#670 | Tutor Chatbot Has a New Question for You',
                              :body => 'This is another reply to your question.'
                            }])
    end

    let!(:student_question) { FactoryBot.create :student_question, :id => 510, :lecturer_id => 'C1529373' }
    let!(:student_question) { FactoryBot.create :student_question, :id => 670, :lecturer_id => 'C1529373' }
    subject { QuestionMailer.receive_answer }

    it { expect { subject }.to change { StudentQuestion.count }.by(-2) }
    it { expect { subject }.to change { Faq.count }.by(2) }
  end
end
