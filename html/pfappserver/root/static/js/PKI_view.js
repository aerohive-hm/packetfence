
$(document).ready(function(){

    // button settings
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

    //view more links
    var caViewMore = document.createElement("A");
        caViewMore.setAttribute("id", "ca_view_more");
        caViewMore.setAttribute("data-toggle", "popover");
        caViewMore.setAttribute("data-placement", "top");
        // caViewMore.setAttribute("data-trigger","focus");
        caViewMore.setAttribute("tab-index", "5");
        caViewMore.innerHTML = "View Current CA Certificate";

    var servViewMore = document.createElement("A");
        servViewMore.setAttribute("id", "serv_view_more");
        servViewMore.setAttribute("data-toggle", "popover");
        servViewMore.setAttribute("data-placement", "top");
        // servViewMore.setAttribute("data-trigger","focus");
        servViewMore.setAttribute("tab-index", "5");
        servViewMore.innerHTML = "View Current Server Certificate";

    //dl buttons
    // var caNewlabel = document.createElement("Button");
    // var caNewlabel = document.createElement("Button");
    // var caCertPopup = document.createElement("");
    // var caNewlabel = document.createElement("Button");

    document.getElementById('ca_cert_label_upload').after(caViewMore);
    document.getElementById('server_cert_label_upload').after(servViewMore);

    document.getElementById("ca_cert_path_upload").onchange = function(){
      showCaCertFileInfo();
    };
    document.getElementById("server_cert_path_upload").onchange = function(){
      showServerFileInfo();
    };


//*********** info for view more ***************//
    var caSubjectVal = document.getElementById('ca_cert_subject').value;
    var servSubjectVal = document.getElementById('server_cert_subject').value;

    caViewMore.setAttribute("data-content", caSubjectVal);
    servViewMore.setAttribute("data-content", servSubjectVal);


//*****************save button press pki********************//
    document.getElementById("savePKI").onclick = function(e){
        e.preventDefault();
        var caFile = document.getElementById('ca_cert_path_upload');
        var caFileExists = document.getElementById('ca_cert_path');
        var serverFile = document.getElementById('server_cert_path_upload');
        var serverFileExists = document.getElementById('server_cert_path');
        var pki_provider_name = document.getElementById("id");
        var pki_provider_id = $("input[name=id]").val();
        // if (pki_provider_name.value != ""){
            // if ((/\s/g.test(pki_provider_name.value) == false) || /\s/g.test(pki_provider_name.value) == false ){
              if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name != null) {
                  //clone
                  var processCAFile2 = processFiles(caFile, pki_provider_name.value, 'CA');
                  var processServFile2 = processFiles(serverFile, pki_provider_name.value, 'Server');
                  if (caFile.value.length != 0 && serverFile.value.length != 0){
                      if (showCaCertFileInfo() || showServerFileInfo()){
                          $.when(processCAFile2, processServFile2).done(function(caFilePath, servFilePath){
                              if (caFilePath[1] == "success" || servFilePath[1] == "success"){
                                  var ca_path = document.getElementById("ca_cert_path");
                                  ca_path.value = caFilePath[0].filePath;
                                  var server_path = document.getElementById("server_cert_path");
                                  server_path.value = servFilePath[0].filePath;
                                  //if pki name doesn't exist
                                  $('form').submit();
                              }
                          });
                      }
                  } else { $('form').submit(); }
              } else if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name == null) {
                  //updates

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
        // }//end of if to check if pki name has a blank space
        // } else {
            //err msg for if pki name is blank
        // }
    }; //end of save click button

    //initiate popover
    $("#ca_view_more").popover();
    $("#serv_view_more").popover();


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
              document.getElementById("server_cert_label_upload").innerHTML = 'Choose File...';
              alert("File size is greater than 1MB. Upload again.");
              return false;
            }
        } else {
            document.getElementById("server_cert_label_upload").innerHTML = 'Choose File...';
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
              $(input).val('');
              document.getElementById("ca_cert_label_upload").innerHTML = 'Choose File...';
              alert("File size is greater than 1MB. Upload again.");
              return false;
            }
        } else {
            $(input).val('');
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
    // var form = document.forms.namedItem("modalItem");
    var form = $('#modalItem').get(0);
    var fd = new FormData();
    fd.append('file', $('input[type=file]')[0].files[0]);

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
          var errMsg = data.responseJSON.status_msg;
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
