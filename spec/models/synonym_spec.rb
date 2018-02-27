require 'rails_helper'
require 'rubymuse'

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
      subject { FactoryBot.create :synonym, :word => 'an' }
      it { expect { subject }.to raise_error(ArgumentError).and change { Synonym.count }.by(0) }
    end
  end

  describe '.search' do
    before(:each) do
      allow(Datamuse)
        .to receive(:words)
        .with(:ml => 'film')
        .and_return([{'word' => 'movie','score' => 56808,'tags' => ['syn', 'n']}])

      allow(Datamuse)
        .to receive(:words)
        .with(:ml => 'availability')
        .and_return([{'word' => 'accessible', 'score' => 37788, 'tags' => ['syn', 'adj']}])

      allow(Datamuse)
        .to receive(:words)
        .with(:ml => 'color')
        .and_return([{'word' => 'panchromatic','score' => 97284,'tags' => ['syn','adj']}])
    end

    subject { Synonym.search(sentence) }

    context 'when sentence < 3 chars' do
      let(:sentence) { 'a?' }
      it { expect { subject }.to raise_error(ArgumentError) }
    end

    context 'when sentence contains no nouns or adjectives' do
      let(:sentence) { 'This not working' }
      it { is_expected.to eq([]) }
    end

    context 'when sentence is valid' do
      let(:sentence) { 'Do you know this film\'s availablity in color?' }
      let(:synonyms_of_film) { FactoryBot.build :synonym, :word => 'film', :words => ['movie'] }
      let(:synonyms_of_availability) { FactoryBot.build :synonym, :word => 'availability', :words => ['accessible'] }
      let(:synonyms_of_color) { FactoryBot.build :synonym, :word => 'color', :words => 'panchromatic' }
      it { is_expected.to contain_exactly(synonyms_of_film, synonyms_of_color, synonyms_of_availability) }
    end
  end
end
