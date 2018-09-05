$(document).ready(function(){

  document.getElementById("link-account").onclick = function (){
    console.log("clicked on link account");
    // e.preventDefault();
    linkAerohiveAccount();
  }
});

//function to switch back and forth depending on setrings


//function to submit form
function linkAerohiveAccount(){
  console.log("inside link aerohive account");
  var base_url = window.location.origin;
  var form = document.forms.namedItem("cloudForm");
  // var form = $('#cloudForm').serializeArray();
  var formData = new FormData(form);
  console.log("formelement: ");
  console.log(form);
  console.log("formData: ");
  // req = new XMLHttpRequest();
  //
  // req.open("POST", "/a3/api/v1/configuration/cloud")
  // req.send(formData);
  $.ajax({
      type: 'POST',
      url: base_url + '/a3/api/v1/configuration/cloud',
      dataType: json,
      data: formData,
      success: function(data){
          alert(data);
          return data;
      },
      error: function(data){
          alert('something went wrong');
      }
  });
}

//function to response from data put in table for cloud
