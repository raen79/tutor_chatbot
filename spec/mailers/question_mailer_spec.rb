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

    describe 'headers' do
      it { expect(subject.to).to eq(to) }
      it { expect(subject.subject).to eq(m_subject) }
      it { expect(subject.from).to eq(from) }
    end

    describe 'body' do
      subject { subject.body.encoded }
      it { is_expected.to include('Module ID:') }
      it { is_expected.to include(student_question.module_id) }
      it { is_expected.to include('Coursework ID:') }
      it { is_expected.to include(student_question.coursework_id) }
      it { is_expected.to include(student_question.text) }
      it { is_expected.to include('Reply to this email without altering its subject or recipients with a plaintext answer to the question.') }
    end
  end

  # TODO: Send email to student
  describe '.receive_answers' do
    before(:each) do
      allow(User).to receive(:find_by).with(:student_id => 'C1529373').and_return(User.new(:email => 'peere@cardiff.ac.uk'))
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

    subject { QuestionMailer.receive_answers }

    it { expect { subject }.to change { StudentQuestion.count }.by(-2) }
    it { expect { subject }.to change { Faq.count }.by(2) }
    it { is_expected.to have_exactly(2).items }

    describe 'mail' do
      subject { subject.find { |mail| mail.subject.include("SQ##{student_question.id}") } }

      context 'for student_question#510' do
        let(:student_question) { sq_510 }
        let(:to) { 'peere@cardiff.ac.uk' }
        let(:from) { ENV['GM_USER'] }
        let(:m_subject) { 'SQ#510 | Your tutor has replied to your question' }

        describe 'headers' do
          it { expect(subject.to).to eq(to) }
          it { expect(subject.subject).to eq(m_subject) }
          it { expect(subject.from).to eq(from) }
        end

        describe 'body' do
          subject { subject.body.encoded }
          it { is_expected.to include('Module ID:') }
          it { is_expected.to include(student_question.module_id) }
          it { is_expected.to include('Coursework ID:') }
          it { is_expected.to include(student_question.coursework_id) }
          it { is_expected.to include('Your Question:') }
          it { is_expected.to include(student_question.question) }
          it { is_expected.to include('This is the reply to your question.') }
        end
      end

      context 'for student_question#670' do
        let(:student_question) { sq_670 }
        let(:to) { 'peere@cardiff.ac.uk' }
        let(:from) { ENV['GM_USER'] }
        let(:m_subject) { 'SQ#670 | Your tutor has replied to your question' }

        describe 'headers' do
          it { expect(subject.to).to eq(to) }
          it { expect(subject.subject).to eq(m_subject) }
          it { expect(subject.from).to eq(from) }
        end

        describe 'body' do
          subject { subject.body.encoded }
          it { is_expected.to include('Module ID:') }
          it { is_expected.to include(student_question.module_id) }
          it { is_expected.to include('Coursework ID:') }
          it { is_expected.to include(student_question.coursework_id) }
          it { is_expected.to include('Your Question:') }
          it { is_expected.to include(student_question.question) }
          it { is_expected.to include('This is another reply to your question.') }
        end
      end
    end
  end
end
