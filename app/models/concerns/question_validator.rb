class QuestionValidator < ActiveModel::Validator
  def validate(record)
    attr_name = options[:attributes].first

    unless attr_name.blank? || record[attr_name].blank?
      must_end_with_question_mark(record, attr_name)
      validate_length(record, attr_name)
    end
  end
  
  private
    def must_end_with_question_mark(record, attr_name)
      unless record[attr_name].last == '?'
        record.errors.add(attr_name, 'must end with question mark')
      end
    end

    def validate_length(record, attr_name)
      if record[attr_name].length < 3
        record.errors.add(attr_name, 'must be greater or equal to 3 chars')
      elsif record[attr_name].length > 140
        record.errors.add(attr_name, 'must be less than or equal to 140 chars')
      end
    end
end