
$(document).ready(function(){

// variables
    var caFile = document.getElementById('ca_cert_path_upload');
    var serverFile = document.getElementById('server_cert_path_upload');
    var caFileExists = document.getElementById('ca_cert_path');
    var serverFileExists = document.getElementById('server_cert_path');
    var pki_provider_name = document.getElementById("id");
    var pki_provider_id = $("input[name=id]").val();

//change styling and add new html elements
    caFile.setAttribute("class", "btn");
    serverFile.setAttribute("class", "btn");

    //view more popovers
    var caViewMore = document.createElement("A");
        caViewMore.setAttribute("id", "ca_view_more");
        caViewMore.innerHTML = "View Current CA Certificate";
        caViewMore.setAttribute("style", "padding-left:20px;");

    var servViewMore = document.createElement("A");
        servViewMore.setAttribute("id", "serv_view_more");
        servViewMore.innerHTML = "View Current Server Certificate";
        servViewMore.setAttribute("style", "padding-left:20px;");

        //if the file path exists (clone or update), then append view more link after
        if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0)){
            $("#ca_cert_path_upload").after(caViewMore);
            $("#server_cert_path_upload").after(servViewMore);
        }

        // view more button functionality
        $("#ca_view_more").click(function(){
            $("#wholeCertWindow").slideDown("slow");
            $.when(readCert(caFileExists.value)).done(function(caInfo){
                var cleanCaInfo = caInfo.Server_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
                document.getElementById("certificateInfoBody").innerHTML = cleanCaInfo;
            });
        });
        $("#serv_view_more").click(function(){
            $("#wholeCertWindow").slideDown("slow");
            $.when(readCert(serverFileExists.value)).done(function(serverInfo){
                var cleanServerInfo = serverInfo.Server_INFO.replace(/\n/g, "<br>").replace(/\s/g, "&nbsp;");
                document.getElementById("certificateInfoBody").innerHTML = cleanServerInfo;
            });
        });
        $("#closeCertInfoWindow").click(function(e){
            e.preventDefault();
            $("#wholeCertWindow").slideUp("slow");
        });

//*********** info for view more ***************//
        var caSubjectVal = caFileExists.value;
        var servSubjectVal = serverFileExists.value;

        $('input[type=file]').on('change', function(){
            verifyFile(this);
        });

//*****************save button press pki********************//
    var regexp =  RegExp("^[a-zA-Z0-9-\._]+$"); //regex: allow alphanumeric, dash, period, underscore
    document.getElementById("savePKI").addEventListener('click', function (e){
        e.preventDefault();
        e.stopPropagation();

        if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name == null) {
       //for update
           if (caFile.value.length != 0 && serverFile.value.length == 0){ /* if only ca file update */
               processAndSubmitFiles(caFile, pki_provider_id, 'CA');
           } else if (caFile.value.length == 0 && serverFile.value.length != 0){ /* if only server file update */
               processAndSubmitFiles(serverFile, pki_provider_id, 'Server');
           } else if (caFile.value.length != 0 && serverFile.value.length != 0){ /* if both file update */
               $.when(processFiles(pki_provider_id)).done(function(filePaths){
                    caFileExists.value = filePaths.CA_file_path;
                    serverFileExists.value = filePaths.Server_file_path;
                    $('form').submit();
               });
           } else { /*nothing update*/ $('form').submit(); }
        }
        if (pki_provider_name.value != 0){
            if (regexp.test(pki_provider_name.value) == true){
                if ((caFileExists.value.length != 0 && serverFileExists.value.length != 0) && pki_provider_name != null) {
                //for clone
                    if (caFile.value.length != 0 && serverFile.value.length == 0){
                        processAndSubmitFiles(caFile, pki_provider_name.value, 'CA'); /* if only ca file update */
                    } else if (caFile.value.length == 0 && serverFile.value.length != 0){
                        processAndSubmitFiles(serverFile, pki_provider_name.value, 'Server'); /* if only server file update */
                    } else if (caFile.value.length != 0 || serverFile.value.length != 0){
                        $.when(processFiles(pki_provider_name.value)).done(function(filePaths){ /* if both file update */
                             caFileExists.value = filePaths.CA_file_path;
                             serverFileExists.value = filePaths.Server_file_path;
                             $('form').submit();
                        });
                    } else { /*nothing update*/ $('form').submit(); }
                }  else if ((caFile.value.length != 0 && serverFile.value.length != 0) && (caFileExists.value.length == 0 && serverFileExists.value.length == 0)){
                //for create
                    $.when(processFiles(pki_provider_name.value)).done(function(filePaths){
                         caFileExists.value = filePaths.CA_file_path;
                         serverFileExists.value = filePaths.Server_file_path;
                         $('form').submit();
                    });
                } else if ((caFile.value.length == 0 && serverFile.value.length == 0) && (caFileExists.value.length == 0 && serverFileExists.value.length == 0)){
                    document.getElementById('errorMessage').innerHTML = "Error! To create a PKI provider, upload both CA and server certificates.";
                    $("#error-alert").show();
                    setTimeout(function(){
                        $("#error-alert").slideUp(500);
                    }, 3000);
                } else {}
            } else {
              document.getElementById('errorMessage').innerHTML = "Error! The PKI provider name can only contain alphanumeric characters, dashes, periods, and underscores.";
              $("#error-alert").show();
              setTimeout(function(){
                  $("#error-alert").slideUp(500);
              }, 3000);
            } //end of regex test
        } else {
            document.getElementById('errorMessage').innerHTML = "Error! The PKI provider name field is empty.";
            $("#error-alert").show();
            setTimeout(function(){
                $("#error-alert").slideUp(500);
            }, 3000);
        } //end of empty pki check
    }); //end of click save button

    // {pki_provider_name, [file1,file2]}  //for 2 files
    function processFiles(pki_provider_name){
        var base_url = window.location.origin;

        var fd = new FormData();
        $.each($('input[type=file]'), function(i, obj){
            $.each(obj.files, function(i, file){
                fd.append('file', file);
            });
        });

        return $.ajax({
            type: 'POST',
            url: base_url + '/config/pki_provider/uploadCerts/' + "scep?name=" + pki_provider_name,
            data: fd,
            dataType: 'json',
            processData: false,
            contentType: false,
            success: function(data){
              //if succeed, replace path in ca_path/server_path field on html
            },
            error: function(data){
                alert(data.status_msg);
            }
        });
    } //end of processfiles

    // ******************** download button *********************//
    // document.getElementById("download").addEventListener("click", function(e){
    //     console.log("ca download button click");
    //     e.preventDefault();
    //     if (this.id === "ca_cert_path_upload"){
    //         certFilesList[0]= this.files;
    //     } else {
    //         certFilesList[1]= this.files;
    //     }
    //     $.when(downloadCert("pki_provider")).done(function(downloadFileInfo){
    //           downloadFile("cacertificate.pem", downloadFileInfo);
    //     });
    // }, false);

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
                                for update and clone 1 file****************/
var caFileExists = document.getElementById('ca_cert_path');
var serverFileExists = document.getElementById('server_cert_path');
/* 1 file upload */
function processAndSubmitFiles(file, pki_provider_name, qualifier){
    $.when(updateCloneFiles(file, pki_provider_name, qualifier)).done(function(pathOfFile){
        if (qualifier === "CA"){ /* if ca */ document.getElementById('ca_cert_path').value = pathOfFile.filePath; }
        else { /* if server */               document.getElementById('server_cert_path').value = pathOfFile.filePath; }
        $('form').submit();
    });
}

function updateCloneFiles(input, pki_provider_name, qualifier){
    var base_url = window.location.origin;
    var form = $('#modalItem').get(0);
    var fd = new FormData();

    if (qualifier === "CA"){ fd.append('file', $('input[type=file]')[0].files[0]); }
    else if (qualifier === "Server"){ fd.append('file', $('input[type=file]')[1].files[0]); }

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
          var errMsg = data.responseText;
          if (errMsg != null ) {
              document.getElementById('errorMessage').innerHTML = errMsg;
              $("#error-alert").show();
              setTimeout(function (){
                $("#error-alert").slideUp(500);
              }, 3000);
          }
        }
    }); //end of ajax
}
//end of updateclone

/******************* Download ********************/
function downloadCert(qualifier){
    console.log("in downloadCert");
    var base_url = window.location.origin;
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

function downloadFile (fileName, data){
    console.log("in download file");

    var element = document.createElement('a');
    element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(data.Cert_Content));
    element.setAttribute('download', fileName);

    element.style.display = 'none';
    document.body.appendChild(element);
    element.click();

    document.body.removeChild(element);
}

//gets the cert info
function readCert(filePath){
    var base_url = window.location.origin;
    var filePathData = {'cert_path' : filePath}

    return $.ajax({
        type: 'GET',
        data: filePathData,
        dataType: 'json',
        url: base_url + '/readCert/' + "?qualifier=pki-provider",
        success: function(data){
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
