class AddAuthToFaq < ActiveRecord::Migration[5.1]
  def change
    add_column :faqs, :module_id, :string
    add_column :faqs, :lecturer_id, :string
  end
end
