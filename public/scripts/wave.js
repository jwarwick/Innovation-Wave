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
	pusher.subscribe('update_channel');
	pusher.bind('update', function(data) {
		// alert(data);
		location.reload();
	});
});

