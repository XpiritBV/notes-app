class CreateNotes < ActiveRecord::Migration[6.1]
  def change
    create_table :notes do |n|
      n.string    :title
      n.string :body
      n.timestamps
    end
  end
end
