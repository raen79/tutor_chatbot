require 'rails_helper'
include API

RSpec.describe User do
  let(:jwt) { jwt_token(attributes) }
  let(:user) { User.find_by(:jwt => jwt) }

  before(:each) do
    allow(HTTParty).to receive(:get).and_return(
      double(HTTParty::Response, :body => {
        :id => 1,
        :email => 'peere@cardiff.ac.uk',
        :student_id => 'C1529373',
        :lecturer_id => 'C1529373'
      }.to_json)
    )
  end

  describe '#initialize' do
    it 'should not be called publicly' do
      expect { User.new }.to raise_error(NoMethodError)
    end
  end

  describe '.find_by' do
    subject { User.find_by(params) }

    context 'when jwt is filled' do
      let(:attributes) { {
        :email => 'eran.peer79@gmail.com',
        :lecturer_id => 'C1529344',
        :student_id => 'C452313562'
      } }
      let(:params) { { :jwt => jwt } }
      it { is_expected.to be_a(User) }
    end

    context 'when lecturer_id is filled' do
      let(:attributes) { user_attributes }
      let(:params) { { :lecturer_id => 'C1523245' } }
      it { is_expected.to be_a(User) }
    end

    context 'when student_id is filled' do
      let(:attributes) { user_attributes }
      let(:params) { { :student_id => 'C1523245' } }
      it { is_expected.to be_a(User) }
    end

    context 'when email is filled' do
      let(:attributes) { user_attributes }
      let(:params) { { :email => 'peere@cardiff.ac.uk' } }
      it { is_expected.to be_a(User) }
    end
  end

  describe '#lecturer?' do
    subject { user.lecturer? }
    
    context 'when user is not a lecturer' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return(
          double(HTTParty::Response, :body => {
            :id => 1,
            :email => 'peere@cardiff.ac.uk',
            :student_id => 'C1529373',
            :lecturer_id => nil
          }.to_json)
        )
      end

      let(:attributes) { user_attributes.merge({:lecturer_id => nil}) }
      it { is_expected.to be_falsy }
    end

    context 'when user is a lecturer' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return(
          double(HTTParty::Response, :body => {
            :id => 1,
            :email => 'peere@cardiff.ac.uk',
            :student_id => nil,
            :lecturer_id => 'C1529373'
          }.to_json)
        )
      end

      let(:attributes) { user_attributes.merge({:lecturer_id => 'C1529373'}) }
      it { is_expected.to be_truthy }
    end
  end

  describe '#student?' do
    subject { user.student? }
    
    context 'when user is not a student' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return(
          double(HTTParty::Response, :body => {
            :id => 1,
            :email => 'peere@cardiff.ac.uk',
            :lecturer_id => 'C1529373',
            :student_id => nil
          }.to_json)
        )
      end

      let(:attributes) { user_attributes.merge({:student_id => nil}) }
      it { is_expected.to be_falsy }
    end

    context 'when user is a student' do
      before(:each) do
        allow(HTTParty).to receive(:get).and_return(
          double(HTTParty::Response, :body => {
            :id => 1,
            :email => 'peere@cardiff.ac.uk',
            :student_id => 'C1529373',
            :lecturer_id => nil
          }.to_json)
        )
      end

      let(:attributes) { user_attributes.merge({:student_id => 'C1529373'}) }
      it { is_expected.to be_truthy }
    end
  end

  describe '#faqs' do
    before { allow(Datamuse).to receive(:words).and_return([]) }

    let(:attributes) { user_attributes }
    let!(:faq) { FactoryBot.create :faq, :lecturer_id => user.lecturer_id }
    let!(:wrong_faq) { FactoryBot.create :faq, :lecturer_id => user.lecturer_id + '41', :question => 'New?' }

    subject { user.faqs }
    
    it { is_expected.to include(faq) }
    it { is_expected.not_to include(wrong_faq) }
  end

  describe '#attributes' do
    before(:each) do
      allow(HTTParty).to receive(:get).and_return(
        double(HTTParty::Response, :body => user_attributes.to_json)
      )
    end
    let(:attributes) { user_attributes }
    subject { user.attributes }
    it { is_expected.to include(user_attributes) }
  end
end