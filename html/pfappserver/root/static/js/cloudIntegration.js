$(document).ready(function(){
  getNodeInfo();

  document.getElementById("link-account").onclick = function(e){
    e.preventDefault();
    var cloudurl  = document.getElementById('url').value;
    var clouduser = document.getElementById('user').value;
    var cloudpass = document.getElementById('pass').value;
    if(cloudurl == "" || clouduser == "" || cloudpass == ""){
      document.getElementById('errorMessage').innerHTML = "Fill in all fields.";
      $("#error-alert").show();
      setTimeout(function (){
        $("#error-alert").slideUp(500);
      }, 3000);
    } else {
      linkAerohiveAccount();
    }
    console.log("clicked on link account");
    //add loader here
  }

  document.getElementById('unlink-account').onclick = function(){
    console.log("clicked on unlink account");
    document.getElementById("link-account").disabled = false;
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
      //determin which page to show if linked or unlinked
      //linked
      if (data.msgtype == "nodesInfo"){
        $('#rdcUrl').html(data.body.header.rdcUrl);
        document.getElementById("rdcUrl").href = data.body.header.rdcUrl;
        if (data.body.header.region == ""){
          $('#region').html("unknown");
        } else {
          $('#region').html(data.body.header.region);
        }
        $('#ownerId').html(data.body.header.ownerId);
        if (data.body.header.lastContactTime == ""){
          $('#lastContactTime').html("unknown");
        } else {
          $('#lastContactTime').html(data.body.header.lastContactTime);
        }
        $('#vhmId').html(data.body.header.vhmId);

        $(".disconnected").hide();
        $(".linked").show();
        $.each(data.body.data, function(i, items){
          console.log(items);
          //convert time stamp here
          $("#cloud-cluster-table-tbody").append("<tr><td id='connectedIcon'>" + items.status + "</td><td>" + items.hostname + "</td><td>" +  items.lastContactTime + "</td></tr>");
        });
        $('#cloud-cluster-table-tbody td:nth-child(1)').each(function() {
          console.log($(this));
          console.log("hi");
          if ($(this).text() == "connected"){
              $(this).html('<i class="icon-circle icon" style="color:#28a745; font-size:15px; margin: 0 auto;"></i>');
          } else if ($(this).text() == "connecting") {
              $(this).html('<i class="icon-circle icon" style="color:#ffc107; font-size:15px; margin: 0 auto;"></i>');
          } else if ($(this).text() == "disconnected") {
              $(this).html('<i class="icon-circle icon" style="color:#dc3545; font-size:15px; margin: 0 auto;"></i>');
          } else {
              $(this).html('<i class="icon-exclamation-triangle icon" style="color:#dc3545; font-size:15px; margin: 0 auto;"></i>');
          }
        });
        $('#cloud-cluster-table-tbody tr:nth-child(even) td').each(function(){
            $(this).css('background-color', '#f4f6f9');
        });

        //unlinked
      } else if (data.msgtype == "cloudConf"){
        $('#rdcUrl').html(data.body.header.rdcUrl);
        document.getElementById("rdcUrl").href = data.body.header.rdcUrl;
        if (data.body.header.region == ""){
          $('#region').html("unknown");
        } else {
          $('#region').html(data.body.header.region);
        }
        // if ($('#lastContactTime').text() == ""){
        $('#lastContactTime').html("unknown");
        // } else {
        //   $('#lastContactTime').html(data.body.data.lastContactTime);
        // }
        $('#ownerId').html(data.body.header.ownerId);
        $('#vhmId').html(data.body.header.vhmId);
        $(".linked").hide();
        $(".disconnected").show();
      } else {
        $(".disconnected").show();
      }
    },
    error: function(data){
      document.getElementById('errorMessage').innerHTML = "Could not retrieve data.";
      $("#error-alert").show();
      setTimeout(function (){
        $("#error-alert").slideUp(500);
      }, 3000);
    }
  })
}

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
        $("#error-alert").show();
        setTimeout(function (){
          $("#error-alert").slideUp(500);
        }, 3000);
      } else {
          $(".linked").hide();
          $(".disconnected").show();
          document.getElementById('successMessage').innerHTML = "Successfully unlinked.";
          $("#success-alert").show();
          setTimeout(function (){
            $("#success-alert").slideUp(500);
          }, 3000);
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
  document.getElementById("link-account").disabled = true;
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
          $("#error-alert").show();
          setTimeout(function (){
            $("#error-alert").slideUp(500);
          }, 3000);
          document.getElementById("link-account").disabled = false;
        } else {
            $(".disconnected").hide();
            $(".linked").show();
            document.getElementById('successMessage').innerHTML = "Successfully linked";
            $("#success-alert").show();
            setTimeout(function (){
              $("#success-alert").slideUp(500);
            }, 3000);
            getNodeInfo();

        }
      },
      error: function(data){
          console.log(data);
          document.getElementById('errorMessage').innerHTML = data.msg;
          $("#error-alert").show();
          setTimeout(function (){
            $("#error-alert").slideUp(500);
          }, 3000);
          document.getElementById("link-account").disabled = false;
      }
  });
}
