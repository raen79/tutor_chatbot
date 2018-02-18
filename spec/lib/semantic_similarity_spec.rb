require 'spec_helper'
require 'semantic_similarity'

RSpec.describe SemanticSimilarity do
  describe 'intialize input parameter' do
    describe 'first question' do
      context 'when is less than 3 characters' do
        subject { FactoryBot.build :semantic_similarity, first_question: 'a?' }
        it { expect{ subject }.to raise_error(ArgumentError, 'first_question must be greater than or equal to 3 characters.') }
      end

      context 'when is greater than 140 characters' do
        let(:first_question) {
          <<-HEREDOC 
            This question must be greater than 140 characters, it is a reasonable amount of characters 
            that should be used by other applications for the same purposes, don't you think?
          HEREDOC
        }
        subject { FactoryBot.build :semantic_similarity, first_question: first_question }
        it { is_expected.to raise_error(ArgumentError, 'first_question must be lower than or equal to 140 characters.') }
      end

      context 'when doesn\'t end in a question mark' do
        subject { FactoryBot.build :semantic_similarity, first_question: 'Do you know what the value of pi is.' }
        it { is_expected.to raise_error(ArgumentError, 'first_question must end in a question mark.') }
      end
    end

    describe 'second question' do
      context 'when is less than 3 characters' do
        subject { FactoryBot.build :semantic_similarity, second_question: 'a?' }
        it { is_expected.to raise_error(ArgumentError, 'second_question must be greater than or equal to 3 characters.') }        
      end

      context 'when is greater than 140 characters' do
        let(:second_question) {
          <<-HEREDOC 
            This question must be greater than 140 characters, it is a reasonable amount of characters 
            that should be used by other applications for the same purposes, don't you think?
          HEREDOC
        }
        subject { FactoryBot.build :semantic_similarity, second_question: second_question }
        it { is_expected.to raise_error(ArgumentError, 'second_question must be lower than or equal to 140 characters.') }
      end

      context 'when doesn\'t end in a question mark' do
        subject { FactoryBot.build :semantic_similarity, second_question: 'Do you know what the value of pi is.' }
        it { is_expected.to raise_error(ArgumentError, 'second_question must end in a question mark.') }
      end
    end
  end

  describe 'instance attribute' do
    describe 'score' do
      let(:semantic_similarity) { FactoryBot.build :semantic_similarity }
      subject { semantic_similarity.score }
      it { is_expected.to be_a(Float) }
      it { is_expected.to be >= 0.0 }
      it { is_expected.to be <= 1.0 }
    end

    describe 'same_question?' do
      context 'when the first question is `Do you know if this film is available in color?`' do
        let(:first_question) { "Do you know if this film is available in color?" }

        context 'and the second question is `Are you aware whether this movie exists not in black and white?`' do
          let(:second_question) { 'Are you aware whether this movie exists not in black and white?' }
          let(:semantic_similarity) { FactoryBot.build :semantic_similarity, first_question: first_question, second_question: second_question }
          subject { semantic_similarity.same_question? }
          it { is_expected.to be true }
        end

        context 'and the second question is `Do you know if this book has been written yet?`' do
          let(:second_question) { 'Do you know if this book has been written yet?' }
          let(:semantic_similarity) { FactoryBot.build :semantic_similarity, first_question: first_question, second_question: second_question }
          subject { semantic_similarity.same_question? }
          it { is_expected.to be true }
        end
      end
    end
  end
end
