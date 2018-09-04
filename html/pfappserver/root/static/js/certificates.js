
$(document).ready(function(){
  // alert("js connected!");

  document.getElementById("certificate-upload").onclick = function(e){
      uploadKey();
  }

// uploadKey();

  // readCert();
  //
  // uploadCACert();
  //
  // uploadServerCert();

  document.getElementById("serverKey").onchange = function(){
    checkKey();
  };
  document.getElementById("serverCert").onchange = function(){
    checkCert();
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
          //text to change back to choose file
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

function uploadKey(){
    // alert("in process key");
    var base_url = window.location.origin;
    // var form = document.forms.namedItem();
    // var fd = new FormData(form[0]);
    // fd.append("file", input.files[0]);

    return $.ajax({
        type: 'POST',
        url: base_url + '/uploadKey',
        dataType: 'json',
        success: function(data){
          alert("post went through");
        },
        error: function(data){
          // alert("did not go through");
          console.log(data);
        }
    });
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
