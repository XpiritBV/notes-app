class AddNoteToNotebook < ActiveRecord::Migration[6.1]
  def change
    add_column :notes, :notebook_id, :integer
  end
end
