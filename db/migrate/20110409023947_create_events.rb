class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :title
      
      t.datetime :starts_at
      t.datetime :ends_at
      
      t.boolean :all_day
      
      # more fields:
      t.text    :description
      t.string  :bg_color
      t.string  :text_color
      
      t.integer :peron_id

      t.timestamps
    end
    
    add_index :events, :starts_at
    add_index :events, :ends_at
    add_index :events, :peron_id
    
  end

  def self.down
    remove_index :events, :starts_at
    remove_index :events, :ends_at
    remove_index :events, :peron_id
    drop_table :events
  end
end
