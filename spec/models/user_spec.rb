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

  describe '#lecturer?' do
    let(:jwt) { jwt_token(attributes) }
    let(:user) { User.find_by(:jwt => jwt) }
    subject { user.lecturer? }
    
    context 'when user is not a lecturer' do
      let(:attributes) { user_attributes.merge({:lecturer_id => nil}) }
      it { is_expected.to be_falsy }
    end

    context 'when user is a lecturer' do
      let(:attributes) { user_attributes.merge({:lecturer_id => 'C1529373'}) }
      it { is_expected.to be_truthy }
    end
  end

  describe '#student?' do
    let(:jwt) { jwt_token(attributes) }
    let(:user) { User.find_by(:jwt => jwt) }
    subject { user.student? }
    
    context 'when user is not a student' do
      let(:attributes) { user_attributes.merge({:student_id => nil}) }
      it { is_expected.to be_falsy }
    end

    context 'when user is a student' do
      let(:attributes) { user_attributes.merge({:student_id => 'C1529373'}) }
      it { is_expected.to be_truthy }
    end
  end
end