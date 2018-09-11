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
  var https_server_path = document.getElementById('https_cert_path');
  var eap_key_path      = document.getElementById('eap_key_path');
  var eap_server_path   = document.getElementById('eap_cert_path');
  var eap_ca_path       = document.getElementById('eap_cacert_path');

  document.getElementById("https-upload").onclick = function(e){
    e.preventDefault();
    // console.log("https key" + https_key.value);
    // console.log("https cert" + document.getElementById('https_serverCert_upload').value);

    if(https_key.files.length != 0 && https_server_cert.files.length != 0){
      uploadCertAndKey();
    } else {
      document.getElementById('errorMessage').innerHTML = "Upload both a key and certificate file.";
      $("#error-alert").show();
      setTimeout(function(){
        $("#error-alert").slideUp(500);
      }, 3000);
    }
  }

  // console.log("server cert value" + document.getElementById('https_cert_path').value);

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
  document.getElementById("download_button").onclick = function(e){
    console.log("pressing downloading");
    e.preventDefault();
    downloadCert("https", document.getElementById('https_cert_path').value);
  }
});

function uploadCertAndKey(){
  uploadCert(document.getElementById('https_serverCert_upload'), "https_form").then(function(https_cert_path){
      console.log("https_cert_path: "); console.log(https_cert_path); //gets cert path
      https_server_path = https_cert_path; //saving the path into here
      var uploadKeyFile  = uploadKey(document.getElementById('https_serverKey_upload'), "https_form");
      console.log("uploadKeyFile: "); console.log(uploadKeyFile);
      return uploadKeyFile;
  }, function(error){
      console.log("error on uploadCert");
      return;
  }).then(function(https_key_path){
      console.log("https_key_path: ");  console.log(https_key_path);
      var qualifier = "https";
      var verifyCertFile = verifyCert(https_server_path.filePath, https_key_path.filePath, qualifier);
      return verifyCertFile;
  }, function(error){
      console.log("error on uploadKey");
      removeCert(https_server_path.filePath);
      return;
  }).then(function(verified){
      console.log("verified"); console.log(verified);
  }, function(error){
      console.log("error on verifyCert");
      return;
  });
}

//upload key
function uploadKey(input, sentForm){
    console.log("in upload key");
    // console.log("key input" + input.files[0]);
    var https_server_path = https_server_path;
    // console.log("in upload key https_server_path: " + https_server_path);
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
          // console.log("uploadKey data: " );
          // console.log(data);
          // console.log("- - - - - - - - -");
          document.getElementById("https_key_path").value = data.filePath;
          var filePath = data.filePath;
        },
        error: function(data){
          // alert("did not go through");
          console.log("File for key is incorrect. Upload key file again.");
          console.log(data);
          document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
          $("#error-alert").show();
          setTimeout(function(){
            $("#error-alert").slideUp(500);
          }, 3000);
        }
    });
}

//upload server cert
function uploadCert(input, sentForm){
  console.log("in upload cert");
  // console.log("cert input" + input.files[0]);
  var base_url = window.location.origin;
  var form = document.forms.namedItem(sentForm);
  var fd = new FormData(form[0]);
  // console.log("fd");
  // console.log(fd);
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
        console.log("upload cert failed");
        console.log("dataaaaaaaa: "  + data);
        console.log("------------end of upload cert failed--------------");
        document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
        $("#error-alert").show();
        setTimeout(function(){
          $("#error-alert").slideUp(500);
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


function verifyCert(https_cert_path, https_key_path, qualifier){
  console.log("in verify cert");
  // console.log(https_key_path + " " + https_cert_path + " " + qualifier );
  var base_url = window.location.origin;
  return $.ajax({
    type: 'POST',
    url: base_url + '/verifyCert/' + "?cert_path=" + https_cert_path + "&key_path=" + https_key_path + "&qualifier=" + qualifier,
    dataType: 'json',
    success: function(data){
      // console.log("verifycert data: " );
      // console.log(data);
      // console.log("- - - - - - - - - - -");
      $("#https_serv_view_more").attr('data-content', data.CN_Server);
      document.getElementById('successMessage').innerHTML = data.status_msg;
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
      // console.log(data);
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
          // console.log("readacert data: " );
          // console.log(data);
          // console.log("- - - - - - - - - - - - -");
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
  console.log("in removeCert");
    var filePath = path;
    var base_url = window.location.origin;
    $.ajax({
        type: 'POST',
        url: base_url + '/removeCert/' + "?file_path=" + filePath,
        data: filePath,
        dataType: 'json',
        success: function(data){
          console.log("removed files");
        },
        error: function(data){
          console.log("couldn't remove files");

        }
    })
}

//eap, https, eap-ca option
function downloadCert(qualifier, path){
  console.log("in download cert");
  // console.log("path exists: " + path);
  var base_url    = window.location.origin;
  var fileName    = "server.crt";
  var qualifier   = "https";
  var contentType = "text/plain";
  $.ajax({
      type: 'GET',
      url: base_url + '/downloadCert/' + "?qualifier=" + qualifier,
      success: function(data){
        console.log("download cert pass");
        console.log(data);
        var cert_content = JSON.stringify(data);
        // var a = document.createElement("a");
        var file = new Blob([cert_content], {type: contentType});
        $('#download_button').href = URL.createObjectURL(file);
        $('#download_button').download = fileName;
        console.log("file: " + file);
        $('#download_button').click();
      },
      error: function(data){
        console.log("download cert fail");
        console.log(data);
        console.log("- - - - - - - - - - - - ");
        document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
        $("#error-alert").show();
        setTimeout(function(){
          $("#error-alert").slideUp(500);
        }, 3000);
      }
    });


}
