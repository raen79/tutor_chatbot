class CreateJoinTable < ActiveRecord::Migration[5.1]
  def change
    create_join_table :synonyms, :faqs do |t|
      t.index [:synonym_id, :faq_id]
      t.index [:faq_id, :synonym_id]
    end
  end
end
