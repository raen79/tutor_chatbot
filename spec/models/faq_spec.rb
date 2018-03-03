require 'rails_helper'

RSpec.describe Faq, type: :model do
  before(:each) do
    datamuse_return_hash = [{ 'word' => 'tinnitus', 'score' => 51691, 'tags' => ['syn','n'] },
                            { 'word' => 'ring', 'score' => 28491, 'tags' => ['n'] },
                            { 'word' => 'cinchonism', 'score' => 28392, 'tags' => ['n'] },
                            { 'word' => 'acouasm', 'score' => 28091 },
                            { 'word' => 'rings','score' => 28091,'tags' => ['n'] }]
    allow(Datamuse).to receive(:words).and_return(datamuse_return_hash)
  end

  describe 'Validation' do
    describe '#question' do
      it_behaves_like 'question', :faq, :question
    end
    
    describe '#answer' do
      subject { FactoryBot.build :faq, :answer => answer }

      context 'when < 3 chars' do
        let(:answer) { 'a' }
        it { is_expected.not_to be_valid }
      end
    end

    describe '#module_id' do
      it_behaves_like 'id', :faq, 'module'
    end

    describe '#lecturer_id' do
      it_behaves_like 'id', :faq, 'lecturer'
    end

    describe '#coursework_id' do
      it_behaves_like 'id', :faq, 'coursework'
    end

    describe '(#question, #coursework_id)' do
      subject { FactoryBot.build :faq, :question => question, :coursework_id => coursework_id }

      context 'when not unique' do
        let(:question) { 'This is a previously asked question?' }
        let (:coursework_id) { 'CM234' }
        let!(:non_unique_faq) { FactoryBot.create :faq, :question => question, :coursework_id => coursework_id }
        it { is_expected.not_to be_valid }
      end

      context 'when only #question unique' do
        let (:coursework_id) { 'CM234' }
        let (:question) { 'unique question?' }
        let!(:non_unique_faq) { FactoryBot.create :faq, :question => 'unique too?', :coursework_id => coursework_id }
        it { is_expected.to be_valid }
      end

      context 'when only #coursework_id unique' do
        let (:coursework_id) { 'CM234' }
        let (:question) { 'reused question?' }
        let!(:non_unique_faq) { FactoryBot.create :faq, :question => question, :coursework_id => 'CM435' }
        it { is_expected.to be_valid }
      end
    end

    context 'when valid' do
      subject { FactoryBot.create :faq, :question => 'Do you know if this film is available in color?' }
      it { expect { subject }.to change { Faq.count }.by(1) }
      it 'should have an association `synonyms` with appropriate instances of Synonym' do
        expect(subject.synonyms).to all(be_a(Synonym))
        expect(subject.synonyms.find { |synonym| synonym.word == 'film' }).not_to be_nil
        expect(subject.synonyms.find { |synonym| synonym.word == 'available' }).not_to be_nil
        expect(subject.synonyms.find { |synonym| synonym.word == 'color' }).not_to be_nil
      end
    end

    context 'when not valid' do
      subject { FactoryBot.create :faq, :question => 'a?' }
      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid).and change { Faq.count }.by(0) }
    end
  end

  describe '.find_answer' do
    before(:each) do
      allow(Datamuse).to receive(:words) do |opts|
        case opts[:ml]
        when 'film'
          [{ 'word' => 'movie', 'score' => 56808, 'tags' => ['syn', 'n'] }]
        when 'color'
          [{ 'word' => 'panchromatic', 'score' => 97284,'tags' => ['syn','adj'] }]
        when 'available'
          [{ 'word' => 'availability', 'score' => 97284,'tags' => ['syn','adj'] }]
        when 'panchromatic'
          [{ 'word' => 'color', 'score' => 97284,'tags' => ['syn','adj'] }]
        when 'availability'
          [{ 'word' => 'available', 'score' => 97284,'tags' => ['syn','adj'] }]
        else
          []
        end
      end
    end

    let!(:expected_faq) do
      FactoryBot.create :faq,
                        :question => 'Do you know if this film is available in color?',
                        :answer => 'Yes, but you\'ll never know'
    end

    subject { 
      Faq.find_answer(
        :question => user_question,
        :module_id => expected_faq.module_id,
        :coursework_id => expected_faq.coursework_id,
        :student_id => 'C1529373',
        :lecturer_id => 'C1529372'
      ) 
    }

    context 'when user\'s question < 3 chars' do
      let(:user_question) { 'a?' }
      it { is_expected.to eq('Your question must be greater than or equal to 3 characters.') }
    end
    
    context 'when user\'s question > 140 characters' do
      let(:user_question) do
        <<-HEREDOC
          This question must be greater than 140 characters, it is a reasonable amount of characters 
          that should be used by other applications for the same purposes, don't you think?
        HEREDOC
      end
      it { is_expected.to eq('Your question must be lower than or equal to 140 characters.') }
    end

    context 'when user\'s question doesn\'t end in a question mark' do
      let(:user_question) { 'Do you know what the value of pi is.' }
      it { is_expected.to eq('Your question must end in a question mark.') }
    end

    context 'when user\'s question is valid' do
      context 'and multiple answers are found' do
        let!(:expected_faq2) do
          FactoryBot.create :faq,
                            :question => 'Do you know this film\'s panchromatic availability?',
                            :answer => 'Not 100% sure.'
        end
        let(:user_question) { 'Are you aware of this movie\'s availability in color?' }
        it { is_expected.to include('I have found multiple answers to your question:') }
        it { is_expected.to include(expected_faq.answer) }
        it { is_expected.to include(expected_faq2.answer) }
      end

      context 'and one answer is found' do
        let(:user_question) { 'Are you aware of this movie\'s availability in color?' }
        it { is_expected.to eq(expected_faq.answer) }
      end

      context 'and no answer is found' do
        let(:user_question) { 'This is totally random?' }
        it { is_expected.to eq('I have found no answer to your question, I\'ll ask my supervisor and reply to you by email.') }
        it { expect { subject }.to change { StudentQuestion.count }.by(1) }
      end
    end
  end
end
