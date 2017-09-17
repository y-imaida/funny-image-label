class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :image
      t.string :content

      t.timestamps null: false
    end
  end
end
