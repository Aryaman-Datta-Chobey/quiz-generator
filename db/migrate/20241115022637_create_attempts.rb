class CreateAttempts < ActiveRecord::Migration[7.2]
  def change
    create_table :attempts do |t|
      t.references :quiz, null: false, foreign_key: true
      t.date :attempt_date
      t.integer :time_taken
      t.integer :score

      t.timestamps
    end
  end
end
