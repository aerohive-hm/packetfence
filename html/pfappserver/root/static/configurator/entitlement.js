//toggles
$(document).ready(function(){
     $('#entitlementRadio').click(function () {
     $('.keyInput').css('display', 'inline');
     $('.continueButton').prop("disabled", true);
  });
  $('#thirtyDayTrialRadio').click(function(){
     $('.keyInput').css('display', 'none');
     $('.continueButton').prop("disabled", false);
  });

  checkKey();

});

// *** Check regex: When user clicks submit, check the input first, then open modal ***
function checkKey(){
  var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
  var sampleKey = ["P82G9-DA9BA-67LRQ-4KA6B-LK539-3YTXQ","SF89F-08SF8-908F9-0S8F9-0890F-S9RS9"];  //need to check if key exists
  var errMsg = "<span class='errMsg'>Sorry please reenter the license key again.</span>";
  var errMsg2 = "<span class='errMsg' style='color:red;'>This key is not found or not valid.</span>";
  var errMsg3 = "<span class='errMsg' style='color:red;'>This key is already deactivated.</span>";
  var errMsgX = "<span class='errMsg' style='color:red;'>This key is already expired.</span>"
  var userKeyInput = document.getElementById('entitlementKey1').value;
   console.log("input1: " + userKeyInput);
   //check regex with user input
   console.log(checkKeyRegex.test(userKeyInput));
   var checkFirstCharOfInput = userKeyInput.charAt(0);
   if (checkFirstCharOfInput === '3') {
       $(".errMsg").css('display', 'none');
       $("#entitlementKeyInputs").before(errMsg3);
       $("#keyInput").css('border','1px solid #dfdfdf');
   }else if (checkFirstCharOfInput === '2'){
       $(".errMsg").css('display', 'none');
       $("#entitlementKeyInputs").before(errMsg2);
       $("#keyInput").css('border','1px solid #dfdfdf');
   }else if (checkFirstCharOfInput === 'X'){
       $(".errMsg").css('display', 'none');
       $("#entitlementKeyInputs").before(errMsgX);
       $("#keyInput").css('border','1px solid #dfdfdf');
   }else if (checkKeyRegex.test(userKeyInput) == true){
       $(".errMsg").css('display', 'none');
	     $('#eulaModal').modal({backdrop:'static', keyboard: false })   // initialized with no keyboard
	     $('#eulaModal').modal('show');
   } else {
       $(".errMsg").css('display', 'none');
       $("#entitlementKeyInputs").before(errMsg);
	     $("#entitlementKey").css('border','1px solid #d9534f');
   }
 }
//if user selects both agree and submit button the the modal disappears and then te
// 30 day trail is disabled and the user can only press the continue button. add a green
//check mark next to the input box.
function agreeEula(){
  var agreeInput = document.getElementById('agreeToEula');
  var valid = false;
  $(".agree").slideUp();
  $(".submitAgreement").show();
  //ajax call here
}
function submitAgree(){
  var submitSpan = "<span style='padding-left: 25px; color:#5cb85c;'>Complete! Press Continue to finish the process.</span>";
  $('#eulaModal').modal('hide');
  $('#thirtyDayTrialRadio').prop("disabled", true);
  $('#entitlementKey1').prop("disabled", true);
  $('#entitlementKeySubmit').css('display', 'none');
  $('.errMsg').hide();
  $('.continueButton').prop("disabled", false);
  $('#entitlementKeyInputs').after(submitSpan);
}



function registerExits() {
    $('#tracker a, .form-actions button').click(function(event) {
        var href = $(this).attr('href');
        window.location.href = href;
        return false; // don't follow link
    });
}

function initStep() {
  $('#configure_fingerbank_api_key').click(function(e) {
    e.preventDefault();
    var btn = $(e.target);

    $.ajax({
        headers: {
          'Accept':'application/json',
        },
        type: 'POST',
        url: btn.attr('href'),
        data: { api_key: $('#api_key').val() }
    }).done(function(data) {
        btn.addClass('disabled');
        $('#api_key').attr('disabled', '');
        resetAlert(btn.closest('.control-group'));
        showSuccess(btn.closest('.control-group'), data.status_msg);

        var continueBtn = btn.closest('form').find('[type="submit"]');
        continueBtn.removeClass("btn-danger").addClass("btn-primary").html(continueBtn.data("msg-done"));
    }).fail(function(jqXHR) {
        var obj = $.parseJSON(jqXHR.responseText);
        showError(btn.closest('.control-group'), obj.status_msg);
    });

    return false;
  });
}


// function checkIfKeyEntered(){
//     var base_url = window.location.origin;
//    //var to grab state of page
//     $.ajax({
//         type: 'GET',
//         url: '/eula',
//         // data: ,
//     }).done(function(response){
//         console.log("response: " + response);
//     }).fail(function(jqXHR){
//
//     });
//     return true;
// }

function checkUserSubmitTrial(){
    var trialPressed = document.getElementById("thirtyDayTrialRadio");
    var keyEnteredPressed = document.getElementById("entitlementRadio");
    var checkedTrial = false;
    var radioValue;
    $('input').on('change', function() {
      radioValue = $('input:radio[name="licenseRadio"]:checked').val();
      console.log(radioValue);
    });
    $(".continueButton").on("click", function(){
        console.log("inside click continue func!");
        if (radioValue = "trial" ){
          console.log("yes! trial");
          userSubmitEula();
        }
        console.log("continue");
    });
    return false;
}

$(document).ready(function(){
  // checkIfKeyEntered();
  checkUserSubmitTrial();
});


function userSubmitEula(){
    var base_url = window.location.origin;
    var agreePressed = document.getElementById("");
    var checked = false;
    $.ajax({
        type: 'POST',
        url: base_url + '/entitlement/trial'
    }).done(function(data){
        console.log(data);
        console.log("success!");
    }).fail(function(data){
        console.log("error");
    });
    return false;
}
