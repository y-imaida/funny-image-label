class CreateReservedImages < ActiveRecord::Migration
  def change
    create_table :reserved_images do |t|
      t.string :image

      t.timestamps null: false
    end
  end
end
