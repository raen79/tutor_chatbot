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
        let(:words) { [2, 'hello'] }
        it { is_expected.not_to be_valid }
      end
    end

    context 'when valid' do
      subject { FactoryBot.create :synonym }
      it { expect { subject }.to change { Synonym.count }.by(1) }
    end

    context 'when not valid' do
      subject { FactoryBot.create :synonym, :word => 'an' }
      it { expect { subject }.to raise_error(ActiveRecord::RecordInvalid).and change { Synonym.count }.by(0) }
    end
  end

  describe '.in_sentence' do
    before(:each) do
      allow(Datamuse).to receive(:words) do |opts|
        case opts[:ml]
        when 'film'
          [{ 'word' => 'movie', 'score' => 56808, 'tags' => ['syn', 'n'] }]
        when 'availability'
          [{ 'word' => 'accessible', 'score' => 37788, 'tags' => ['syn', 'adj'] }]
        when 'color'
          [{ 'word' => 'panchromatic', 'score' => 97284,'tags' => ['syn','adj'] }]
        else
          []
        end
      end
    end

    subject { Synonym.in_sentence(sentence) }

    context 'when sentence < 3 chars' do
      let(:sentence) { 'a?' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when sentence contains no nouns or adjectives' do
      let(:sentence) { 'This not working' }
      it { is_expected.to be_empty }
    end

    context 'when sentence is valid' do
      let(:sentence) { 'Do you know this film\'s availability in color?' }
      
      it 'should return an array of appropriate instances of Synonym' do
        is_expected.to all(be_a(Synonym))
        expect(subject.find { |synonym| synonym.word == 'film' && synonym.words == ['movie'] }).not_to be_nil
        expect(subject.find { |synonym| synonym.word == 'availability' && synonym.words == ['accessible'] }).not_to be_nil
        expect(subject.find { |synonym| synonym.word == 'color' && synonym.words == ['panchromatic'] }).not_to be_nil
      end
    end
  end
end
