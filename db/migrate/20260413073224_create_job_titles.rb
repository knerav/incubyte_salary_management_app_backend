class CreateJobTitles < ActiveRecord::Migration[8.1]
  def change
    create_table :job_titles do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :job_titles, :name, unique: true
  end
end
