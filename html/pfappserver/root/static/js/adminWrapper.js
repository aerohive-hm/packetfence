
$(document).ready(function(){
  $(".trial-clock-indicator").click(function(){
    $("#clockTrialDiv").animate({
      width: "toggle"
    });
  });
  // $("#trialIndicator").load(window.location + " #trialIndicator");
  $(".dismiss-modal").click(function(){
    $("#myModal").css("display", "none");
  });

  document.getElementById("licenseKey").onclick = function () {
    var base_url = window.location.origin;
    console.log("going to license management page");
    location.href = base_url+"/admin/licenseKeys";
  };

  timeLeft();

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
         days  = Math.ceil(parseSeconds / (3600*24));
         hours = Math.ceil(parseSeconds / 3600);
         console.log("Days: " + days);
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
               console.log("show modal");
               $('#myModal').modal('show');
               $.cookie('pop', '1');
            }
            if (numberOfDaysLeft == 1){
              document.getElementById("daysLeft2").innerHTML= numberOfDaysLeft + " day";
              $("#daysLeft").html(numberOfDaysLeft + " " + "day");
              $(timeBar).css('width', percentageWidth);
            }else{
              document.getElementById("daysLeft2").innerHTML= numberOfDaysLeft + " days";
              $("#daysLeft").html(numberOfDaysLeft + " " + "days");
              $(timeBar).css('width', percentageWidth);
            }
         }else if (numberOfDaysLeft == 0){
              console.log("show expired modal");
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
        console.log("removing trial indicator");

    });
    return numOfDaysLeft;
}


function openExpiredModal(){
    console.log("show expired modal");
    $('#expiredModal').modal({backdrop:'static', keyboard: false });
    $('#expiredModal').modal('show');
}

function openAlmostExpiredModal(){
    $('#myModal').modal({backdrop:'static', keyboard: false });
    $('#myModal').modal('show');
}
