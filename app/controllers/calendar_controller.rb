# calendars are not (yet) a resource in the rails sense of thw word - we
# simply have a url like calendar/index to get the one and only calendar
# this demo serves up.
class CalendarController < ApplicationController
  
  SOURCES = { 
    "arshaw" => "arshaw",
    "abletech" => "AbleTech",
    "buerofuerideen" => "buero-fuer-ideen",
    "jarnokurlin" => "jarnokurlin"
    }
  
  def index
  end
  
  def show
    @calender_type = params[:id]
    # render :template => "calendar/#{ @calender_type }"
  end

end
