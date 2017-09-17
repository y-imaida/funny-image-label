class CreateImageLabels < ActiveRecord::Migration
  def change
    create_table :image_labels do |t|
      t.references :topic, index: true, foreign_key: true
      t.string :api
      t.string :label
      t.float :score
      t.boolean :selected, default: false

      t.timestamps null: false
    end
  end
end
