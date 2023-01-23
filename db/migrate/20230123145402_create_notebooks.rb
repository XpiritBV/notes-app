class CreateNotebooks < ActiveRecord::Migration[6.1]
  def change
    create_table :notebooks do |n|
      n.string :name
      n.timestamps
    end
  end
end
