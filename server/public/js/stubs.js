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
				new_div.attr("id", "#stub_" + new String(stub.key));
				new_div.attr("class", "stub " + new String(stub.kind) + "-stub");
				header = $("<h1>");
				header.html("<a href=\"" + stub.uri +"\">" + stub.title + "</a>");
				
				details1 = $("<p>");
				details1.attr("class", "description");
				details1.text(stub.desc);
				
				details2 = $("<p>");
				details2.attr("class", "details");
				details2.text(stub.time);
				
				details3 = $("<p>");
				details3.attr("class", "details");
				details3.text(stub.provider.title);
				
				new_div.append(header);
				new_div.append(details1);
				new_div.append(details2);
				new_div.append(details3);
				
				if (stub.place != null)
				{
					details4 = $("<p>");
					details4.attr("class", "details important");
					details4.text(stub.place.title);
					new_div.append(details4);
				}
				
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