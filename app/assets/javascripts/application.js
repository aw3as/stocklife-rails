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
		cash = $('#cash'),
		price = $('#price'),
		minimum = $('#minimum'),
		groupGroup = $('#group-group'),
		botGroup = $('#bot-group'),
		cashGroup = $('#cash-group'),
		priceGroup = $('#price-group'),
		minimumGroup = $('#minimum-group');

	modal.modal();

	$('#reset').click(function() {

		group.val('');
		bot.val('');
		cash.val('');
		price.val('');
		minimum.val('');

		groupGroup.removeClass('has-error');
		groupGroup.removeClass('has-success');
		botGroup.removeClass('has-error');
		botGroup.removeClass('has-success');
		cashGroup.removeClass('has-error');
		cashGroup.removeClass('has-success');
		priceGroup.removeClass('has-error');
		priceGroup.removeClass('has-success');
		minimumGroup.removeClass('has-error');
		minimumGroup.removeClass('has-success');
	});

	$('#register').click(function() {
		if (groupGroup.hasClass('has-success') && botGroup.hasClass('has-success') && cashGroup.hasClass('has-success') && priceGroup.hasClass('has-success') && minimumGroup.hasClass('has-success')) {
			$.ajax('register', {
				method: 'POST',
				data: {
					group_id: group.val(),
					bot_id: bot.val(),
					start_cash: cash.val(),
					start_price: price.val(),
					minimum_person: minimum.val(),
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

	cash.blur(function() {
		if (/^\d+$/.test(cash.val())) {
			cashGroup.addClass('has-success');
			cashGroup.removeClass('has-error');
		} else {
			cashGroup.addClass('has-error');
			cashGroup.removeClass('has-success');
		}
	});

	price.blur(function() {
		if (/^\d+$/.test(price.val())) {
			priceGroup.addClass('has-success');
			priceGroup.removeClass('has-error');
		} else {
			priceGroup.addClass('has-error');
			priceGroup.removeClass('has-success');
		}
	});

	minimum.blur(function() {
		if (/^\d+$/.test(minimum.val())) {
			minimumGroup.addClass('has-success');
			minimumGroup.removeClass('has-error');
		} else {
			minimumGroup.addClass('has-error');
			minimumGroup.removeClass('has-success');
		}
	});
});