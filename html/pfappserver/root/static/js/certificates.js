//TO-DO
//downloadcert

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

    if(https_key.files.length != 0 && https_server_cert.files.length != 0){
      uploadCertAndKey(https_server_cert, https_key, "https_form", "https", eap_ca_cert);
    } else {
      document.getElementById('errorMessage').innerHTML = "Upload both a key and certificate file.";
      $("#error-alert").show();
      setTimeout(function(){
        $("#error-alert").slideUp(500);
      }, 3000);
    }
  }

  document.getElementById("eap-upload").onclick = function(e){
    e.preventDefault();
    if (eap_ca_cert.value == ""){
      console.log("ca is empty");
      if(eap_key.files.length != 0 && eap_server_cert.files.length != 0){
        uploadCertAndKey(eap_server_cert, eap_key, "eap_tls_form", "eap", eap_ca_cert);
      } else {
        document.getElementById('errorMessage').innerHTML = "Upload both a key and certificate file.";
        $("#error-alert").show();
        setTimeout(function(){
          $("#error-alert").slideUp(500);
        }, 3000);
      }
    } else {
      console.log("ca is not empty");
      if(eap_key.files.length != 0 && eap_server_cert.files.length != 0){
        uploadCertAndKey(eap_server_cert, eap_key, "eap_tls_form", "eap", document.getElementById('caCert_upload'));
      } else {
        document.getElementById('errorMessage').innerHTML = "Upload both a key and certificate file.";
        $("#error-alert").show();
        setTimeout(function(){
          $("#error-alert").slideUp(500);
        }, 3000);
      }
    }
  }

  //DOWNLOAD
  document.getElementById("download_button_https").addEventListener("click", function(e){
    console.log("inside add eventlistener click");
    e.preventDefault();
    $.when(downloadCert("https")).done(function(downloadFileInfo){
      downloadFile("server.crt", downloadFileInfo);
    });
  }, false);

  document.getElementById("download_button_eap_serv").addEventListener("click", function(e){
    e.preventDefault();
    $.when(downloadCert("eap")).done(function(downloadFileInfo){
      downloadFile("eap-server.crt", downloadFileInfo);
    });
  }, false);

  document.getElementById("download_button_eap_ca").addEventListener("click", function(e){
    e.preventDefault();
    $.when(downloadCert("eap-ca")).done(function(downloadFileInfo){
      downloadFile("ca.pem", downloadFileInfo);
    });
  }, false);

});

function uploadCertAndKey(server_cert_upload, key_upload, form, qualifier, ca_file_upload){
  uploadCert(server_cert_upload, form).then(function(cert_path){
      console.log("server_cert_upload: "); console.log(server_cert_upload);
      console.log("cert_path: "); console.log(cert_path); //gets cert path
      if (qualifier == "https"){
        https_server_path = cert_path;
      } else {
        eap_server_path = cert_path;
      }
      var uploadKeyFile  = uploadKey(key_upload, form);
      console.log("key_upload: "); console.log(key_upload);
      console.log("uploadKeyFile: "); console.log(uploadKeyFile);
      return uploadKeyFile;
  }, function(error){
      console.log("error on uploadCert");
      return;
  }).then(function(key_path, cert_path){
      console.log("key_path: ");  console.log(key_path);
      if (qualifier == "https"){
        var verifyCertFile = verifyCert(https_server_path.filePath, key_path.filePath, qualifier);
      } else {
        var verifyCertFile = verifyCert(eap_server_path.filePath, key_path.filePath, qualifier);
      }
      return verifyCertFile;
  }, function(error){
      console.log("error on uploadKey");
      removeCert(cert_path.filePath);
      return;
  }).then(function(verified){
      console.log("verified"); console.log(verified);
      //if ca file caFileExists --> uploadCA Cert --> get path
      if (ca_file_upload.files.length != 0){
        console.log("ca_file_upload: "); console.log(ca_file_upload);
        return uploadCACert(ca_file_upload, form);
      } else {
        return;
      }
      //else don't even call upload CA Cert-- > return some error messages
  }, function(error){
      console.log("error on verifyCert");
      return;
  }).then(function(eap_ca_cert_path){
      console.log("eap_ca_cert_path: "); console.log(eap_ca_cert_path);
      readCert("eap");
  },function(error){
      console.log("ERROOORRR");

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
  console.log("input"); console.log(input.value);
  var base_url = window.location.origin;
  var form = document.forms.namedItem(sentForm);
  var fd = new FormData(form[0]);
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
        // console.log("upload cert failed");
        // console.log("dataaaaaaaa: "  + data);
        // console.log("------------end of upload cert failed--------------");
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
    console.log("input"); console.log(input.value);
    var base_url = window.location.origin;
    var form = document.forms.namedItem(sentForm);
    var fd = new FormData(form[0]);
    fd.append("file", input.files[0]);

    var xhr = new XMLHttpRequest;
    xhr.open('POST', base_url + '/uploadCACert' , true);
    xhr.send(fd);
}


function verifyCert(https_cert_path, https_key_path, qualifier){
  console.log("in verify cert");
  var base_url = window.location.origin;
  return $.ajax({
    type: 'POST',
    url: base_url + '/verifyCert/' + "?cert_path=" + https_cert_path + "&key_path=" + https_key_path + "&qualifier=" + qualifier,
    dataType: 'json',
    success: function(data){
      $("#https_serv_view_more").innerHTML = data.CN_Server;
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
            var Server_INFO = data.Server_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
            document.getElementById('https_serv_view_more').innerHTML = data.CN_Server + '<br><br>' + Server_INFO;
          } else {
            var Server_INFO = data.Server_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
            var CA_INFO = data.CA_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
            document.getElementById('eap_serv_view_more').innerHTML = data.CN_Server + '<br><br>' + Server_INFO;
            document.getElementById('eap_ca_view_more').innerHTML = data.CN_CA + '<br><br>' + CA_INFO;
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

function downloadFile (fileName, data){
  console.log("download file");
  console.log(data);
  data = JSON.stringify(data.Cert_Content)
  data = data.replace(/\\n/g,"\n").replace(/"/g,"");
  console.log('- - - - - - -- - - ');
  var element = document.createElement('a');
  element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(data));
  element.setAttribute('download', fileName);

  element.style.display = 'none';
  document.body.appendChild(element);
  element.click();

  document.body.removeChild(element);
}

//eap, https, eap-ca option
function downloadCert(qualifier){
  console.log("in download cert");
  var base_url    = window.location.origin;
  var contentType = "text/plain";
  return $.ajax({
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
        document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
        $("#error-alert").show();
        setTimeout(function(){
          $("#error-alert").slideUp(500);
        }, 3000);
      }
    });
}
