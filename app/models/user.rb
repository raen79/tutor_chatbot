class User
  attr_accessor :first_name, :last_name, :email, :lecturer_id

  def initialize(first_name: nil, last_name: nil, email: nil, lecturer_id: nil)
    @first_name = first_name
    @last_name = last_name
    @email = email
    @lecturer_id = lecturer_id
  end

  def self.find_by(lecturer_id: nil, email: nil, student_id: nil)
    if [lecturer_id, student_id].include? 'BLANK'
      raise ActiveRecord::RecordNotFound
    elsif lecturer_id.blank? && student_id.blank? && email.blank?
      raise ActiveRecord::RecordNotFound
    else
      User.new(
        :first_name => 'Eran',
        :last_name => 'Peer',
        :email => 'peere@cardiff.ac.uk',
        :lecturer_id => 'C1529373'
      )
    end
  end
end