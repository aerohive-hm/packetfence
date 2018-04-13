
$(document).ready(function(){
  $(".trial-clock-indicator").click(function(){
    // console.log("clickclick");
    $("#clockTrialDiv").animate({
      width: "toggle"
    });
  });
  timeLeft();
  document.getElementById("time-indicator").style.width = 30 * 6;
});

function timeLeft(){
  var base_url = window.location.origin;
  var numOfDaysLeft = 0;
  var seconds = 0;
  var hours = 0;
  var days = 0;
  $.ajax({
      type: 'GET',
      url: base_url + '/entitlement/trial',
      success: function(data){
         seconds = data.trial[0].expires_in;
         var parseSeconds = parseInt(seconds, 10);
         days  = Math.floor(parseSeconds / (3600*24));
         hours = Math.floor(parseSeconds / 3600);
         console.log("Days: " + days);
         numberOfDaysLeft = days;
         if (numberOfDaysLeft > 1){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
         } else {
            $("#daysLeft").html(numberOfDaysLeft + " " + "day");
         }
         document.getElementById("time-indicator-bar").style.width = numberOfDaysLeft;
         //fix plural issue for days
      },
      fail: function(){
         console.log(error);
      }
    });
}
