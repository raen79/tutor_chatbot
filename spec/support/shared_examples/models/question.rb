RSpec.shared_examples 'question' do |model, attribute|
  subject { FactoryBot.build model, attribute => question }

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