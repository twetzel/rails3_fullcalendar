class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      
      t.string :sex
      t.string :name
      t.string :first_name
      t.string :bg_color
      t.string :txt_color

      t.timestamps
    end
  end
end
