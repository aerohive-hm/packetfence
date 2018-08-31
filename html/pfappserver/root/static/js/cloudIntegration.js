$(document).ready(function(){
  $("#link-account").on("click", function(e) {
    e.preventDefault();
    $(".disconnected").hide();
    $(".cluster-cloud").show();
  });

  $("#unlink-account2").on("click", function(e) {
    e.preventDefault();
    $(".cluster-cloud").hide();
    $(".disconnected").show();
  });
});

//function to switch back and forth depending on setrings


//function to submit form
function linkAerohiveAccount(){
  //get button id

}


//function to response from data put in table for cloud
