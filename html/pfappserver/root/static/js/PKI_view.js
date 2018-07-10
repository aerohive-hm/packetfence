
$(document).ready(function(){
  var caNewlabel = document.createElement("Label");
    caNewlabel.setAttribute("for", "ca_cert_path_upload");
    caNewlabel.setAttribute("id", "ca_cert_label_upload");
    caNewlabel.innerHTML = "Upload File";
  $("#ca_cert_path_upload").after(caNewlabel);
  var servNewlabel = document.createElement("Label");
    servNewlabel.setAttribute("for", "server_cert_path_upload");
    servNewlabel.setAttribute("id", "server_cert_label_upload");
    servNewlabel.innerHTML = "Choose File...";
  $("#server_cert_path_upload").after(servNewlabel);

  document.getElementById("ca_cert_path_upload").onchange = function(){
    showCaCertFileInfo();
  };
  document.getElementById("server_cert_path_upload").onchange = function(){
    showServerFileInfo();
  };

//check if input ca_text value is empty
  var input = document.getElementById('ca_cert_path');
  var input2 = document.getElementById('ca_cert_path');
  if(input.value.length == 0){ console.log("CA EMPTY"); }
  else{ console.log("CA NOT EMPTY"); }
  if(input2.value.length == 0){ console.log("SERV EMPTY"); }
  else{ console.log("SERV NOT EMPTY"); }

  document.getElementById("savePKI").onclick = function(e){
      e.preventDefault();
      var caFile = document.getElementById('ca_cert_path_upload');
      var serverFile = document.getElementById('server_cert_path_upload');
      var pki_provider_name = document.getElementById("id").value;

      if (showCaCertFileInfo()){
        if (showServerFileInfo()){
           processFiles(caFile, pki_provider_name, 'CA');
           processFiles(serverFile, pki_provider_name, 'Server');
         }
      }
  };
});



function showServerFileInfo(){
  var input2;
  var file2;
  var fileType2, fileSize2;

  if (!window.FileReader) {
      alert("The File API isn't supported on this browser please change to Google Chrome.");
      return;
  }

  input2 = document.getElementById('server_cert_path_upload');
  if (!input2) {
      alert("Couldn't find the file input element.");
  }
  else if (!input2.files) {
      alert("This browser doesn't support the `files` property of file inputs.");
  }
  else if (!input2.files[0]) {
      alert("Please select a file before clicking 'Save'");
  }
  else {
      file2 = input2.files[0];
      fileType2 = file2.type;
      fileSize2 = file2.size/1024;

      if (fileTypeValidation(input2)){
          if (fileSizeValidation(input2)){
            // append file name
            var fileName = '';
            fileName = input2.files[0].name;
            document.getElementById("server_cert_label_upload").innerHTML = fileName;
            return true;
          } else {
            alert("File size is greater than 1MB. Upload again.");
            return false;
          }
      } else {
          alert("Incorrect file type. Upload again.");
          return false;
      }
  }
}

function showCaCertFileInfo() {
    var input;
    var file;
    var fileType,fileSize;

    if (!window.FileReader) {
        alert("The File API isn't supported on this browser please change to Google Chrome.");
        return;
    }

    input = document.getElementById('ca_cert_path_upload');
    if (!input) {
        alert("Couldn't find the file input element.");
    }
    else if (!input.files) {
        alert("This browser doesn't support the `files` property of file inputs.");
    }
    else if (!input.files[0]) {
        alert("Please select a file before clicking 'Save'");
    }
    else {

        if (fileTypeValidation(input)){
            if (fileSizeValidation(input)){
              var fileName = '';
              fileName = input.files[0].name;
              document.getElementById("ca_cert_label_upload").innerHTML = fileName;
              return true;
            } else {
              document.getElementById("ca_cert_label_upload").innerHTML = 'Choose File...';
              alert("File size is greater than 1MB. Upload again.");
              return false;
            }
        } else {
            alert("Incorrect file type. Upload again.");
            document.getElementById("ca_cert_label_upload").innerHTML = 'Choose File...';
            return false;
        }
    }

}

//test file types
function fileTypeValidation(input){
    var filePath = input.value;
    var allowedExtensions = /(\.pem)$/i;
    if(!allowedExtensions.exec(filePath)){
        input.value = '';
        return false;
    }else{
        return true;
    }
}

function fileSizeValidation(input){
    var fileSize = input.files[0].size/1024/1024;
    if (fileSize > 1){
        $(input).val('');
        return false;
    }
    else{
        return true;
    }
}

//call only when save button is pressed

function processFiles(input, pki_provider_name, qualifier){
    var base_url = window.location.origin;
    var form = document.forms.namedItem("modalItem");
    var fd = new FormData(form[0]);
    fd.append("file", input.files[0]);
    $.ajax({
        type: 'POST',
        url: base_url + '/config/pki_provider/processCertificate/' + "scep?name=" + pki_provider_name + "&qualifier=" + qualifier,
        data: fd,
        dataType: 'json',
        processData: false,
        contentType: false,
        success: function(data){
          var filePath = data.filePath;
          if (qualifier === "CA"){
            var ca_path = document.getElementById("ca_cert_path");
            ca_path.value = filePath;
          } else if (qualifier === "Server") {
            var server_path = document.getElementById("server_cert_path");
            server_path.value = filePath;
          } else{
            console.log("does not exist");
          }
          $('form').submit();
        },
        error: function(data){
          var errMsg = data.status_msg;
          if (errMsg != null ) {
              document.getElementById('errorMessage').innerHTML = errMsg;
              $("#success-alert").show();
              setTimeout(function (){
                $("#success-alert").slideUp(500);
              }, 3000);
          }
        }
    });
}
