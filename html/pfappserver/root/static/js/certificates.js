//TO-DO
//add check for empty key or empty server or both empty
//if file went in and second fail, then remove, put before Verify file
//

$(document).ready(function(){
   readCert("https");
   readCert("eap");
    $('[data-toggle="popover"]').popover({
      container: 'body'
    });

  var https_key         = document.getElementById('https_serverKey_upload');
  var https_server_cert = document.getElementById('https_serverCert_upload');
  var eap_key           = document.getElementById('serverKey_upload');
  var eap_server_cert   = document.getElementById('serverCert_upload');
  var eap_ca_cert       = document.getElementById('caCert_upload');
  var https_form        = document.getElementById('https_form').name;
  var eap_form          = document.getElementById('eap_tls_form').name;
  var view_more_link    = document.getElementById('view-more');

  var https_path        = document.getElementById('https_key_path');
  var https_server_cert = document.getElementById('https_cert_path');
  var eap_key_path      = document.getElementById('eap_key_path');
  var eap_server_path   = document.getElementById('eap_cert_path');
  var eap_ca_path       = document.getElementById('eap_cacert_path');

  document.getElementById("https-upload").onclick = function(e){
    e.preventDefault();
    console.log("https key" + https_key.value);
    console.log("https cert" + document.getElementById('https_serverCert_upload').value);

    //add promise, upload key then upload cert
    // then call verify files
    $.when(uploadCert(document.getElementById('https_serverCert_upload'), "https_form"),uploadKey(https_key, "https_form")).done(function(https_path, https_server_cert){
        console.log(https_path[0].filePath); console.log(https_server_cert[0].filePath);
        var qualifier = "https";
        verifyCert(https_path[0].filePath,https_server_cert[0].filePath, qualifier);
    });
  }

  document.getElementById("eap-upload").onclick = function(e){
    e.preventDefault();
    console.log("eap key" + eap_key.value);
    console.log("eap server" + eap_server_cert.value);
    console.log("eap ca " + eap_ca_cert.value);
    if (eap_ca_cert.value == ""){
      console.log("ca is empty");
      $.when(uploadKey(eap_key, "eap_tls_form"), uploadCert(document.getElementById('serverCert_upload'), "eap_tls_form")).done(function(eap_path, eap_server_cert_path){
          console.log(eap_path[0].filePath); console.log(eap_server_cert_path[0].filePath);
          var qualifier = "eap";
          verifyCert(eap_path[0].filePath,eap_server_cert_path[0].filePath, qualifier);
      });
    } else {
      console.log("ca is not empty");
      $.when(uploadKey(eap_key, "eap_tls_form"), uploadCert(document.getElementById('serverCert_upload'), "eap_tls_form"), uploadCACert(document.getElementById('caCert_upload'), "eap_tls_form")).done(function(eap_path, eap_server_cert_path, eap_ca_cert_path){
          console.log(eap_path[0].filePath); console.log(eap_server_cert_path[0].filePath); console.log(eap_ca_cert_path[0].filePath);
          var qualifier = "eap";
          verifyCert(eap_path[0].filePath,eap_server_cert_path[0].filePath, qualifier);
      });
    }
  }


  document.getElementById("download_https_serv").onclick = function(e){
    console.log("pressing downloading");
    e.preventDefault();
    downloadCert("https");
  }

});

//upload key
function uploadKey(input, sentForm){
    console.log("in upload key");
    console.log("key input" + input.files[0]);
    var base_url = window.location.origin;
    var form = document.forms.namedItem(sentForm);
    var fd = new FormData(form[0]);
    fd.append("file", input.files[0]);

    return $.ajax({
        type: 'POST',
        url: base_url + '/uploadKey',
        data: fd,
        dataType: 'json',
        processData: false,
        contentType: false,
        success: function(data){
          console.log("uploadKey data: " );
          console.log(data);
          console.log("- - - - - - - - -");
          document.getElementById("https_key_path").value = data.filePath;
          var filePath = data.filePath;
        },
        error: function(data){
          // alert("did not go through");
          console.log(data.responseJSON.status_msg);
          document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
          $("#success-alert").show();
          setTimeout(function(){
            $("#success-alert").slideUp(500);
          }, 3000);
        }
    });
}

//upload server cert
function uploadCert(input, sentForm){
  console.log("in upload cert");
  console.log("cert input" + input.files[0]);
  var base_url = window.location.origin;
  var form = document.forms.namedItem(sentForm);
  var fd = new FormData(form[0]);
  console.log("fd");
  console.log(fd);
  fd.append("file", input.files[0]);

  return $.ajax({
      type: 'POST',
      url: base_url + '/uploadServerCert',
      data: fd,
      dataType: 'json',
      processData: false,
      contentType: false,
      success: function(data){
        console.log("upload serv cert data: ");
        console.log(data);
        document.getElementById("https_cert_path").value = data.filePath;
        var filePath = data.filePath;
      },
      error: function(data){
        console.log(data);
        document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
        $("#success-alert").show();
        setTimeout(function(){
          $("#success-alert").slideUp(500);
        }, 3000);
      }
  });
}

// for eap only
function uploadCACert(input, sentForm){
    console.log("in upload ca cert");
    var base_url = window.location.origin;
    var form = document.forms.namedItem(sentForm);
    var fd = new FormData(form[0]);
    fd.append("file", input.files[0]);

    return $.ajax({
        type: 'POST',
        url: base_url + '/uploadCACert',
        dataType: 'json',
        success: function(data){
          console.log("upload ca success");
        },
        error: function(data){
          document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
          $("#success-alert").show();
          setTimeout(function(){
            $("#success-alert").slideUp(500);
          }, 3000);
        }
    });
}


function verifyCert(https_key_path, https_cert_path, qualifier){
  console.log(https_key_path + " " + https_cert_path + " " + qualifier );
  var base_url = window.location.origin;
  return $.ajax({
    type: 'POST',
    url: base_url + '/verifyCert/' + "?key_path=" + https_cert_path + "&cert_path=" + https_key_path + "&qualifier=" + qualifier,
    dataType: 'json',
    success: function(data){
      console.log("verifycert data: " );
      console.log(data);
      console.log("- - - - - - - - - - -");
      $("#https_serv_view_more").attr('data-content', data.CN_Server);
      document.getElementById('successMessage').innerHTML = "Successfully Updated.";
      $("#success-alert").show();
      setTimeout(function(){
        $("#success-alert").slideUp(500);
      }, 3000);
      if (qualifier == "https"){
        readCert("https");
      } else {
        readCert("eap");
      }
    },
    error: function(data){
      console.log(" verify cert not successful");
      console.log(data);
      document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
      $("#error-alert").show();
      setTimeout(function(){
        $("#error-alert").slideUp(500);
      }, 3000);
    }
  });
}

function readCert(qualifier){
    console.log("in read cert");
    var base_url = window.location.origin;
    return $.ajax({
        type: 'GET',
        url: base_url + '/readCert/' + "?qualifier=" + qualifier,
        success: function(data){
          console.log("readacert data: " );
          console.log(data);
          console.log("- - - - - - - - - - - - -");
          //https_key_view_more || https_serv_view_more,
          //eap_key_view_more || eap_serv_view_more || eap_ca_view_more
          if (qualifier == "https"){
            $("#https_serv_view_more").attr('data-original-title', data.CN_Server);
            $("#https_serv_view_more").attr('data-content', data.Server_INFO);
          } else {
            $("#eap_serv_view_more").attr('data-original-title', data.CN_Server);
            $("#eap_serv_view_more").attr('data-content', data.Server_INFO);
            $("#eap_ca_view_more").attr('data-original-title', data.CN_CA);
            $("#eap_ca_view_more").attr('data-content', data.CA_INFO);
          }
        },
        error: function(data){
          document.getElementById('errorMessage').innerHTML = "Failed to receive info about certificates/key.";
          $("#success-alert").show();
          setTimeout(function(){
            $("#success-alert").slideUp(500);
          }, 3000);
        }
    });
}

function removeCert(path){
    var filePath = path;

}

//eap, https, eap-ca option
function downloadCert(qualifier){
  var base_url = window.location.origin;
  var qualifier = "https";
  var path =
  $.ajax({
      type: 'GET',
      url: base_url + '/downloadCert/' + "?qualifier=" + qualifier,
      success: function(data){
        console.log("download cert pass");
        console.log(data);
      },
      error: function(data){
        console.log("download cert fail");
        console.log(data);
        console.log("- - - - - - - - - - - - ");
      }
    });

}
