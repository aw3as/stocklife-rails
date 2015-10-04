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
	var modal = $('#modal'),
		group = $('#group'),
		bot = $('#bot'),
		length = $('#length'),
		unit = $('#unit'),
		plus = $('#plus'),
		minus = $('#minus'),
		groupGroup = $('#group-group'),
		lengthGroup = $('#length-group'),
		botGroup = $('#bot-group'),
		plusGroup = $('#plus-group'),
		minusGroup = $('#minus-group');

	modal.modal();

	$('#reset').click(function() {

		group.val('');
		bot.val('');
		plus.val('');
		minus.val('');
		length.val('');
		$('#day').click();

		groupGroup.removeClass('has-error');
		groupGroup.removeClass('has-success');
		botGroup.removeClass('has-error');
		botGroup.removeClass('has-success');
		lengthGroup.removeClass('has-error');
		lengthGroup.removeClass('has-success');
		plusGroup.removeClass('has-error');
		plusGroup.removeClass('has-success');
		minusGroup.removeClass('has-error');
		minusGroup.removeClass('has-success');
	});

	$('#register').click(function() {
		if (groupGroup.hasClass('has-success') && botGroup.hasClass('has-success') && lengthGroup.hasClass('has-success') && plusGroup.hasClass('has-success') && minusGroup.hasClass('has-success')) {
			$.ajax('register', {
				method: 'POST',
				data: {
					group_id: group.val(),
					bot_id: bot.val(),
					length: parseInt(length.val()) * ($('#unit').text().trim() == 'Days' ? 1 : 7),
					daily_plus: plus.val(),
					daily_minus: minus.val()
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

	$('li').click(function() {
		$('#unit').html($(this).text().trim() + ' <span class="caret"></span>');
		length.blur();
	});

	group.blur(function() {
		if (/^\d+$/.test(group.val())) {
			groupGroup.addClass('has-success');
			groupGroup.removeClass('has-error');
		} else {
			groupGroup.addClass('has-error');
			groupGroup.removeClass('has-success');
		}
	});

	bot.blur(function() {
		if (/^[a-z0-9]+$/.test(bot.val()) && bot.val().length == 26) {
			botGroup.addClass('has-success');
			botGroup.removeClass('has-error');
		} else {
			botGroup.addClass('has-error');
			botGroup.removeClass('has-success');
		}
	});

	length.blur(function() {
		var days = parseInt(length.val()) * ($('#unit').text().trim() == 'Days' ? 1 : 7);
		if (/^\d+$/.test(length.val()) && days > 2 && days < 43){
			lengthGroup.addClass('has-success');
			lengthGroup.removeClass('has-error');
		} else {
			lengthGroup.addClass('has-error');
			lengthGroup.removeClass('has-success');
		}
	});

	plus.blur(function() {
		if (/^\d+$/.test(plus.val())) {
			plusGroup.addClass('has-success');
			plusGroup.removeClass('has-error');
		} else {
			plusGroup.addClass('has-error');
			plusGroup.removeClass('has-success');
		}
	});

	minus.blur(function() {
		if (/^\d+$/.test(minus.val())) {
			minusGroup.addClass('has-success');
			minusGroup.removeClass('has-error');
		} else {
			minusGroup.addClass('has-error');
			minusGroup.removeClass('has-success');
		}
	});
});