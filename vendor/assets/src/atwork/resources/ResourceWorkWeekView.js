
fcViews.resourceWorkWeek = ResourceWorkWeekView;

function ResourceWorkWeekView(element, calendar) {
	var t = this;
	
	// exports
	t.render = render;
	
	// imports
	ResourceView.call(t, element, calendar, 'resourceWorkWeek');
	var opt = t.opt;
	var renderResourcesDaysView = t.renderResourcesDaysView;
	var formatDates = calendar.formatDates;
	
	function render(date, delta) {
		if (delta) {
			addDays(date, delta * 7);
		}
		var start = addDays(cloneDate(date), -((date.getDay() - opt('firstDay') + 7) % 7));
		var end = addDays(cloneDate(start), 7);
		var visStart = cloneDate(start);
		var visEnd = cloneDate(end);
		var weekends = false;
		skipWeekend(visStart);
		skipWeekend(visEnd, -1, true);
		t.title = formatDates(
			visStart,
			addDays(cloneDate(visEnd), -1),
			opt('titleFormat')
		);
		t.start = start;
		t.end = end;
		t.visStart = visStart;
		t.visEnd = visEnd;
		renderResourcesDaysView(5);
	}
	

}
