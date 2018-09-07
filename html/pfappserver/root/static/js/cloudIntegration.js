
$(document).ready(function(){
  getNodeInfo();


  document.getElementById("link-account").onclick = function(){
    console.log("clicked on link account");
    linkAerohiveAccount();
  }

  document.getElementById('unlink-account').onclick = function(){
    console.log("clicked on unlink account");
    unlinkAerohiveAccount();
  }

});

function getNodeInfo(){
  console.log("inside getNodeInfo");
  var rdcUrl            = document.getElementById('rdcUrl'),
      region            = document.getElementById('region'),
      ownerId           = document.getElementById('ownerId'),
      lastContactTime   = document.getElementById('lastContactTime'),
      vhmId             = document.getElementById('vhmId');
  var base_url = window.location.origin;

  $.ajax({
    type: 'GET',
    url: base_url + '/a3/api/v1/configuration/cloud',
    success: function(data){
      console.log(data);
      $('#rdcUrl').html(data.header.rdcUrl);
      document.getElementById("rdcUrl").href = data.header.rdcUrl;
      if (data.header.region == ""){
        $('#region').html("unknown");
      } else {
        $('#region').html(data.header.region);
      }
      $('#ownerId').html(data.header.ownerId);
      $('#lastContactTime').html(data.data.lastContactTime);
      $('#vhmId').html(data.header.vhmId);

      //determin which page to show if linked or unlinked
      //linked
      if (data.msgtype == "nodesInfo"){
        $(".disconnected").hide();
        $(".linked").show();
        //unlinked
      } else if (data.msgtype == "cloudConf"){
        $(".linked").hide();
        $(".disconnected").show();
      } else {
        $(".disconnected").show();
      }
    },
    error: function(data){
      document.getElementById('errorMessage').innerHTML = "Could not retrieve data.";
      $("#success-alert").show();
      setTimeout(function (){
        $("#success-alert").slideUp(500);
      }, 3000);
    }
  })
}

// function populateCloudTable(){
//
// }

function unlinkAerohiveAccount(){
  console.log("inside unlink aerohive account");
  var base_url = window.location.origin;
  var data = {url: ""};
  var jsonFormData = JSON.stringify(data);

  $.ajax({
    type: 'POST',
    url: base_url + '/a3/api/v1/configuration/cloud',
    dataType: 'json',
    data: jsonFormData,
    success: function(data){
      console.log("went through");
      console.log(data);
      if (data.code == "fail"){
        document.getElementById('errorMessage').innerHTML = data.msg;
        $("#success-alert").show();
        setTimeout(function (){
          $("#success-alert").slideUp(500);
        }, 3000);
      } else {
          $(".linked").hide();
          $(".disconnected").show();
      }
    },
    error: function(data){
        alert('something went wrong');
        console.log(data);
    }
  });
}

//function to submit form
function linkAerohiveAccount(){
  console.log("inside link aerohive account");
  var base_url = window.location.origin;
  var form = document.forms.namedItem("cloudForm");
  var formData = new FormData(form);
  var object = {};
  formData.forEach(function(value, key){
      object[key] = value;
  });
  var jsonFormData = JSON.stringify(object);

  $.ajax({
      type: 'POST',
      url: base_url + '/a3/api/v1/configuration/cloud',
      dataType: 'json',
      data: jsonFormData,
      success: function(data){
        console.log("went through");
        console.log(data);
        if (data.code == "fail"){
          document.getElementById('errorMessage').innerHTML = data.msg;
          $("#success-alert").show();
          setTimeout(function (){
            $("#success-alert").slideUp(500);
          }, 3000);
        } else {
            $(".disconnected").hide();
            $(".linked").show();
            getNodeInfo();

        }
      },
      error: function(data){
          alert('something went wrong');
          console.log(data);
      }
  });
}
