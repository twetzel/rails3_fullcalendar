## Rails3 fullcalendar example

This is an example application showing how to use the JQuery FullCalendar plugin with Rails3, following RESTful rails practices as closely as possible, and forgoing 'cleverness' for clarity.
[Homepage](http://arshaw.com/fullcalendar/) | [DOKU](http://arshaw.com/fullcalendar/docs/) | [Source](https://github.com/arshaw/fullcalendar)

This app compares 4 Versions of fullcallender to show how they can handle resources (people).

#### Usage:

    git clone git://github.com/twetzel/rails3_fullcalendar.git
    cd rails3_fullcalendar/
    bundle install
    bundle exec rake db:migrate
    bundle exec rake db:seed .. if you want sample data
    rails s

***
Fullcalendar is a great ajaxy calendar... there are several examples on that page, and downloadable with the project.  Integration with rails is not overly complicated, but a sample project that can be dissected is really helpful in getting all the moving parts worked out.  This project will eventually include detailed instructions of how it came together, and I might even record a screencast on it.  Until then, notable things:

**This app uses:**
* Rails 3.2.8 (but every version above 3.1 should work fine!)
* jquery-rails & jquery-ui-rails .. (as gems)
* coffeescript version off [rails3_fullcalendar](https://github.com/bokmann/rails3_fullcalendar) start script plus create action
* different fullCalender sources are bundled with sprockets

**Several fullCalendar sources included in *vendor/assets/src*:**
* [arshaw](https://github.com/arshaw/fullcalendar) .. the original
* [AbleTech](https://github.com/arshaw/fullcalendar) .. includes resources & resourceDay-view
* [buero-fuer-ideen](https://github.com/buero-fuer-ideen/fullcalendar) .. includes resources & resourceDay-view
* [jarnokurlin](https://github.com/jarnokurlin/fullcalendar) .. includes resources & several resource-views

the src-path is softlinked in vendor/assets/javascripts and vendor/assets/stylesheets .. so you can use it directly.

for more details about the diffrent versions, please have a look at [issue 490](http://code.google.com/p/fullcalendar/issues/detail?id=490)

***
In order to simplify communication between the fullcalendar and the rails application that is actually serving up the events to put on the calendar, The app is using the [jquery.REST plugin](https://github.com/lyconic/jquery.rest) .. see this [post](http://lyconic.com/blog/2010/08/03/dry-up-your-ajax-code-with-the-jquery-rest-plugin)


This project does not currently support recurring events - doing so would overcomplicate the simple examples I want to make here.


There will eventually be branches that support recurring events as well as multiple calendars (and displaying multiple calendar events on the same fullcalendar in different colors, now that fullcalendar 2.5 supports that)

***
### More:
This is just an updated (and slightly improved) version of [David Bock`s rails3_fullcalendar](https://github.com/bokmann/rails3_fullcalendar).
His project was inspired by an earlier attempt to do the same thing.  https://github.com/vinsol/fullcalendar_rails demonstrates an older calendar integrations with Rails2; however it doesn't live up to Rails' RESTful ideals, and complicates the example with other uses of ajax and a more complex domain model to support recurring events.  It is still a useful project, and kudos to vinsol for sharing it; it definitely made this Rails3 version easier

Some JS-Code is addopted from [Victor Tatai´s fork](https://github.com/vtatai/rails3_fullcalendar).