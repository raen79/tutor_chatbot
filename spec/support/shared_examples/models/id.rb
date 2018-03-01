RSpec.shared_examples 'id' do |model, attribute|
  subject { FactoryBot.build model, :"#{attribute}_id" => id }

  context 'when includes lowercase letters' do
    let(:id) { 'cm14523' }
    it { is_expected.to be_valid.and have_attributes(:"#{attribute}_id" => 'CM14523') }
  end

  context 'when not present' do
    let(:id) { nil }
    it { is_expected.not_to be_valid }
  end
end
