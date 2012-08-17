class CreateEvents < ActiveRecord::Migration
  def change
    
    create_table :events do |t|
      t.string    :title
      t.datetime  :starts_at
      t.datetime  :ends_at
      t.boolean   :all_day
      # more fields:
      t.text      :description
      t.string    :bg_color
      t.string    :txt_color
      t.integer   :person_id
      t.timestamps
    end
    
    add_index :events, :starts_at
    add_index :events, :ends_at
    add_index :events, :person_id
    
  end
end
