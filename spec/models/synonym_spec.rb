require 'rails_helper'

RSpec.describe Synonym, type: :model do
  describe 'Validation' do
    describe '#word' do
      subject { FactoryBot.build :synonym, :word => word }

      context 'when < 3 chars' do
        let(:word) { 'an' }
        it { is_expected.not_to be_valid }
      end
    end

    describe '#words' do
      subject { FactoryBot.build :synonym, :words => words }

      context 'when not an array' do
        let(:words) { 23 }
        it { is_expected.not_to be_valid }
      end

      context 'when an item of the array is not a string' do
        let(:words) { [12, 'hello'] }
        it { is_expected.not_to be_valid }
      end
    end

    context 'when valid' do
      subject { FactoryBot.create :synonym }
      it { expect { subject }.to change { Synonym.count }.by(1) }
    end

    context 'when not valid' do
      subject { FactoryBot.create :faq, :word => 'an' }
      it { expect { subject }.to raise_error.and change { Synonym.count }.by(0) }
    end
  end

  describe '.search' do
    subject { Synonym.search('Do you know if this film is available in color?') }

    context 'when user\'s question < 3 chars' do
      let(:user_question) { 'a?' }
      it { is_expected.to eq('Your question must be greater than or equal to 3 characters.') }
    end
  end
end
