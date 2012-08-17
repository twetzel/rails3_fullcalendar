# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
puts("create some people ..")
bg_colors = %w(red blue orange green yellow)
tx_colors = %w(light light dark dark dark)
['Joe Bloggs', 'Alan Black', 'Bob Orange', 'Paul Green', 'Jane Yellow'].each_with_index do |person,index|
  Person.create!(
                      :sex => index == 4 ? :female : :male,
                      :name => person.split(' ')[1],
                      :first_name => person.split(' ')[0],
                      :bg_color => Event::BG_COLORS[ bg_colors[index] ],
                      :txt_color => Event::TXT_COLORS[ tx_colors[index] ]
                 )
end
puts("create some events ..")
%w(Lorem ipsum dolor sit amet consectetur adipisicing elit sed do eiusmod tempor incididunt ut labore et dolore magna aliqua Ut enim ad minim veniam quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur Excepteur sint occaecat cupidatat non proident sunt in culpa qui officia deserunt mollit anim id est laborum).each_with_index do |title,index|
  if index.modulo(2) == 0
    date = Time.now - rand(300).hours
  else
    date = Time.now + rand(300).hours
  end
  person = rand(4) + 1
  if rand(3) == 2
    Event.create!( :title => title, :starts_at => date, :ends_at => date + 2.hours, :person_id => person, :all_day => true )
  else
    Event.create!( :title => title, :starts_at => date, :ends_at => date + 2.hours, :person_id => person )
  end
end
puts("Ready !!! ... start with: rails s")