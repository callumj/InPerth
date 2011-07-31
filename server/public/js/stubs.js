function get_stubs_since(time, category) {
	if (category == null)
		category = "all" 
	if (time == null)
		time = 0 ;
		
	query_param = time == 0 ? '' : '?since=' + time;
	$.getJSON('/stub/' + category +'.json' + query_param, function(contents) {
		newer_obj = null;
	  	for (i = 0; i < contents.data.length; i++)
		{
			//check it already exists
			stub = contents.data[i];
			find = $("#stub_" + stub.key);
			if (!(find.length))
			{
				new_div = $("<div>");
				new_div.attr("id", $("#stub_" + stub.key));
				new_div.attr("class", "stub " + stub.type + "-stub");
				header = $("<h1>");
				header.text(stub.title);
				new_div.appender(header);
				if (newer_obj == null)
				{
					$("#stubs").prepend(new_div);
				}
				else
				{
					new_div.insertAfter(newer_obj);
				}
				newer_obj = new_div;
			}
		}
	});
}

$(function() {
	get_stubs_since(since_time,null);
});