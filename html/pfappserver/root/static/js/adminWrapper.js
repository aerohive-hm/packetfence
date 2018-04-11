
$(document).ready(function(){
  $(".trial-clock-indicator").click(function(){
    console.log("clickclick");
    $("#clockTrialDiv").animate({
      width: "toggle"
    });
  });
});
