require 'rails_helper'

RSpec.describe QuestionMailer, type: :mailer do
  describe '#ask_lecturer' do
    before(:each) do
      allow(HTTParty).to receive(:get).and_return(
        double(HTTParty::Response, :body => {
          :id => 1,
          :email => to[0],
          :student_id => nil,
          :lecturer_id => lecturer_id
        }.to_json)
      )
    end

    subject(:question_mailer) { QuestionMailer.ask_lecturer(student_question) }
    let(:student_question) { FactoryBot.create :student_question, :id => 510, :lecturer_id => lecturer_id }
    let(:lecturer_id) { 'C1529373' }
    let(:to) { ['peere@cardiff.ac.uk'] }
    let(:m_subject) { "SQ##{student_question.id} | Tutor Chatbot Has a New Question for You" }
    let(:from) { [ENV['GM_USER']] }

    describe 'headers' do
      it { expect(subject.to).to eq(to) }
      it { expect(subject.subject).to eq(m_subject) }
      it { expect(subject.from).to eq(from) }
    end

    describe 'body' do
      subject { question_mailer.body.encoded }
      it { is_expected.to include('Module ID:') }
      it { is_expected.to include(student_question.module_id) }
      it { is_expected.to include('Coursework ID:') }
      it { is_expected.to include(student_question.coursework_id) }
      it { is_expected.to include(student_question.text) }
      it { is_expected.to include('Reply to this email without altering its subject or recipients with a plaintext answer to the question.') }
    end
  end
  
  describe '#receive_answer' do
    before(:each) do
      allow(HTTParty).to receive(:get).and_return(
        double(HTTParty::Response, :body => {
          :id => 1,
          :email => to[0],
          :student_id => 'C1529373',
          :lecturer_id => nil
        }.to_json)
      )
      allow(Datamuse).to receive(:words).and_return([{ 'word' => 'test' }])
    end

    let(:mail) { 
      Mail.new { 
        to ENV['GM_USER']; 
        from 'peere@cardiff.ac.uk';
        subject 'Re: SQ#510 | Tutor Chatbot Has a New Question for You';
        body 'This is the reply to your question.'
      }
    }

    let!(:student_question) { FactoryBot.create :student_question, :id => 510, :text => 'different question?', :lecturer_id => 'C1529373' }
    let(:to) { ['peere@cardiff.ac.uk'] }
    let(:from) { [ENV['GM_USER']] }
    let(:m_subject) { 'SQ#510 | Your tutor has replied to your question' }
    subject(:question_mailer) { QuestionMailer.receive_answer(mail.subject, mail.from, mail.decoded).deliver }

    it { expect { subject }.to change { StudentQuestion.count }.by(-1) }
    it { expect { subject }.to change { Faq.count }.by(1) }    

    describe 'headers' do
      it { expect(subject.to).to eq(to) }
      it { expect(subject.subject).to eq(m_subject) }
      it { expect(subject.from).to eq(from) }
    end

    describe 'body' do
      subject { question_mailer.body.encoded }
      it { is_expected.to include('Module ID:') }
      it { is_expected.to include(student_question.module_id) }
      it { is_expected.to include('Coursework ID:') }
      it { is_expected.to include(student_question.coursework_id) }
      it { is_expected.to include('Your Question:') }
      it { is_expected.to include(student_question.text) }
      it { is_expected.to include('This is the reply to your question.') }
    end
  end

  describe '.receive_answers' do
    before(:each) do
      allow(HTTParty).to receive(:get).and_return(
        double(HTTParty::Response, :body => {
          :id => 1,
          :email => 'peere@cardiff.ac.uk',
          :student_id => 'C1529373',
          :lecturer_id => nil
        }.to_json)
      )
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
    end

    let!(:sq_510) { FactoryBot.create :student_question, :id => 510, :text => 'different question?', :lecturer_id => 'C1529373' }
    let!(:sq_670) { FactoryBot.create :student_question, :id => 670, :lecturer_id => 'C1529373' }

    subject(:question_mailer) { QuestionMailer.receive_answers }

    it { expect(subject.size).to eq(2) }

    describe 'mail' do
      subject(:mail) { question_mailer.find { |mail| mail.subject.include? "SQ##{student_question.id}" } }

      context 'for student_question#670' do
        let(:student_question) { sq_670 }
        let(:to) { ['peere@cardiff.ac.uk'] }
        let(:from) { [ENV['GM_USER']] }
        let(:m_subject) { 'SQ#670 | Your tutor has replied to your question' }

        describe 'headers' do
          it { expect(subject.to).to eq(to) }
          it { expect(subject.subject).to eq(m_subject) }
          it { expect(subject.from).to eq(from) }
        end

        describe 'body' do
          subject { mail.body.encoded }
          it { is_expected.to include('Module ID:') }
          it { is_expected.to include(student_question.module_id) }
          it { is_expected.to include('Coursework ID:') }
          it { is_expected.to include(student_question.coursework_id) }
          it { is_expected.to include('Your Question:') }
          it { is_expected.to include(student_question.text) }
          it { is_expected.to include('This is another reply to your question.') }
        end
      end
    end
  end
end
