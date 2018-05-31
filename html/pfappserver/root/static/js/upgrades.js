$(document).ready(function(){
  upgradeButton();
});

function upgradeButton(){
  var upgradeButton = $("#upgrade-button");
  upgradeButton.click(function(){
      $("#upgrade-button" ).slideUp();
      $(".progress-bar-content").slideDown();
  });
}
