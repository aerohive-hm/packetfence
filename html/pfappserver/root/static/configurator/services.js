function registerExits() {
    $('.form-actions button').click(function(event) {
        var btn = $(this);
        if (btn.hasClass('disabled')) return false;
        var href = btn.attr('href');
        saveStep(href);
        return false; // don't follow link
    });
}


$(document).ready(function(){
     $("#details").click(function(){
         $("#daemonTable").toggle();
     });
});

function saveStep(href) {
    $('table .label').each(function(index, event) {
        $(this).fadeIn().delay(100*index).fadeOut('fast', function(event) {
            $(this).text('Starting').removeClass('label-error label-success').addClass('label-warning');
        }).fadeIn('fast');
    });
    $.ajax({
        type: 'POST',
        url: href
    }).always(function(data) {
        setInterval(function(){getStatus(href)}, 10000);
    }).done(function(data) {
        resetAlert($('#services'));
          console.log("done saveStep");
    }).fail(function(jqXHR) {
        servicesError();
        var obj = $.parseJSON(jqXHR.responseText);
        if(obj) {
            showError($('#services table'), obj.status_msg);
        }
    });

}

function getStatus(href){
    $.ajax({
        type: 'POST',
        url: href
    }).done(function(data) {
        resetAlert($('#services'));
        servicesUpdate(data);
        console.log("done getStatus");
        // where it stops after all of them start
    }).fail(function(jqXHR) {
        servicesError();
        var obj = $.parseJSON(jqXHR.responseText);
        if(obj) {
            showError($('#services table'), obj.status_msg);
        }
    });
}

function escape_service(service){
    return service.replace(/([;&,\.\+\*\~':"\!\^#$%@\[\]\(\)=>\|])/g, '\\$1')
}

function servicesUpdate(data) {
    var startFailed = false;
    $.each(data.services, function(i, service) {
        // identify services that didn't start and set failure flag
        if (service.status != "0") {
            $('#service-' + escape_service(service.name)).fadeOut('fast', function(event) {
                $(this).text('Started').removeClass('label-error label-warning').addClass('label-success');
            }).fadeIn();
        }
        else{
            startFailed = true;
        }
    });
    updateProgressBar();
    if (!startFailed) {
        // added a delay for dramatic effect
        window.setTimeout(function() { $('#modalRedirection').modal({ show: true }); }, 2000 );
    }
}

function servicesError() {
    $('table .label').each(function(index, event) {
        $(this).fadeIn().delay(100*index).fadeOut('fast', function(event) {
            $(this).text('Unknown').removeClass('label-error label-success').addClass('label-warning');
            var stopAnimation = document.getElementById("movingLogo");
            stopAnimation.classList.remove("startRotation");
        }).fadeIn('fast');
    });

}

function updateProgressBar(){
  var progressBarFrame = document.getElementById("progress-bar");
  var progressBar = document.getElementById("progress");
  var widthTotal = $(".table tbody tr").length;
  var width = 0;
  	console.log("widthTotal: " + widthTotal);
  	$('table .label').each(function(){
  	  console.log($(this).text());
	    if ($(this).text() === 'Started'){
	      width++;
        console.log ("width: " + width);
	    }
	  });
    var percentageWidth = Math.round((width) * (100/widthTotal)) + '%';
    console.log(percentageWidth);
    var daemonTextUpdate = $("#daemons");
    $(daemonTextUpdate).text(width).fadeIn(500);
    document.getElementById("daemons").innerHTML = width;
    $(progressBar).css('width', percentageWidth).animate({width: percentageWidth}, 1000);
    if (width === widthTotal){
        var stopAnimation = document.getElementById("movingLogo");
        stopAnimation.classList.remove("startRotation");
    }
}
