require 'rails_helper'

RSpec.describe Synonym, type: :model do
  describe 'Validation' do
    describe '#word' do
      subject { FactoryBot.build :synonym, :word => word }

      context 'when < 3 chars' do
        let(:word) { 'an' }
        it { is_expected.not_to be_valid }
      end

      context 'when not included' do
        let(:word) { nil }
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

      context 'when not included' do
        let(:words) { nil }
        it { is_expected.not_to be_valid }
      end
    end

    context 'when valid' do
      subject { FactoryBot.create :synonym }
      it { is_expected.to be_valid }
      it { expect { subject }.to change { Synonym.count }.by(1) }
    end

    context 'when not valid' do
      subject { FactoryBot.create :faq, :word => 'an' }
      it { is_expected.not_to be_valid }
      it { expect { subject }.not_to change { Synonym.count } }
    end
  end
end
