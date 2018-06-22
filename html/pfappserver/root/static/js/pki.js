
$(document).ready(function(){
    $("input[type='file']").after("<span id='val'></span>");
    $("input[type='file']").click(function() {
    $("input[type='file']").trigger('click');
    });

    $("input[type='file']").change(function() {
        validateFileSize();
        $('#val').text(this.value.replace(/C:\\fakepath\\/i, ''))
    });
});

function validateFileSize(file) {
    var FileSize = file.files[0].size / 1024 / 1024; // in MB
    if (FileSize > 1) {
        alert('File size exceeds 1 MB. Please try again.');
    } else {

    }
}

function showFileSize() {
    var input, file;

    // (Can't use `typeof FileReader === "function"` because apparently
    // it comes back as "object" on some browsers. So just see if it's there
    // at all.)
    if (!window.FileReader) {
        bodyAppend("p", "The file API isn't supported on this browser yet.");
        return;
    }

    input = document.getElementById('');
    if (!input) {
        bodyAppend("p", "Um, couldn't find the file input element.");
    }
    else if (!input.files) {
        bodyAppend("p", "This browser doesn't seem to support the `files` property of file inputs.");
    }
    else if (!input.files[0]) {
        bodyAppend("p", "Please select a file before clicking 'Load'");
    }
    else {
        file = input.files[0];
        bodyAppend("p", "File " + file.name + " is " + file.size + " bytes in size");
    }
}
