$(document).ready(function(){
    // applyKeyButton();
  $('.agreeToEula').click(function() {
      //changes checkbox to submit button
      $(".agree").slideUp();
      $(".agree").delay(3000);
      $(".submitAgreement").slideDown();
  });
  $('.submitAgreement').click(function(){
      userSubmitEula();
  });

  $("#applyKey").click(function(e){
    e.preventDefault();
    document.getElementById("applyKey").disabled = false;
    var userKeyInput = document.getElementById('keyInput').value;
    var keyCorrectRegex = checkKeyInput(userKeyInput);
    if (keyCorrectRegex == true){
        $(".errMsg").css('display', 'none');
        $("#keyInput").css('border','1px solid #dfdfdf');
        updateKeyTable(userKeyInput);
        document.getElementById('keyInput').value ='';
        return true;
    } else {
        document.getElementById('keyInput').value = userKeyInput;
        document.getElementById('errorMessage').innerHTML = "The key entered needs to be in format XXXXX-XXXXX-XXXXX-XXXXX-XXXXX-XXXXX";
        $(".alert-danger").show(); // use slide down for animation
        setTimeout(function (){
          $(".alert-danger").slideUp(500);
        }, 3000);
        return false;
    }
  });
});

// update table after checking regex
function updateKeyTable(userKeyInput) {
  console.log("inside updateKeyTable");
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
               $("#nav").load(window.location + " #trialIndicator");
           }
           return true;
        }).fail(function(xhr, status, error){
           return false;
        });
}


function checkKeyInput(userKeyInput){
    console.log("inside checkKeyInput");
    var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
    //TRUE OR FALSE
    if (checkKeyRegex.test(userKeyInput)){
        $("#keyInput").css('border','1px solid #dfdfdf');
        return true;
    } else {
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
