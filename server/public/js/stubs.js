function get_stubs_since(time, category) {
	if (category == null)
		category = "all" 
	if (time == null)
		time = 0 ;
		
	query_param = time == 0 ? '' : '?since=' + time;
	results = []
	$.getJSON('/stub/' + category +'.json' + query_param, function(contents) {
	  	results = contents.data;
	});
	return results;
}

$(function() {
	get_stubs_since(null,null);
});