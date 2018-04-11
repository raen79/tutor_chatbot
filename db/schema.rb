# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180411212223) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "faqs", force: :cascade do |t|
    t.string "question"
    t.string "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "module_id"
    t.string "lecturer_id"
    t.string "coursework_id"
  end

  create_table "faqs_synonyms", id: false, force: :cascade do |t|
    t.bigint "synonym_id", null: false
    t.bigint "faq_id", null: false
    t.index ["faq_id", "synonym_id"], name: "index_faqs_synonyms_on_faq_id_and_synonym_id"
    t.index ["synonym_id", "faq_id"], name: "index_faqs_synonyms_on_synonym_id_and_faq_id"
  end

  create_table "student_questions", force: :cascade do |t|
    t.string "text"
    t.string "coursework_id"
    t.string "lecturer_id"
    t.string "module_id"
    t.string "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "synonyms", force: :cascade do |t|
    t.string "word"
    t.string "words", default: [], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
