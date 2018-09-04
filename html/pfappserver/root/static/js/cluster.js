$(document).ready(function(){


});

//function to get cluster table data
function getClusterStatusInfo(){
  $.get("/a3/api/v1/configuration/cluster", function(data){
          alert("Data: " + data);
  });
}

function submitClusterNode(){
  var base_url = window.location.origin;
  $.ajax({
      type: 'POST',
      url: base_url + '/a3/api/v1/configuration/cluster',
      dataType: 'json',
      processData: false,
      contentType: false,
      success: function(data){

      },
      error: function(data){
        alert("something went wrong");
        var errMsg = data.status_msg;
        if (errMsg != null ) {
            document.getElementById('errorMessage').innerHTML = errMsg;
            $("#success-alert").show();
            setTimeout(function (){
              $("#success-alert").slideUp(500);
            }, 3000);
        }
      }
  });
}
