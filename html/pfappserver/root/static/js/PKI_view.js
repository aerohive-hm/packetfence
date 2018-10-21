
$(document).ready(function(){

// variables
    var caFile = document.getElementById('ca_cert_path_upload');
    var caFileExists = document.getElementById('ca_cert_path');
    var serverFile = document.getElementById('server_cert_path_upload');
    var serverFileExists = document.getElementById('server_cert_path');
    var pki_provider_name = document.getElementById("id");
    var pki_provider_id = $("input[name=id]").val();

//change styling and add new html elements
    caFile.setAttribute("class", "btn");
    serverFile.setAttribute("class", "btn");

    //view more popovers
    var caViewMore = document.createElement("A");
        caViewMore.setAttribute("id", "ca_view_more");
        caViewMore.setAttribute("data-toggle", "popover");
        caViewMore.setAttribute("data-placement", "top");
        caViewMore.innerHTML = "View Current CA Certificate";
        caViewMore.setAttribute("style", "padding-left:20px;");

    var servViewMore = document.createElement("A");
        servViewMore.setAttribute("id", "serv_view_more");
        servViewMore.setAttribute("data-toggle", "popover");
        servViewMore.setAttribute("data-placement", "top");
        servViewMore.innerHTML = "View Current Server Certificate";
        servViewMore.setAttribute("style", "padding-left:20px;");

        //if the file path exists (clone or update), then append view more link after
        if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0)){
            $("#ca_cert_path_upload").after(caViewMore);
            $("#server_cert_path_upload").after(servViewMore);
        }

//*********** info for view more ***************//
        var caSubjectVal = caFileExists.value;
        var servSubjectVal = serverFileExists.value;

    $('input[type=file]').on('change', function(){
        console.log("in input onchange: ");
        verifyFile(this);
    });

//*****************save button press pki********************//
    document.getElementById("savePKI").addEventListener('click', function (e){
        console.log("button press!");
        e.preventDefault();
        e.stopPropagation();
        //for update and clone

        if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name != null) {
        //for clone
            var cloneCAFile = updateCloneFiles(caFile, pki_provider_name.value, 'CA');
            var cloneServFile = updateCloneFiles(serverFile, pki_provider_name.value, 'Server');
            console.log("in clone");
            $.when(updateCAFile, updateServFile).done(function(caFilePath, servFilePath){
                    caFileExists.value = caFilePath[0].filePath;
                    serverFileExists.value = servFilePath[0].filePath;
                    $('form').submit();
                }
            });
        } else if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name == null) {
        //for update
              var updateCAFile = updateCloneFiles(caFile, pki_provider_id, 'CA');
              var updateServFile = updateCloneFiles(serverFile, pki_provider_id, 'Server');
              console.log("in update");
              //if only ca file update
              if (caFile.value.length != 0 && serverFile.value.length == 0){
                  console.log("only ca file update");
                  $.when(updateCAFile).done(function(caFilePath){
                      if (caFilePath[1] == "success"){
                          caFileExists.value = caFilePath[0].filePath;
                          $('form').submit();
                      } else { $('form').submit(); }
                  });
              //if only server file update
              } else if (caFile.value.length == 0 && serverFile.value.length != 0){
                  console.log("only ca file update");
                  $.when(updateServFile).done(function(servFilePath){
                      if (servFilePath[1] == "success"){
                          serverFileExists.value = servFilePath[0].filePath;
                          //if pki name doesn't exist
                          $('form').submit();
                      } else { $('form').submit(); }
                  });
              //if both files update
            } else if (caFile.value.length == 0 && serverFile.value.length != 0) {
                  $.when(updateCAFile, updateServFile).done(function(caFilePath, servFilePath){
                      if (caFilePath[1] == "success" || servFilePath[1] == "success"){
                          caFileExists.value = caFilePath[0].filePath;
                          serverFileExists.value = servFilePath[0].filePath;
                          $('form').submit();
                      }
                  });
            } else { /*nothing update*/ $('form').submit(); }
        } else if ((caFile.value.length != 0 && serverFile.value.length != 0) && (caFileExists.value.length == 0 && serverFileExists.value.length == 0)){
        //for create
            console.log("in create");
            $.when(processFiles(pki_provider_name.value)).done(function(filePaths){
                 caFileExists.value = filePaths.CA_file_path;
                 serverFileExists.value = filePaths.Server_file_path;
                 $('form').submit();
            });
            // processFiles(pki_provider_name.value);
        } else {

        }
    }); //end of click save button NEW NEW NEW

    // API CALL RESPONSE: {pki_provider_name, [file1,file2]}
    //input : array [caFile, serverFile]
    function processFiles(pki_provider_name){
        console.log("inprocessfiles");
        var base_url = window.location.origin;

        var fd = new FormData();
        $.each($('input[type=file]'), function(i, obj){
            $.each(obj.files, function(i, file){
                fd.append('file', file);
            });
        });
        console.log(fd);

        return $.ajax({
            type: 'POST',
            url: base_url + '/config/pki_provider/uploadCerts/' + "scep?name=" + pki_provider_name,
            data: fd,
            dataType: 'json',
            processData: false,
            contentType: false,
            success: function(data){
              console.log("processfiles success!!");
              //if succeed, replace path here in ca_path/server_path field on html
              console.log(data);
            },
            error: function(data){
              console.log("processfiles failed");
              console.log(data);
            }
        });
    } //end of processfiles NEW

    //******************** initiate popover *********************//
    $("#ca_view_more").popover({
        html: true,
        title: 'Current CA Certificate <button class="btn btn-primary" id="downloadCA">Download</button>'
    });
    $("#serv_view_more").popover({
        html: true,
        title: 'Current Server Certificate <button class="btn btn-primary" id="downloadServ">Download</button>'
    });

    //******************** download button *********************//
    document.getElementById("download_button").addEventListener("click", function(e){
        e.preventDefault();

        $.when(downloadCert("pki_provider")).done(function(downloadFileInfo){
              //if ca : ca.PEM
              //if server: server.pem
        //     downloadFile("server.crt", downloadFileInfo);
        // });
        }, false);
    )};
}); // end of document ready


/******************* verify file type and size *******************/
function verifyFile(input){
    if (fileTypeValidation(input)){
        if (fileSizeValidation(input)){
            return true;
        } else {
            input.value = '';
            document.getElementById('errorMessage').innerHTML = "File size is bigger than 1MB.";
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
            return false;
        }
    } else {
        input.value = '';
        document.getElementById('errorMessage').innerHTML = "Upload a file with the extension: '.pem' .";
        $("#error-alert").show();
        setTimeout(function(){
            $("#error-alert").slideUp(500);
        }, 3000);
        return false;
    }
}

//test file types
function fileTypeValidation(input){
    var file = input.value;
    var allowedExtensions = /(\.pem)$/i;
    if(!allowedExtensions.exec(file)){
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
        input.value = '';
        return false;
    }
    else{
        return true;
    }
}


/*************calls only when save button is pressed
                                for update and clone****************/

function updateCloneFiles(input, pki_provider_name, qualifier){
    var base_url = window.location.origin;
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

/******************* Download ********************/
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

// if (verifyFile(this) == true){
//     if (this.id === "ca_cert_path_upload"){
//         certFilesList[0]= this.files;
//     } else {
//         certFilesList[1]= this.files;
//     }
// } else {
//     if (this.id === "ca_cert_path_upload"){
//         certFilesList[0]= null;
//     } else {
//         certFilesList[1]= null;
//   }
// }
// console.log(certFilesList);

function downloadFile (fileName, data){

    var element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(data.Cert_Content));
    element.setAttribute('download', fileName);

    element.style.display = 'none';
    document.body.appendChild(element);
    element.click();

    document.body.removeChild(element);
}

function readCert(filePath){
    var base_url = window.location.origin;
    return $.ajax({
        type: 'GET',
        url: base_url + '/readCert/' + "?qualifier=" + filePath,
        success: function(data){
            //https_key_view_more || https_serv_view_more,
            //eap_key_view_more || eap_serv_view_more || eap_ca_view_more
            caViewMore.setAttribute("data-content", data.CN_CA + '<br><br>' + CA_INFO);
            servViewMore.setAttribute("data-content", data.CN_Server + '<br><br>' + Server_INFO);
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
