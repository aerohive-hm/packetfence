$(document).ready(function(){


  document.getElementById("link-account").onclick = function (){
    var url = document.getElementById("url").value;
    var user = document.getElementById("user").value;
    var pass = document.getElementById("pass").value;

    console.log("clicked on link account");
    // e.preventDefault();
    linkAerohiveAccount();
  }
});

//function
// function populateCloudTable(){
//
// }

//function to submit form
function linkAerohiveAccount(){
  console.log("inside link aerohive account");
  var base_url = window.location.origin;
  var form = document.forms.namedItem("cloudForm");
  var formData = new FormData(form);
  // console.log("formelement: ");
  // console.log(form);
  // console.log("formData: ");
  var object = {};
  formData.forEach(function(value, key){
      object[key] = value;
  });
  var jsonFormData = JSON.stringify(object);

  $.ajax({
      type: 'POST',
      url: base_url + '/a3/api/v1/configuration/cloud',
      dataType: json,
      data: jsonFormData,
      success: function(data){
        console.log("went through");
        console.log(data);
      },
      error: function(data){
          alert('something went wrong');
          console.log(data);
      }
  });
}
