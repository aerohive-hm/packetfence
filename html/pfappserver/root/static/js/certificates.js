
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

    https_key.onchange = function(){
      if (!keyTypeValidation(https_key) || !keySizeValidation(https_key)){
        $(https_key).val('');
      }
    };
    https_server_cert.onchange = function(){
      if (!certTypeValidation(https_server_cert) || !certSizeValidation(https_server_cert)){
        $(https_server_cert).val('');
      }
    };
    eap_key.onchange = function(){
      if (!keyTypeValidation(eap_key) || !keySizeValidation(eap_key)){
        $(eap_key).val('');
      }
    };
    eap_server_cert.onchange = function(){
      if (!certTypeValidation(eap_server_cert) || !certSizeValidation(eap_server_cert)){
        $(eap_server_cert).val('');
      }
    };
    eap_ca_cert.onchange = function(){
      if (!certTypeValidation(eap_ca_cert) || !certSizeValidation(eap_ca_cert)){
        $(eap_ca_cert).val('');
      }
    };

    //if https form button click
    document.getElementById("https-upload").onclick = function(e){
        e.preventDefault();

        if(https_key.files.length != 0 && https_server_cert.files.length != 0){
            uploadCertAndKey(https_server_cert, https_key, "https_form", "https", document.getElementById('caCert_upload'));
            // uploadCACert(document.getElementById('caCert_upload'));
        } else {
            document.getElementById('errorMessage').innerHTML = "Upload both a key and certificate file.";
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        }
    }
    //if eap form button click
    document.getElementById("eap-upload").onclick = function(e){
        e.preventDefault();
        if (eap_ca_cert.value == ""){
            if(eap_key.files.length != 0 && eap_server_cert.files.length != 0){
                uploadCertAndKey(eap_server_cert, eap_key, "eap_tls_form", "eap", document.getElementById('caCert_upload'));
            } else {
            document.getElementById('errorMessage').innerHTML = "Upload both a key and certificate file.";
            $("#error-alert").show();
                setTimeout(function(){
                    $("#error-alert").slideUp(500);
                }, 3000);
            }
        } else {
            uploadCertAndKey(eap_server_cert, eap_key, "eap_tls_form", "eap", document.getElementById('caCert_upload'));
        }
    }

    //DOWNLOAD
    document.getElementById("download_button_https").addEventListener("click", function(e){
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

//API call to run server cert and key together first before ca file upload if ca exist
function uploadCertAndKey(server_cert_upload, key_upload, form, qualifier, ca_file_upload){
    if (ca_file_upload.files.length != 0){
        uploadCACert(ca_file_upload, form, qualifier);
    }

    uploadCert(server_cert_upload, form).then(function(cert_path){
        var uploadKeyFile;
        if (qualifier == "https"){
            https_server_path = cert_path;
            uploadKeyFile = uploadKey(key_upload, form, https_server_path.filePath);
        } else {
            eap_server_path = cert_path;
            uploadKeyFile = uploadKey(key_upload, form, eap_server_path.filePath);
        }
        return uploadKeyFile;
    }, function(error){
        return;
    }).then(function(key_path, cert_path){
        if (qualifier == "https"){
            var verifyCertFile = verifyCert(https_server_path.filePath, key_path.filePath, qualifier);
        } else {
            var verifyCertFile = verifyCert(eap_server_path.filePath, key_path.filePath, qualifier);
        }
        return verifyCertFile;
    }, function(error){
        if (cert_path === "undefined"){
            return;
        } else {
            removeCert(cert_path.filePath);
        }
        return;
    }).then(function(verified){
        $('input').val('');
    }, function(error){
        $('input').val('');
        return;
    });

}

//upload key
function uploadKey(input, sentForm, cert_path){
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
            document.getElementById("https_key_path").value = data.filePath;
            var filePath = data.filePath;
        },
        error: function(data){
            removeCert(cert_path);
            $('input').val('');
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
            document.getElementById("https_cert_path").value = data.filePath;
            var filePath = data.filePath;
        },
        error: function(data){
            document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        }
    });
}

// for eap only
function uploadCACert(input, sentForm, qualifier){
    var base_url = window.location.origin;
    var form = document.forms.namedItem(sentForm);
    var fd = new FormData(form[0]);
    fd.append("file", input.files[0]);

    return $.ajax({
        type: 'POST',
        url: base_url + '/uploadCACert',
        data: fd,
        dataType: 'json',
        processData: false,
        contentType: false,
        success: function(data){
            readCert(qualifier);
            document.getElementById('successMessage').innerHTML = data.status_msg;
            $("#success-alert").show();
            setTimeout(function(){
                $("#success-alert").slideUp(500);
            }, 3000);
            // document.getElementById("https_cert_path").value = data.filePath;
            // var filePath = data.filePath;
        },
        error: function(data){
            document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        }
    });
}

//verify if the server cert and key are matching
function verifyCert(https_cert_path, https_key_path, qualifier){
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
          document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
          $("#error-alert").show();
          setTimeout(function(){
              $("#error-alert").slideUp(500);
          }, 3000);
      }
  });
}

//gives information about the current certs existing
function readCert(qualifier){
    var base_url = window.location.origin;
    return $.ajax({
        type: 'GET',
        url: base_url + '/readCert/' + "?qualifier=" + qualifier,
        success: function(data){
            //https_key_view_more || https_serv_view_more,
            //eap_key_view_more || eap_serv_view_more || eap_ca_view_more
            if (qualifier == "https"){
                var Server_INFO = data.Server_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
                document.getElementById('https_serv_view_more').innerHTML = data.CN_Server + '<br><br>' + Server_INFO;
            } else {
                var Server_INFO = data.Server_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
                var CA_INFO = data.CA_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
                document.getElementById('eap_serv_view_more').innerHTML = data.CN_Server + '<br><br>' + Server_INFO;
                if (data.CN_CA != null ){
                    document.getElementById('eap_ca_view_more').innerHTML = data.CN_CA + '<br><br>' + CA_INFO;
                }
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

//will remove the server cert if the key is empty
function removeCert(path){
    var filePath = path;
    var base_url = window.location.origin;
    $.ajax({
        type: 'POST',
        url: base_url + '/removeCert/' + "?file_path=" + filePath,
        data: filePath,
        dataType: 'json',
        success: function(data){
        },
        error: function(data){
        }
    })
}

//DOWNLOAD
function downloadFile (fileName, data){

    var element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(data.Cert_Content));
    element.setAttribute('download', fileName);

    element.style.display = 'none';
    document.body.appendChild(element);
    element.click();

    document.body.removeChild(element);
}

//eap, https, eap-ca option
function downloadCert(qualifier){
    var base_url    = window.location.origin;
    var dataType = "json";
    return $.ajax({
        type: 'GET',
        url: base_url + '/downloadCert/' + "?qualifier=" + qualifier,
        success: function(data){
        },
        error: function(data){
            document.getElementById('errorMessage').innerHTML = data.responseJSON.status_msg;
            $("#error-alert").show();
            setTimeout(function(){
              $("#error-alert").slideUp(500);
            }, 3000);
        }
    });
}

//test file types
function certTypeValidation(input){
    var filePath = input.value;
    var certAllowedExtensions = /(\.pem|\.crt|\.cer)$/i;
    if(!certAllowedExtensions.exec(filePath)){
        // input.value = '';
        document.getElementById('errorMessage').innerHTML = "Upload a file with the extension: .pem/.crt/.cer .";
        $("#error-alert").show();
        setTimeout(function(){
            $("#error-alert").slideUp(500);
        }, 3000);
        return false;
    }else{
        return true;
    }
}

function keyTypeValidation(input){
    var filePath = input.value;
    var keyAllowedExtensions = /(\.key)$/i;
    if(!keyAllowedExtensions.exec(filePath)){
        document.getElementById('errorMessage').innerHTML = "Upload a file with the extension: .key ";
        $("#error-alert").show();
        setTimeout(function(){
            $("#error-alert").slideUp(500);
        }, 3000);
        return false;
    }else{
        return true;
    }
}

//test file size
function certSizeValidation(input){
    var fileSize = input.size/1024/1024;
    if (fileSize > 1){
        // $(input).val('');
        document.getElementById('errorMessage').innerHTML = "File size is bigger than 1MB.";
        $("#error-alert").show();
        setTimeout(function(){
            $("#error-alert").slideUp(500);
        }, 3000);
        return false;
    }
    else{
        return true;
    }
}

function keySizeValidation(input){
    var fileSize = input.files[0].size/1024/1024;
    if (fileSize > 0.008){
        document.getElementById('errorMessage').innerHTML = "File size is bigger than 0.008MB.";
        $("#error-alert").show();
        setTimeout(function(){
            $("#error-alert").slideUp(500);
        }, 3000);
        return false;
    }
    else {
        return true;
    }
}
