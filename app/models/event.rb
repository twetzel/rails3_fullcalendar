class Event < ActiveRecord::Base
  
  BG_COLORS = { "blue" => "#06578f", "red" => "#e8173e", "orange" => "#ffa54c", "gray" => "#d5d5d5", "green" => "#73f435", "yellow" => "#fff16a" }
  TXT_COLORS = { "dark" => "#333", "smooth" => "#999", "light" => "#ddd" }
  
  attr_accessible :title, :starts_at, :ends_at, :all_day, :description, :person_id
  
  belongs_to :person
    
  scope :before, lambda {|end_time| {:conditions => ["ends_at < ?", Event.format_date(end_time)] }}
  scope :after, lambda {|start_time| {:conditions => ["starts_at > ?", Event.format_date(start_time)] }}
  
  validates_presence_of :title, :starts_at
  
  # need to override the json view to return what full_calendar is expecting.
  # http://arshaw.com/fullcalendar/docs/event_data/Event_Object/
  def as_json(options = {})
    {
      :id => self.id,
      :title => self.title,
      :description => self.description || "",
      :start => starts_at.rfc822,
      :end => ends_at && !ends_at.blank? ? ends_at.rfc822 : '',
      :allDay => self.all_day,
      :color => self.person ? self.person.bg_color : "#f3f2f2",
      :borderColor => self.person ? self.person.bg_color : "#ddd",
      :textColor => self.person ? self.person.txt_color : "#666",
      :className => "event #{'unsinged' unless self.person}",
      :recurring => false,
      :resource => self.person ? self.person.id : "",
      :resourceId => self.person ? self.person.id : "",
      :url => Rails.application.routes.url_helpers.event_path(id)
    }
    
  end
  
  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end
end
