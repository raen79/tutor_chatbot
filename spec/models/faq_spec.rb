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
      subject { FactoryBot.build :faq, :question => question }

      context 'when < 3 chars' do
        let(:question) { 'a?' }
        it { is_expected.not_to be_valid }
      end
      
      context 'when > 140 characters' do
        let(:question) do
          <<-HEREDOC 
            This question must be greater than 140 characters, it is a reasonable amount of characters 
            that should be used by other applications for the same purposes, don't you think?
          HEREDOC
        end
        it { is_expected.not_to be_valid }
      end

      context 'when doesn\'t end in a question mark' do
        let(:question) { 'Do you know what the value of pi is.' }
        it { is_expected.not_to be_valid }
      end
    end
    
    describe '#answer' do
      subject { FactoryBot.build :faq, :answer => answer }

      context 'when < 3 chars' do
        let(:answer) { 'a' }
        it { is_expected.not_to be_valid }
      end
    end

    context 'when valid' do
      subject { FactoryBot.create :faq, :question => 'Do you know if this film is available in color?' }
      it { expect { subject }.to change { Faq.count }.by(1) }
      it 'should have an association `synonyms` with apporpriate instances of Synonym' do
        is_expected.to all(be_a(Synonym))
        expect(subject.synonyms).to all(be_a(Synonym))
        expect(subject.synonyms.find { |synonym| synonym.word == 'film' }).not_to be_nil
        expect(subject.synonyms.find { |synonym| synonym.word == 'available' }).not_to be_nil
        expect(subject.synonyms.find { |synonym| synonym.word == 'color' }).not_to be_nil
        expect(subject.synonyms.find { |synonym| synonym.word == 'know' }).not_to be_nil
      end
    end

    context 'when not valid' do
      subject { FactoryBot.create :faq, :question => 'a?' }
      it { expect { subject }.to raise_error(ArgumentError).and change { Faq.count }.by(0) }
    end
  end

  describe '.find_answer' do
    let!(:expected_faq) do
      FactoryBot.create :faq,
                        :question => 'Do you know if this film is available in color?',
                        :answer => 'Yes, but you\'ll never know'
    end

    subject { Faq.find_answer(user_question) }

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
      let(:user_question) { 'Do you know if this film is available in color?' }
      it { is_expected.to eq('Yes, but you\'ll never know') }
    end
  end
end
