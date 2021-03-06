jQuery.fn.center = function () {
    this.css("position","absolute");
    this.css("top", Math.max(0, (($(window).height() - $(this).outerHeight()) / 2) + 
                                                $(window).scrollTop()) + "px");
    this.css("left", Math.max(0, (($(window).width() - $(this).outerWidth()) / 2) + 
                                                $(window).scrollLeft()) + "px");
    return this;
}


$(document).ready(function(){

	//qr link
	$('#qr_code').on('click', function(){
		var qr = $('#qr_popup');
        $(qr).fadeIn('fast');
        qr.center();
        var overlay = $('#black_overlay');
        $(overlay).fadeIn('fast');
        $(overlay).on('click', function(){
          $(qr).fadeOut('f');
          $(this).fadeOut('fast');
        });
	});

	//talks link
	$('#talks').on('click', function(){
        var talks = $('#talks_popup');
        $(talks).fadeIn('fast');
        talks.center();
        var overlay = $('#black_overlay');
        $(overlay).fadeIn('fast');
        $(overlay).on('click', function(){
          $(talks).fadeOut('fast');
          $(this).fadeOut('fast');
        });
	});

    // email link
    $('#email').on('click', function(){
        var email = $('#email_popup');
        $(email).fadeIn('fast');
        email.center();
        var overlay = $('#black_overlay');
        $(overlay).fadeIn('fast');
        $(overlay).on('click', function(){
          $(email).fadeOut('fast');
          $(this).fadeOut('fast');
        });
    });


    // location link
    $('#location').on('click', function(){
        var location = $('#location_popup');
        $(location).fadeIn('fast');
        location.center();
        var overlay = $('#black_overlay');
        $(overlay).fadeIn('fast');
        $(overlay).on('click', function(){
          $(location).fadeOut('fast');
          $(this).fadeOut('fast');
        });
    });

    // close popups
    $('.close_popup').on('click', function(){
      $(this).parent().fadeOut('fast');
      $('#black_overlay').fadeOut('fast');
    });
});
