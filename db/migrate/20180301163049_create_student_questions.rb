class CreateStudentQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :student_questions do |t|
      t.string :text
      t.string :coursework_id
      t.string :lecturer_id
      t.string :module_id
      t.string :student_id

      t.timestamps
    end
  end
end
