
$(document).ready(function(){

  applyKeyButton();

  $('.agreeToEula').click(function() {
      //changes checkbox to submit button
      $(".agree").slideUp();
      $(".agree").delay(3000);
      $(".submitAgreement").slideDown();
  });
  $('.submitAgreement').click(function(){
      userSubmitEula();
  });
});

// apply button press
function applyKeyButton(){
  console.log("inside applyKeyButton");
  var applyKeyButton2 = $("#applyKey");
  applyKeyButton2.click(function(){
    var userKeyInput = document.getElementById('keyInput').value;
    if (checkKeyInput(userKeyInput)){
        console.log("checking key: " + checkKeyInput(userKeyInput));
        $(".errMsg").css('display', 'none');
        $("#keyInput").css('border','1px solid #dfdfdf');
        updateKeyTable(userKeyInput);
        document.getElementById('keyInput').value ='';
        return true;
    } else {
        document.getElementById('keyInput').value = userKeyInput;
        return false;
    }
  });
}

// update table after checking regex
function updateKeyTable(userKeyInput) {
  console.log("inside updateKeyTable");
    // var applyKeyButton2 = $("#applyKey");
    var base_url = window.location.origin;
    $.ajax({
        url : base_url + '/entitlement/key/' + userKeyInput,
        type : 'PUT',
        dataType : 'json'
        }).done(function(data){
           var errMsg = data.status_msg;
           if (errMsg != null ) {
               document.getElementById('errorMessage').innerHTML = errMsg;
               $("#success-alert").show(); // use slide down for animation
               setTimeout(function (){
                 $("#success-alert").slideUp(500);
               }, 3000);
           } else {
               openEulaModal();
               $("#keyLicenseTable").load(window.location + " #keyLicenseTable");
               $("#licenseCapa").load(window.location + " #licenseCapa");
               $("#trialIndicator").load(window.location + " #trialIndicator");
           }
           return true;
        }).fail(function(xhr, status, error){
           console.log("error: " + error);
           return false;
        });
}


function checkKeyInput(userKeyInput){
    console.log("inside checkKeyInput");
    var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
    var applyKeyButton2 = $("#applyKey");
    //TRUE OR FALSE
    if (checkKeyRegex.test(userKeyInput)){
        $("#keyInput").css('border','1px solid #dfdfdf');
        console.log("TRUE");
        return true;
    } else {
        // document.getElementById('errorMessage').innerHTML = "The key entered is in the wrong format. Please enter a valid entitlement key.";
        // $("#success-alert").show();
        // setTimeout(function (){
        //   $("#success-alert").slideUp(500);
        // }, 3000);
        console.log("FALSE");
        return false;
    }
}

//open eula
function openEulaModal(){
   $('#eulaModal').modal({backdrop:'static', keyboard: false });   // initialized with no keyboard
   $('#eulaModal').modal('show');
}


//user submits eula with button press
function userSubmitEula(){
    console.log("inside userSubmitEula");
  var base_url = window.location.origin;
  $.ajax({
      type: 'POST',
      url: base_url + '/eula'
  }).done(function(data){
      $('.trialIndicator').remove();
      $('#eulaModal').modal('hide');
      $(".modal-backdrop").hide();
      $(".licenseTrialText").hide();
  }).fail(function(xhr, status, error){
      console.log(error);
  });
}
