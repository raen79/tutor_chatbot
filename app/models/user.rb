class User
  attr_reader :first_name, :last_name, :email, :lecturer_id, :student_id

  def initialize(first_name: nil, last_name: nil, email: nil, lecturer_id: nil, student_id: nil)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @lecturer_id = lecturer_id
    @student_id = student_id
  end

  def self.find_by(lecturer_id: nil, email: nil, student_id: nil, jwt: nil)
    if !jwt.blank?
      find_by_jwt(jwt)
    elsif !student_id.blank?
      find_by_student(student_id)
    elsif !lecturer_id.blank?
      find_by_lecturer(lecturer_id)
    elsif !email_id.blank?
      find_by_email(email)
    else
      raise ActiveRecord::RecordNotFound
    end
  end

  private

    def self.find_by_lecturer(lecturer_id)
      example_user
    end

    def self.find_by_student(student_id)
      example_user
    end

    def self.find_by_jwt(student_id)
      example_user
    end

    def self.find_by_email(email)
      example_user
    end

    def self.example_user
      User.new(
        :first_name => 'Eran',
        :last_name => 'Peer',
        :email => 'peere@cardiff.ac.uk',
        :lecturer_id => 'C1529373',
        :student_id => 'C1529373'
      )
    end
end