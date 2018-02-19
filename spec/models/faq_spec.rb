require 'rails_helper'

RSpec.describe Faq, type: :model do
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
      context 'when < 3 chars' do
        subject { FactoryBot.build :faq, :answer => 'a' }
        it { is_expected.not_to be_valid }
      end
    end

    context 'when valid' do
      subject { FactoryBot.create :faq, :question => 'Do you know if this film is available in color?' }
      it { is_expected.to be_valid }
      it { expect { subject }.to change { Faq.count }.by(1) }
      it { is_expected.to have_attributes(:synonyms => a_collection_containing_exactly('film', 'available', 'color')) }
    end

    context 'when not valid' do
      subject { FactoryBot.create :faq, :question => 'a?' }
      it { is_expected.not_to be_valid }
      it { expect { subject }.not_to change { Faq.count } }
    end
  end

  describe '#similarity_score' do
    let(:faq) { FactoryBot.build :faq, :question => 'Do you know if this film is available in color?' }
    subject { faq.similarity_score(user_question) }

    context 'when user\'s question is valid' do
      let(:user_question) { 'Are you sure that this question is similar?' }
      it { is_expected.to be_a(Float) }
      it { is_expected.to be => 0.0 }
      it { is_expected.to be <= 1.0 }
    end

    context 'when user\'s question < 3 chars' do
      let(:user_question) { 'a?' }
      it { expect{ subject }.to raise_error(ArgumentError, 'question must be greater than or equal to 3 characters.') }
    end
    
    context 'when user\'s question > 140 characters' do
      let(:user_question) do
        <<-HEREDOC
          This question must be greater than 140 characters, it is a reasonable amount of characters 
          that should be used by other applications for the same purposes, don't you think?
        HEREDOC
      end
      it { expect{ subject }.to raise_error(ArgumentError, 'question must be lower than or equal to 140 characters.') }
    end

    context 'when user\'s question doesn\'t end in a question mark' do
      let(:user_question) { 'Do you know what the value of pi is.' }
      it { expect{ subject }.to raise_error(ArgumentError, 'question must end in a question mark.') }
    end
  end

  describe '#same_question?' do
    let(:faq) { FactoryBot.build :faq, :question => 'Do you know if this film is available in color?' }
    subject { faq.same_question?(user_question) }
    let(:similarity_score) { faq.similarity_score(user_question) }

    context 'when .similarity_score >= 0.6' do
      let(:user_question) { 'Are you aware whether this movie does not exist in black and white?' }
      it { expect(similarity_score).to be >= 0.6 }
      it { is_expected.to_be true }
    end

    context 'when .similarity_score < 0.6' do
      let(:user_question) { 'Do you know if this book has been written yet?' }
      it { expect(similarity_score).to be < 0.6 }
      it { is_expected.to_be false }
    end

    context 'when user\'s question < 3 chars' do
      let(:user_question) { 'a?' }
      it { expect{ subject }.to raise_error(ArgumentError, 'question must be greater than or equal to 3 characters.') }
    end
    
    context 'when user\'s question > 140 characters' do
      let(:user_question) do
        <<-HEREDOC
          This question must be greater than 140 characters, it is a reasonable amount of characters 
          that should be used by other applications for the same purposes, don't you think?
        HEREDOC
      end
      it { expect{ subject }.to raise_error(ArgumentError, 'question must be lower than or equal to 140 characters.') }
    end

    context 'when user\'s question doesn\'t end in a question mark' do
      let(:user_question) { 'Do you know what the value of pi is.' }
      it { expect{ subject }.to raise_error(ArgumentError, 'question must end in a question mark.') }
    end
  end

  describe '.find_answer' do
    before(:each) do
      FactoryBot.create :faq,
                        :question => 'Do you know if this book exists?',
                        :answer => 'No'
      FactoryBot.create :faq,
                        :question => 'Do you know if this assignment is mandatory?',
                        :answer => 'No'
    end

    let!(:expected_faq) do
      FactoryBot.create :faq,
                        :question => 'Do you know if this film is available in color?',
                        :answer => 'Yes, but you\'ll never know'
    end

    subject { Faq.find_answer(user_question) }

    context 'when user\'s question is `Are you aware whether this movie does not exist in black and white?`' do
      let(:user_question) { 'Are you aware whether this movie does not exist in black and white?' }
      it { is_expected.to eq(expected_faq.answer) }
    end

    context 'when user\s question is `This is totally unrelated, don\'t you think?`' do
      let(:user_question) { 'This is totally unrelated, don\'t you think?' }
      it { is_expected.to eq('I don\'t know the answer to this question, I\'ll email you back with the answer as soon as possible.') }
    end

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
  end
end
