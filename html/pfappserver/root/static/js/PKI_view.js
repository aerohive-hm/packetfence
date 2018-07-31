
$(document).ready(function(){
    var caNewlabel = document.createElement("Label");
      caNewlabel.setAttribute("for", "ca_cert_path_upload");
      caNewlabel.setAttribute("id", "ca_cert_label_upload");
      caNewlabel.innerHTML = "Choose File...";
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

    $(function () {
      $('[data-toggle="tooltip"]').tooltip()
    })

//***********for label after the upload button***************//
    var caSubjectVal = document.getElementById('ca_cert_subject').value;
    var servSubjectVal = document.getElementById('server_cert_subject').value;

    var caSubjNewlabel = document.createElement("Div");
    caSubjNewlabel.setAttribute("id", "caSubjNewlabel");
    var servSubjNewlabel = document.createElement("Div");
    servSubjNewlabel.setAttribute("id", "servSubjNewlabel");

    caSubjNewlabel.innerHTML = caSubjectVal;
    servSubjNewlabel.innerHTML = servSubjectVal;
    document.getElementById('ca_cert_label_upload').after(caSubjNewlabel); //add after upload button
    document.getElementById('server_cert_label_upload').after(servSubjNewlabel);

    var caLength = $("#caSubjNewlabel").width();
    var caTextLength = $("#ca_cert_subject").width();
    var servLength = $("#servSubjNewlabel").width();
    var servTextLength = $("#server_cert_subject").width();

    if (caTextLength > caLength) {
      document.getElementById('caSubjNewlabel').after("...");
      caSubjNewlabel.setAttribute("data-toggle", "tooltip");
      caSubjNewlabel.setAttribute("data-placement", "top");
      caSubjNewlabel.setAttribute("title", caSubjectVal);
    }
    if (servTextLength > servLength) {
      document.getElementById('servSubjNewlabel').after("...");
      servSubjNewlabel.setAttribute("data-toggle", "tooltip");
      servSubjNewlabel.setAttribute("data-placement", "top");
      servSubjNewlabel.setAttribute("title", servSubjectVal);
    }
  //*****************save button press pki********************//
    document.getElementById("savePKI").onclick = function(e){
        console.log("clicked on save");
        e.preventDefault();
        var caFile = document.getElementById('ca_cert_path_upload');
        var caFileExists = document.getElementById('ca_cert_path');
        var serverFile = document.getElementById('server_cert_path_upload');
        var serverFileExists = document.getElementById('server_cert_path');
        var pki_provider_name = document.getElementById("id");
        var pki_provider_id = $("input[name=id]").val();
        console.log(pki_provider_id);

        if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name != null) {
            //clone
            console.log("inside clone");
            var processCAFile2 = processFiles(caFile, pki_provider_name.value, 'CA');
            var processServFile2 = processFiles(serverFile, pki_provider_name.value, 'Server');
            if (caFile.value.length != 0 && serverFile.value.length != 0){
              if (showCaCertFileInfo() || showServerFileInfo()){
                  $.when(processCAFile2, processServFile2).done(function(caFilePath, servFilePath){
                      console.log(caFilePath[0].filePath); console.log(servFilePath[0].filePath);
                      if (caFilePath[1] == "success" || servFilePath[1] == "success"){
                          var ca_path = document.getElementById("ca_cert_path");
                          ca_path.value = caFilePath[0].filePath;
                          var server_path = document.getElementById("server_cert_path");
                          server_path.value = servFilePath[0].filePath;
                          $('form').submit();
                      }
                  });
              }
            } else { $('form').submit(); }
        } else if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name == null) {
            //updates
            console.log("inside update");

            //if only ca file update
            if (caFile.value.length != 0 && serverFile.value.length == 0){
                var processCAFile = processFiles(caFile, pki_provider_id, 'CA');
                if (showCaCertFileInfo() || showServerFileInfo()){
                    $.when(processCAFile).done(function(caFilePath){

                        if (caFilePath[1] == "success"){
                            var ca_path = document.getElementById("ca_cert_path");
                            ca_path.value = caFilePath[0].filePath;
                        }
                        $('form').submit();
                    });
                }else{
                   $('form').submit();
                }
            //if ionly serv file update
            } else if (caFile.value.length == 0 && serverFile.value.length != 0){
                var processServFile = processFiles(serverFile, pki_provider_id, 'Server');
                if (showServerFileInfo()){
                    $.when(processServFile).done(function(servFilePath){
                        if (servFilePath[1] == "success"){
                            var server_path = document.getElementById("server_cert_path");
                            server_path.value = servFilePath[0].filePath;
                        }
                        $('form').submit();
                    });
                }else{
                   $('form').submit();
                }
            //if both files updte
            } else if (caFile.value.length != 0 && serverFile.value.length != 0){
                var processCAFile = processFiles(caFile, pki_provider_id, 'CA');
                var processServFile = processFiles(serverFile, pki_provider_id, 'Server');
                if (showCaCertFileInfo() || showServerFileInfo()){
                    $.when(processCAFile, processServFile).done(function(caFilePath, servFilePath){

                        if (caFilePath[1] == "success" && servFilePath[1] == "success"){
                            var ca_path = document.getElementById("ca_cert_path");
                            ca_path.value = caFilePath[0].filePath;
                            var server_path = document.getElementById("server_cert_path");
                            server_path.value = servFilePath[0].filePath;
                        }
                        $('form').submit();
                    });
                }else{
                   $('form').submit();
                }
              //nothing updated
            } else { $('form').submit(); }
            //end of updates
        } else if ((caFile.value.length != 0 && serverFile.value.length != 0) && (caFileExists.value.length == 0 && serverFileExists.value.length == 0)){
            //create
            var processCAFile2 = processFiles(caFile, pki_provider_name.value, 'CA');
            var processServFile2 = processFiles(serverFile, pki_provider_name.value, 'Server');
            if (showCaCertFileInfo() && showServerFileInfo()){
                $.when(processCAFile2, processServFile2).done(function(caFilePath, servFilePath){
                    console.log(caFilePath[0].filePath); console.log(servFilePath[0].filePath);
                    if (caFilePath[1] == "success" && servFilePath[1] == "success"){
                        var ca_path = document.getElementById("ca_cert_path");
                        ca_path.value = caFilePath[0].filePath;
                        var server_path = document.getElementById("server_cert_path");
                        server_path.value = servFilePath[0].filePath;
                        $('form').submit();
                    }
                });
            }
        } else {
            document.getElementById('errorMessage').innerHTML = "Files are incorrect. Try uploading the files again.";
            $("#success-alert").show();
            setTimeout(function (){
              $("#success-alert").slideUp(500);
            }, 3000);
        }
    }; //end of save click button
});



function showServerFileInfo(){
    var input2,valueOfServCert;
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
        // alert("Please select a file before clicking 'Save'");
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
              document.getElementById("ca_cert_label_upload").innerHTML = 'Choose File...';
              alert("File size is greater than 1MB. Upload again.");
              return false;
            }
        } else {
            document.getElementById("ca_cert_label_upload").innerHTML = 'Choose File...';
            alert("Incorrect file type. Upload again.");
            return false;
        }
    }
}

function showCaCertFileInfo() {
    var input, valueOfCaCert;
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
        // alert("Please select a file before clicking 'Save'");
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

//test file size
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

//calls only when save button is pressed
function processFiles(input, pki_provider_name, qualifier){
    var base_url = window.location.origin;
    var form = document.forms.namedItem("modalItem");
    var fd = new FormData(form[0]);
    fd.append("file", input.files[0]);

    return $.ajax({
        type: 'POST',
        url: base_url + '/config/pki_provider/processCertificate/' + "scep?name=" + pki_provider_name + "&qualifier=" + qualifier,
        data: fd,
        dataType: 'json',
        processData: false,
        contentType: false,
        success: function(data){
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
    }); //end of ajax
}
