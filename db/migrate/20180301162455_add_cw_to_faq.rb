class AddCwToFaq < ActiveRecord::Migration[5.1]
  def change
    add_column :faqs, :coursework_id, :string
  end
end
