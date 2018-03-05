class User
  attr_reader :first_name, :last_name, :email, :lecturer_id, :student_id

  @public_key = OpenSSL::PKey::RSA.new(ENV['RSA_PUBLIC_KEY'].gsub('\n', "\n"))

  def initialize(first_name: nil, last_name: nil, email: nil, lecturer_id: nil, student_id: nil)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @lecturer_id = lecturer_id
    @student_id = student_id
  end

  def faqs
    Faq.where(:lecturer_id => @lecturer_id)
  end

  def student?
    !@student_id.blank?
  end

  def lecturer?
    !@lecturer_id.blank?
  end

  def attributes
    {
      :first_name => first_name,
      :last_name => last_name,
      :email => email,
      :lecturer_id => lecturer_id,
      :student_id => student_id
    }
  end

  class << self
    private :new

    def find_by(lecturer_id: nil, email: nil, student_id: nil, jwt: nil)
      if !jwt.blank?
        find_by_jwt(jwt)
      elsif !student_id.blank?
        find_by_student(student_id)
      elsif !lecturer_id.blank?
        find_by_lecturer(lecturer_id)
      elsif !email.blank?
        find_by_email(email)
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    private

      def find_by_lecturer(lecturer_id)
        example_user
      end

      def find_by_student(student_id)
        example_user
      end

      def find_by_jwt(jwt)
        decoded_jwt = JWT.decode jwt, @public_key, true, { :algorithm => 'RS512' }
        user_attributes = decoded_jwt[0].symbolize_keys
        new(user_attributes)
      end

      def find_by_email(email)
        example_user
      end

      def example_user
        new(
          :first_name => 'Eran',
          :last_name => 'Peer',
          :email => 'peere@cardiff.ac.uk',
          :lecturer_id => 'C1529373',
          :student_id => nil
        )
      end
  end
end