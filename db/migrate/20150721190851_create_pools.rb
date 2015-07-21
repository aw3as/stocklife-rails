class CreatePools < ActiveRecord::Migration
  def change
    create_table :pools do |t|

      t.timestamps null: false
    end
  end
end
