
$(document).ready(function(){
  // alert("js connected!");

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

  document.getElementById("https-upload").onclick = function(e){
    e.preventDefault();
    //check which form it's on
    // if (){
    //   //https
    // uploadFile(); key  cert
    //  x2
    // } else if () {
    //   // eap_tls
    //  uploadFile(); eap key, eap sercert, eap ca cert
    //  x3
    // }
    console.log("https key" + https_key.value);
    console.log("https cert" + document.getElementById('https_serverCert_upload').value);
    // console.log("https servercert" + https_server_cert.value);
    // console.log("eap key" + eap_key.value);
    // console.log("eap server" + eap_server_cert.value);
    // console.log("eap ca " + eap_ca_cert.value);

    //add promise, upload key then upload cert
    // then call verify files

    // uploadFile(https_key);
    // uploadCert(https_server_cert);
    $.when(uploadCert(document.getElementById('https_serverCert_upload')),uploadKey(https_key)).done(function(https_path, https_server_cert){
        console.log(https_path[0].filePath); console.log(https_server_cert[0].filePath);
        var qualifier = "https";
        verifyCert(https_path[0].filePath,https_server_cert[0].filePath, qualifier);
    });

  }


  //view more link
  view_more_link.onclick = function(){
     //ppop up bubble with info
  }
 // uploadKey();

  // readCert();
  //
  // uploadCACert();
  //
  // uploadServerCert();

  document.getElementById("serverKey").onchange = function(){
    // checkKey();
    var servKey = document.getElementById('serverKey');
    alert("upload key value" + servKey.value);
  };
  document.getElementById('https_serverCert_upload').onchange = function(){
    var cert = document.getElementById('https_serverCert_upload');
    alert("upload cert value" + cert.value);
  };

  var servKey = document.getElementById('serverKey');
  var servKeyExists = document.getElementById('serverKey_path');
  var serverFile = document.getElementById('serverCert');
  var serverFileExists = document.getElementById('serverCert_path');
  console.log(servKey);
  console.log(serverFile);
  // if (servKeyExists.value.length != 0 && serverFile)
});


function checkKey(){
  var key,valueOfKey;
  var keyFile, keyFileType, keyFileSize;

  if (!window.FileReader){
    alert("The File API isn't supported on this browser please change to Google Chrome.");
    return;
  }

  key = document.getElementById("serverKey_upload");
  if (!key) {
    alert("Couldn't find the file input element.");
  }
  else if (!key.files) {
    alert("This browser doesn't support the `files` property of file inputs.");
  }
  else if (!key.files[0]) {

  } else {
    keyFile = key.files[0];
    keyFileType = key.type;
    keyFileSize = key.size/1024;
    if (keyTypeValidation(key)){
      if (keySizeValidation(key)){
        var keyFileName = '';
        fileName = key.files[0].name;
        document.getElementById("serverKey_upload").innerHTML = fileName;
        return true;
      } else {
          alert("Key is incorrect, upload again.");
      }
    } else {
    }
  }
}

function checkCert(){
  var cert,valueOfCert;
  var certFile, certFileType, certFileSize;

  if (!window.FileReader){
    alert("The File API isn't supported on this browser please change to Google Chrome.");
    return;
  }

  cert = document.getElementById("serverCert_upload");
  if (!cert) {
    alert("Couldn't find the file input element.");
  }
  else if (!cert.files) {
    alert("This browser doesn't support the `files` property of file inputs.");
  }
  else if (!cert.files[0]) {

  } else {
    certFile = cert.files[0];
    certFileType = cert.type;
    certFileSize = cert.size/1024;
    if (certTypeValidation(cert)){
      if (certSizeValidation(cert)){
        var certFileName = '';
        fileName = cert.files[0].name;
        document.getElementById("serverCert_upload").innerHTML = fileName;
        return true;
      } else {
          //text to change back to choose file
          alert("Certificate is incorrect, upload again.");
      }
    } else {
      alert("Certificate is incorrect, upload again.");

    }
  }
}

function certTypeValidation(input){
    var certFilePath = input.value;
    var allowedExtensions = /(\.pem)$/i;
    if(!allowedExtensions.exec()){
        input.value = '';
        return false;
    } else {
        return true;
    }
}
function keyTypeValidation(input){
    alert ("in key type valid");
    var certFilePath = input.value;
    var allowedExtensions = /(\.key)$/i;
    if(!allowedExtensions.exec()){
        input.value = '';
        return false;
    } else {
        return true;
    }
}

function certSizeValidation(input){
    alert ("in cert size valid");
    var fileSize = input.files[0].size/1024/1024;
    if (fileSize > 1){
       $(input).val('');
       return false;
    } else {
       return true;
    }
}

function keySizeValidation(input){
    alert ("in key size valid");
    var fileSize = input.files[0].size/1024/1024;
    if (fileSize > 0.08) {
      $(input).val('');
      return false;
    } else {
      return true;
    }
}

function uploadCert(input){
  alert("in upload cert");
  console.log("cert input" + input.files[0]);
  var base_url = window.location.origin;
  var form = document.forms.namedItem('https_form');
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
        alert("post went through");
        console.log("data: ");
        console.log(data);
        document.getElementById("https_cert_path").value = data.filePath;
        var filePath = data.filePath;
      },
      error: function(data){
        console.log(data);
      }
  });
}

function uploadKey(input){
    alert("in process key");
    console.log("key input" + input.files[0]);
    var base_url = window.location.origin;
    var form = document.forms.namedItem('https_form');
    var fd = new FormData(form[0]);
    console.log("fd");
    console.log(fd);
    fd.append("file", input.files[0]);

    return $.ajax({
        type: 'POST',
        url: base_url + '/uploadKey',
        data: fd,
        dataType: 'json',
        processData: false,
        contentType: false,
        success: function(data){
          alert("post went through");
          console.log("data: ");
          console.log(data);
          document.getElementById("https_key_path").value = data.filePath;
          var filePath = data.filePath;
        },
        error: function(data){
          // alert("did not go through");
          console.log(data.responseJSON.status_msg);
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
      alert("went through");
      console.log(data);
    },
    error: function(data){
      alert("not successful");
      console.log(data);
    }
  })
}


// function readCert(){
//     // alert("in process key");
//     var base_url = window.location.origin;
//     // var form = document.forms.namedItem();
//     // var fd = new FormData(form[0]);
//     // fd.append("file", input.files[0]);
//
//     return $.ajax({
//         type: 'POST',
//         url: base_url + '/readCert',
//         dataType: 'json',
//         success: function(data){
//           alert("post went through");
//         },
//         error: function(data){
//           alert("did not go through");
//         }
//     });
// }
//
//
// function uploadCACert(){
//     // alert("in process key");
//     var base_url = window.location.origin;
//     // var form = document.forms.namedItem();
//     // var fd = new FormData(form[0]);
//     // fd.append("file", input.files[0]);
//
//     return $.ajax({
//         type: 'POST',
//         url: base_url + '/uploadCACert',
//         dataType: 'json',
//         success: function(data){
//           alert("post went through");
//         },
//         error: function(data){
//           alert("did not go through");
//         }
//     });
// }
//
// function uploadServerCert(){
//     // alert("in process key");
//     // var form = document.forms.namedItem();
//     // var fd = new FormData(form[0]);
//     // fd.append("file", input.files[0]);
//     var base_url = window.location.origin;
//
//     return $.ajax({
//         type: 'POST',
//         url: base_url + '/uploadServerCert',
//         dataType: 'json',
//         success: function(data){
//           alert("post went through");
//         },
//         error: function(data){
//           alert("did not go through");
//         }
//     });
// }

// function processServerCert(){
//     alert("in process server");
// }
//
// function processCACert(){
//     alert("in process ca");
// }
