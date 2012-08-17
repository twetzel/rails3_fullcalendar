class Person < ActiveRecord::Base
  
  GENDERS = %w(male female)
  
  attr_accessible :bg_color, :first_name, :name, :sex, :txt_color
  
  has_many :events
  
  def full_name
    da_name = []
    if self.sex && !self.sex.blank? && 3 == 4
      gender = self.sex == "male" ? "Mr." : "Ms."
      da_name << gender
    end
    da_name << self.first_name.titleize if self.first_name && !self.first_name.blank?
    da_name << self.name.titleize if self.name && !self.name.blank?
    da_name.join(' ')
  end
  
  def as_json(options = {})
    {
      :id => self.id,
      :name => self.full_name,
      :color => self.bg_color,
      :textColor => self.txt_color
    }
    
  end
  
end
