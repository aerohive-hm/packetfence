
$(document).ready(function(){
  $(".trial-clock-indicator").click(function(){
    $("#clockTrialDiv").animate({
      width: "toggle"
    });
  });

  // $("#trialIndicator").load(window.location + " #trialIndicator");
  timeLeft();

  $(".dismiss-modal").click(function(){
    $("#myModal").css("display", "none");
  });

  $("#logout").click(function(){
     localStorage.clear();
  });

  var emailForm = $('.emailForm');
  var emailFormButton = $('.toggle-emailForm');
  var licenseAlertButton = $('.toggle-licenseAlert');
  var licenseAlert = $('.licenseAlert');
  var sentEmailButton = $('.emailSentSuccess');
  var successEmailMessage = $('.successEmailMessage');
  $(document).ready(function() {
      emailForm.hide();
      successEmailMessage.hide();
      emailFormButton.click(function() {
        licenseAlert.slideUp(1000);
        emailForm.slideDown(1000);
      });
      licenseAlertButton.click(function() {
        emailForm.slideUp(1000);
        licenseAlert.slideDown(1000);
      });
      sentEmailButton.click(function(){
        emailForm.slideUp(1000);
        successEmailMessage.slideDown(1000);
      });
    });

});

function toLicensePage(){
      var base_url = window.location.origin;
      location.href = base_url+"/admin/licenseKeys";
}

function timeLeft(){
  var base_url = window.location.origin;
  var timeBar = document.getElementById("time-indicator-bar");
  var numOfDaysLeft = 0;
  var seconds = 0;
  var hours = 0;
  var days = 0;
  $.ajax({
      type: 'GET',
      url: base_url + '/entitlement/trial'
    }).done(function(data){
         seconds = data.trial[0].expires_in;
         var parseSeconds = parseInt(seconds, 10);
         days  = Math.floor(parseSeconds / (3600*24));
         hours = Math.floor(parseSeconds / 3600);
         numberOfDaysLeft = days;
         var percentageWidth = Math.round((numberOfDaysLeft) * (100/30)) + '%';
         if (numberOfDaysLeft > 15 && numberOfDaysLeft < 29){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', percentageWidth);
         }else if(numberOfDaysLeft == 29){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', 180);
         }else if(numberOfDaysLeft == 30){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', 180);

         }else if(numberOfDaysLeft <= 15 && numberOfDaysLeft > 0 ){
            if ($.cookie('pop') == null) {
               $.cookie('pop', '1');
            }
            if (numberOfDaysLeft == 1){
              $("#daysLeft").html(numberOfDaysLeft + " " + "day");
              $(timeBar).css('width', percentageWidth);
            }else{
              $("#daysLeft").html(numberOfDaysLeft + " " + "days");
              $(timeBar).css('width', percentageWidth);
            }
         }else if (numberOfDaysLeft == 0){
               $('#expiredModal').modal('show');
               $("#daysLeft").html(numberOfDaysLeft + " " + "day");
               $(timeBar).css('width', percentageWidth);
         }else{
               $("#daysLeft").html(0 + " " + "day");
               $(timeBar).css('width', 0);
         }
           // modal to show for actually expire
    }).fail(function(xhr, status, error){
        $('.trialIndicator').remove();

    });
    return numOfDaysLeft;
}


function openExpiredModal(){
    $('#expiredModal').modal({backdrop:'static', keyboard: false });
    $('#expiredModal').modal('show');
}

function openAlmostExpiredModal(){
      if(typeof(Storage) !== "undefined") {
          var almostModalShowed = localStorage.getItem('modalShowed');
          if (!almostModalShowed) {
              $('#myModal').modal({backdrop:'static', keyboard: false });
              $('#myModal').modal('show');
              localStorage.setItem('modalShowed', 1);
          }
          else {
              $("#myModal").hide();
          }
      }
}

function openEnforcementModal(){
    $('#enforcementModal').modal({backdrop:'static', keyboard: false });
    $('#enforcementModal').modal('show');
}

function openOverUsageModal(){
    $('#overUsageModal').modal({backdrop:'static', keyboard: false });
    $('#overUsageModal').modal('show');
}