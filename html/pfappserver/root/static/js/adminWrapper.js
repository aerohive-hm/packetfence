
$(document).ready(function(){
  $(".trial-clock-indicator").click(function(){
    $("#clockTrialDiv").animate({
      width: "toggle"
    });
  });
  // $("#trialIndicator").load(window.location + " #trialIndicator");
  $(".dismiss-modal").click(function(){
    $("#myModal").css("display", "none");
  });

  document.getElementById("licenseKey").onclick = function () {
    var base_url = window.location.origin;
    console.log("going to license management page");
    location.href = base_url+"/admin/licenseKeys";
  };

  timeLeft();

  var emailForm = $('.emailForm');
  var emailFormButton = $('.toggle-emailForm');
  var licenseAlertButton = $('.toggle-licenseAlert');
  var licenseAlert = $('.licenseAlert');
  var sentEmailButton = $('.emailSentSuccess');
  var successEmailMessage = $('.successEmailMessage');
  $(document).ready(function() {
      emailForm.hide();
      successEmailMessage.hide();
      emailFormButton.click(function() {
        licenseAlert.slideUp(1000);
        emailForm.slideDown(1000);
      });
      licenseAlertButton.click(function() {
        emailForm.slideUp(1000);
        licenseAlert.slideDown(1000);
      });
      sentEmailButton.click(function(){
        emailForm.slideUp(1000);
        successEmailMessage.slideDown(1000);
      });
    });

});

function timeLeft(){
  var base_url = window.location.origin;
  var timeBar = document.getElementById("time-indicator-bar");
  var numOfDaysLeft = 0;
  var seconds = 0;
  var hours = 0;
  var days = 0;
  $.ajax({
      type: 'GET',
      url: base_url + '/entitlement/trial'
    }).done(function(data){
         seconds = data.trial[0].expires_in;
         var parseSeconds = parseInt(seconds, 10);
         days  = Math.ceil(parseSeconds / (3600*24));
         hours = Math.ceil(parseSeconds / 3600);
         console.log("Days: " + days);
         numberOfDaysLeft = days;
         var percentageWidth = Math.round((numberOfDaysLeft) * (100/30)) + '%';
         if (numberOfDaysLeft > 15 && numberOfDaysLeft < 29){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', percentageWidth);
         }else if(numberOfDaysLeft == 29){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', 180);
         }else if(numberOfDaysLeft == 30){
            $("#daysLeft").html(numberOfDaysLeft + " " + "days");
            $(timeBar).css('width', 180);

         }else if(numberOfDaysLeft <= 15 && numberOfDaysLeft > 0 ){
            if ($.cookie('pop') == null) {
               console.log("show modal");
               $('#myModal').modal('show');
               $.cookie('pop', '1');
            }
            if (numberOfDaysLeft == 1){
              document.getElementById("daysLeft2").innerHTML= numberOfDaysLeft + " day";
              $("#daysLeft").html(numberOfDaysLeft + " " + "day");
              $(timeBar).css('width', percentageWidth);
            }else{
              document.getElementById("daysLeft2").innerHTML= numberOfDaysLeft + " days";
              $("#daysLeft").html(numberOfDaysLeft + " " + "days");
              $(timeBar).css('width', percentageWidth);
            }
         }else if (numberOfDaysLeft == 0){
              console.log("show expired modal");
               $('#expiredModal').modal('show');
               $("#daysLeft").html(numberOfDaysLeft + " " + "day");
               $(timeBar).css('width', percentageWidth);
         }else{
               $("#daysLeft").html(0 + " " + "day");
               $(timeBar).css('width', 0);
         }
           // modal to show for actually expire
    }).fail(function(xhr, status, error){
        $('.trialIndicator').remove();
        console.log("removing trial indicator");

    });
    return numOfDaysLeft;
}


function openExpiredModal(){
    console.log("show expired modal");
    $('#expiredModal').modal({backdrop:'static', keyboard: false });
    $('#expiredModal').modal('show');
}

function openAlmostExpiredModal(){
    $('#myModal').modal({backdrop:'static', keyboard: false });
    $('#myModal').modal('show');
}

function updatePkiCertModal(){
  //
  console.log("inside update Pki Cert function");
  if ($("element").data('bs.modal') && $("element").data('bs.modal').isShown){
    console.log("checking if visible");
      $("#client_cert_path").after("<span id='val'></span>");
      $("#client_key_path").after("<span id='val2'></span>");
      $("#ca_cert_path").after("<span id='val3'></span>");
      $("#server_cert_path").after("<span id='val4'></span>");

  // $("input[type='file']").after("<span id='val'></span>");

      $("#client_cert_path").click(function () {
          $("#client_cert_path").trigger('click');
      });

      $("#client_key_path").click(function () {
          $("#client_key_path").trigger('click');
      });

      $("#ca_cert_path").click(function () {
          $("#ca_cert_path").trigger('click');
      });

      $("#server_cert_path").click(function () {
          $("#server_cert_path").trigger('click');
      });

      $("#client_cert_path").change(function () {
          $('#val').text(this.value.replace(/C:\\fakepath\\/i, ''))
      });

      $("#client_cert_path").click(function() {
        $("input[type='file']").trigger('click');
      });
    }
}

// function showFileSize() {
//     console.log(" in show file size");
//     var input, file;
//
//     if (!window.FileReader) {
//         alert("The file API isn't supported on this browser yet.");
//         return;
//     }
//
//     input = document.getElementById('client_cert_path');
//     if (!input) {
//         bodyAppend("p", "Um, couldn't find the fileinput element.");
//     }
//     else if (!input.files) {
//         bodyAppend("p", "This browser doesn't seem to support the `files` property of file inputs.");
//     }
//     else if (!input.files[0]) {
//         bodyAppend("p", "Please select a file before clicking 'Load'");
//     }
//     else {
//         file = input.files[0]; console.log(file);
//         bodyAppend("p", "File " + file.name + " is " + file.size + " bytes in size");
//     }
// }
// function bodyAppend(tagName, innerHTML) {
//    console.log("in body append");
//     var elm;
//
//     elm = document.createElement(tagName);
//     elm.innerHTML = innerHTML;
//     $("#client_cert_path").append(elm);
// }
