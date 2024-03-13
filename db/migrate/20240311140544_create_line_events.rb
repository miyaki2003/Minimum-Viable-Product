class CreateLineEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :line_events do |t|
      t.string :message, null: false
      t.datetime :reminder_time, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
