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
	var updateChannel = pusher.subscribe('update_channel');
	updateChannel.bind('update', function(data) {
		// alert(data);
		// location.reload();
	});
	
	var logChannel = pusher.subscribe('log_channel');
	logChannel.bind('new', function(data) {
		addNewLogMessage(data);
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
