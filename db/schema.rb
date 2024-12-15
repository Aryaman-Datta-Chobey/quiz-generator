# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_12_15_044913) do
  create_table "attempted_questions", force: :cascade do |t|
    t.integer "attempt_id", null: false
    t.integer "question_id"
    t.integer "index"
    t.string "user_answer"
    t.boolean "correct"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "archived_content"
    t.string "archived_correct_answer"
    t.text "archived_options"
    t.index ["attempt_id"], name: "index_attempted_questions_on_attempt_id"
    t.index ["question_id"], name: "index_attempted_questions_on_question_id"
  end

  create_table "attempts", force: :cascade do |t|
    t.integer "quiz_id", null: false
    t.date "attempt_date"
    t.integer "time_taken"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "archived_topic"
    t.integer "archived_difficulty"
    t.integer "archived_study_duration"
    t.integer "archived_detail_level"
    t.index ["quiz_id"], name: "index_attempts_on_quiz_id"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "quiz_id", null: false
    t.text "content"
    t.text "options"
    t.string "correct_answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.string "topic"
    t.integer "difficulty"
    t.integer "study_duration"
    t.integer "detail_level"
    t.integer "number_of_questions"
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["user_id"], name: "index_quizzes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "attempted_questions", "attempts"
  add_foreign_key "attempted_questions", "questions", on_delete: :nullify
  add_foreign_key "attempts", "quizzes"
  add_foreign_key "questions", "quizzes"
  add_foreign_key "quizzes", "users"
end
