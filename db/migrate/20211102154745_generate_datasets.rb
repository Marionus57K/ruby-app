class GenerateDatasets < ActiveRecord::Migration[6.1]
  def change
    create_table :datasets do |t|
      t.string :country
      t.string :year
      t.string :sex
      t.string :age_group
      t.string :value
      t.date :date

      t.timestamps
    end
  end
end
