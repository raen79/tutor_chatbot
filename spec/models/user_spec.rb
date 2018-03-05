require 'rails_helper'
include API

RSpec.describe User do
  describe '#initialize' do
    it 'should not be called publicly' do
      expect { User.new }.to raise_error(NoMethodError)
    end
  end

  describe '.find_by' do
    subject { User.find_by(params) }

    context 'when jwt is filled' do
      let(:user_attributes) { {
        :first_name => 'A Name',
        :last_name => 'Another Name',
        :email => 'eran.peer79@gmail.com',
        :lecturer_id => 'C1529344',
        :student_id => 'C452313562'
      } }
      let(:jwt) { jwt_token(user_attributes) }
      let(:params) { { :jwt => jwt } }

      it { is_expected.to be_a(User) }
      it { is_expected.to have_attributes(user_attributes) }
    end

    context 'when lecturer_id is filled' do
      let(:params) { { :lecturer_id => 'C1523245' } }
      it { is_expected.to be_a(User) }
    end

    context 'when student_id is filled' do
      let(:params) { { :student_id => 'C1523245' } }
      it { is_expected.to be_a(User) }
    end

    context 'when email is filled' do
      let(:params) { { :email => 'peere@cardiff.ac.uk' } }
      it { is_expected.to be_a(User) }
    end
  end
end