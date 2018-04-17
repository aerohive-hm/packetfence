
$(document).ready(function(){
  $(".trial-clock-indicator").click(function(){
    // console.log("clickclick");
    $("#clockTrialDiv").animate({
      width: "toggle"
    });
  });

  timeLeft();
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
         days  = Math.floor(parseSeconds / (3600*24));
         hours = Math.floor(parseSeconds / 3600);
         console.log("Days: " + days);
         numberOfDaysLeft = days + 1;
         var percentageWidth = Math.round((numberOfDaysLeft) * (100/30)) + '%';
         if (numberOfDaysLeft > 1 && numberOfDaysLeft <29){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', percentageWidth);
         }else if(numberOfDaysLeft == 29 || numberOfDaysLeft == 30){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', 180);
         }else {
            $("#daysLeft").html(numberOfDaysLeft + " " + "day");
            $(timeBar).css('width', percentageWidth);
         }
    }).fail(function(xhr, status, error){
        console.log(error);
        if (error){
           document.getElementById('selection-warning').style.display = 'block';
        }
    });
      // // success: function(data){
      //    seconds = data.trial[0].expires_in;
      //    var parseSeconds = parseInt(seconds, 10);
      //    days  = Math.floor(parseSeconds / (3600*24));
      //    hours = Math.floor(parseSeconds / 3600);
      //    console.log("Days: " + days);
      //    numberOfDaysLeft = days + 1;
      //    if (numberOfDaysLeft > 1 && numberOfDaysLeft <29){
      //       $("#daysLeft").html(numberOfDaysLeft + " " + "days");
      //    }else if(numberOfDaysLeft == 29 || numberOfDaysLeft == 30){
      //       $("#daysLeft").html(numberOfDaysLeft + " " + "days");
      //       document.getElementById("time-indicator-bar").style.width = 180;
      //    }else {
      //       $("#daysLeft").html(numberOfDaysLeft + " " + "day");
      //    }
      //    //add modal show up after days gets to 5
      //
      // },
      // fail: function(){
      //    console.log(error);
      // }
}
