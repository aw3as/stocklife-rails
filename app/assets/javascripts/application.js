// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui/slider
//= require bootstrap-sprockets
//= require nprogress
//= require nprogress-ajax
//= require_tree .

$(document).ready(function() {
	var group = $('#group'),
		bot = $('#bot'),
		modal = $('#modal');

	modal.modal();

	$('#reset').click(function() {
		var groupGroup = $('#group-group'),
			botGroup = $('#bot-group');

		group.val('');
		bot.val('');

		groupGroup.removeClass('has-error');
		groupGroup.removeClass('has-success');
		botGroup.removeClass('has-error');
		botGroup.removeClass('has-success');
	});

	$('#register').click(function() {
		var groupGroup = $('#group-group'),
			botGroup = $('#bot-group');
		if (groupGroup.hasClass('has-success') && botGroup.hasClass('has-success')) {
			$.ajax('register', {
				method: 'POST',
				data: {
					group_id: group.val(),
					bot_id: bot.val()
				},
				success: function(response) {
					alert('Thanks for registering for $tocklife!');
					$('#reset').click();
				},
				error: function(response) {
					alert('An error has occured! Sorry!');
				}
			});
		}
	});

	group.blur(function() {
		var groupGroup = $('#group-group');

		if (/^\d+$/.test(group.val())) {
			groupGroup.addClass('has-success');
			groupGroup.removeClass('has-error');
		} else {
			groupGroup.addClass('has-error');
			groupGroup.removeClass('has-success');
		}
	});

	bot.blur(function() {
		var botGroup = $('#bot-group');

		if (/^[a-z0-9]+$/.test(bot.val()) && bot.val().length == 26) {
			botGroup.addClass('has-success');
			botGroup.removeClass('has-error');
		} else {
			botGroup.addClass('has-error');
			botGroup.removeClass('has-success');
		}
	});
});