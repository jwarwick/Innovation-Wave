$(document).ready(function() 
{
	// // Enable pusher logging - don't include this in production
	// Pusher.log = function() {
	// 	if (window.console) window.console.log.apply(window.console, arguments);
	// };
	// 
	// // Flash fallback logging - don't include this in production
	// WEB_SOCKET_DEBUG = true;



	var pusher = new Pusher('3fcce2741943f98bf5f6');

	var projID = $("body").attr("data-project-id");
	if (projID) {
		// Project page
		var projLogChannel = pusher.subscribe('project_log_channel_' + projID);
		projLogChannel.bind('new', function(data) {
			addNewProjectLogMessage(data);
		});

	}
	else
	{
		// Main Index page
		var updateChannel = pusher.subscribe('update_channel');
		updateChannel.bind('update', function(data) {
			// location.reload();
		});
	
		var logChannel = pusher.subscribe('log_channel');
		logChannel.bind('new', function(data) {
			addNewLogMessage(data);
		});
	}
	
	// loadLogMessages(1, 10);
	
	$("#logDeleteButton").button().click(function(e) 
	{
		e.preventDefault();
		var projID = $(this).attr("data-project-id");
		
		$.ajax({
			type: "DELETE",
			url: "/projects/" + projID + "/logs",
			success: function(msg){
				location.reload();
				}
			});
			
	});
	
	$("#supplyDeleteButton").button().click(function(e) 
	{
		e.preventDefault();
		var projID = $(this).attr("data-project-id");
		
		$.ajax({
			type: "DELETE",
			url: "/projects/" + projID + "/supplies",
			success: function(msg){
				location.reload();
				}
			});

	});
	
});

function addNewLogMessage(data)
{
	$(".logContainer ul li:last").remove();
	$(".logContainer ul").prepend("<li><div class='logEntry'><a href='" + data.projURL +
		"' class='projectlink' title='" + data.projName + "'>" + data.projName + 
		"</a><span class='logmessage'>" + data.message + "</span><span class='timestamp'>" + data.timestamp + "</span></div></li>");
	$(".logContainer ul li:first").hide().show('highlight', {}, 20000);
}

function addNewProjectLogMessage(data)
{
	// %li
	// 	.logEntry
	// 		%span.projectLogTimestamp= l.timestamp.httpdate
	// 		%span.logmessage= l.entry
	
	// $(".logContainer ul li:last").remove();
	$(".projectLogContainer ul").prepend("<li><div class='logEntry'><span class='projectLogTimestamp'>" + data.timestamp + "</span><span class='logmessage'>" + data.message + "</span></div></li>");
	$(".projectLogContainer ul li:first").hide().show('highlight', {}, 20000);
}

function loadLogMessages(page, rows)
{
	// / %span.prevButton 
	// / 	%a{:href => '#'}Prev
	// / %span.currentPage Page 1
	// / %span.nextButton
	// / 	%a{:href => '#'} Next
	// / %span.pageCount

	$.getJSON("/logs", { page: page, rows: rows }, 
	function(json)
	{
		if (0 == $(".logControls").length) 
		{
			addLogControls();
		}
		
		if (null != json.prev_page)
		{
			$("a.prevLink").removeClass("disabled");
		}
		else
		{
			$("a.prevLink").addClass("disabled");
		}
		
		$("a.prevLink").unbind();
		$("a.prevLink").click(function()
			{
				if (null != json.prev_page)
				{
					loadLogMessages(json.prev_page, rows);
				}
			});

			if (null != json.next_page)
			{
				$("a.nextLink").removeClass("disabled");
			}
			else
			{
				$("a.nextLink").addClass("disabled");
			}

		$("a.nextLink").unbind();
		$("a.nextLink").click(function()
			{
				if (null != json.next_page)
				{
					loadLogMessages(json.next_page, rows);
				}
			});

		$(".currentPage").text("Page " + json.current_page + " of " + json.page_count)

		$(".logContainer li").remove();
		$.each(json.logs, function(i, item)
		{
			// %li
			// 				.logEntry
			// 					%a.projectlink{:title => l.project.name, :href => "/projects/#{l.project.id}"}= l.project.name
			// 					%span.logmessage= l.entry
			// 					%span.timestamp= l.timestamp.httpdate
			var frag = "<li><a class='projectlink' href='/projects/" + item.project_id + "'>" + item.project_name + "</a></li>";
			$(".logMessages ul").append(item.entry);
		});
		
		
		});	
}

function addLogControls()
{	
	var frag = "<div class='logControls'><span class='prevButton'><a href='#' class='prevLink'>Prev</a></span><span class='currentPage'>Page ?</span><span class='nextButton'><a href='#' class='nextLink'>Next</a></span></div>";
	$(".logMessages").append(frag);
}