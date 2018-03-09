require 'rails_helper'

RSpec.describe StudentQuestion, type: :model do
  before(:each) do
    allow(HTTParty).to receive(:get).and_return(
      double(HTTParty::Response, :body => {
        :id => 1,
        :email => 'peere@cardiff.ac.uk',
        :student_id => 'C1529373',
        :lecturer_id => 'C1529373'
      }.to_json)
    )
  end
  
  describe 'Validation' do
    describe '#text' do
      it_behaves_like 'question', :student_question, :text
    end

    describe '#coursework_id' do
      it_behaves_like 'id', :student_question, 'coursework'
    end

    describe '#student_id' do
      it_behaves_like 'id', :student_question, 'student'
    end

    describe '#lecturer_id' do
      it_behaves_like 'id', :student_question, 'lecturer'
    end

    describe '#module_id' do
      it_behaves_like 'id', :student_question, 'module'
    end

    context 'after create' do
      subject { FactoryBot.create :student_question }
      it { expect { subject }.to change { ActionMailer::Base.deliveries.count }.by(1) }
    end
  end

  describe '#answer' do
    let!(:student_question) { FactoryBot.create :student_question }
    subject { student_question.answer(answer) }
    
    context 'when attr answer < 3 chars' do
      let(:answer) { 'no' }
      it { expect { subject }.to raise_error(ArgumentError, 'answer should be >= 3') }
    end

    context 'when attr answer valid' do
      before { allow(Datamuse).to receive(:words).and_return([{ 'word' => 'tinnitus' }]) }
      let(:answer) { 'An appropriate answer.' }
      it { expect { subject }.to change { Faq.count }.by(1) }
      it { expect { subject }.to change { StudentQuestion.count }.by(-1) }
      it { is_expected.to be_truthy }
    end
  end
end
