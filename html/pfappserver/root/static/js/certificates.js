
$(document).ready(function(){
  processFiles();

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
  if (servKeyExists.value.length != 0 && serverFile)
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
    if (fileTypeValidation(key)){
      if (fileSizeValidation(key)){
        var keyFileName = '';
        fileName = key.files[0].name;
        document.getElementById("serverKey_upload").innerHTML = fileName;
        return true;
      } else {
          //text to change back to choose file
          alert("");
      }
    }else{

    }
  }

}

function checkCert(){
  var cert,valueOfCert;
  var certFile, certFileType, certFileSize;
}



function processFiles(){
    alert("in process files");
    var base_url = window.location.origin;
    return $.ajax({
        type: 'POST',
        url: base_url + '/uploadKey'
        dataType: 'json',
        success: function(data){
          alert("post went through");
        },
        error: function(data){
          alert("did not go through");
        }
    });
}
