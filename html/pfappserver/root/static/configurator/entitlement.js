//toggles
$(document).ready(function(){
  //(1)toggle clicks to hide and disable input fields of key radio btn option
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

// (2) Check regex: When user clicks submit, check the input first, then open modal
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

//check if the user pressed trail or key radio button
 function checkUserSubmitTrial(){
     var trialPressed = document.getElementById("thirtyDayTrialRadio"); //trial radiobutton
     var keyEnteredPressed = document.getElementById("entitlementRadio"); //enter key radiobutton
     var radioValue; //used to get value of the radio button to check
     $('input').on('change', function() {
       radioValue = $('input:radio[name="licenseRadio"]:checked').val();
       console.log(radioValue);
     }); //checks which radio button is pressed
     $(".continueButton").on("click", function(){
         console.log("inside click continue func!");
         if (radioValue = "trial" ){
           console.log("yes! trial");
           userSubmitTrial();
         }else{
           userSubmitEula();//check if keyEnteredPressed
           //send key
         }
         console.log("continue");
     }); //if use press trial then after pressing continue call function to submit trial,
         //else check if submit pressed, send key and then check continue.
     return false;
 }

 $(document).ready(function(){
     var agreeInput = document.getElementById('agreeToEula');
     var valid = false;
     checkUserSubmitTrial(); //check which radio button the user pressed
     $('.agreeToEula').click(function() {
         //changes checkbox to submit button
         $(".agree").slideUp();
         $(".agree").delay(3000);
         $(".submitAgreement").slideDown();
     });
     $('.submitAgreement').click(function(){
         userSubmitEula();
     })
 });

//if user selects both agree and submit button the the modal disappears and then te
// 30 day trail is disabled and the user can only press the continue button. add a green
//check mark next to the input box.
function userSubmitTrial(){
    var base_url = window.location.origin;
    var checked = false;
    $.ajax({
        type: 'POST',
        url: base_url + '/entitlement/trial'
    }).done(function(data){
        console.log(data);
        console.log("trial success!");
        $('#entitlementRadio').prop("disabled", true);
        $('#entitlementKey1').prop("disabled", true);
    }).fail(function(xhr, status, error){
        console.log(error);
        if (error){
           document.getElementById('selection-warning').style.display = 'block';
        }
    });
    return false;
}

function userSubmitEula(){
  var base_url = window.location.origin;
  var submitSpan = "<span style='padding-left: 25px; color:#5cb85c;'>Complete! Press Continue to finish the process.</span>";
  //add ajax call here after submit button pressed
  $.ajax({
      type: 'POST',
      url: base_url + '/eula'
  }).done(function(data){
      console.log(data);
      console.log("sent eula! press continue to finish process");
      // $()
      var submitSpan = "<span style='padding-left: 25px; color:#5cb85c;'>Complete! Press Continue to finish the process.</span>";
       $('#eulaModal').modal('hide');
       $('#thirtyDayTrialRadio').prop("disabled", true);
       $('#entitlementKey1').prop("disabled", true);
       $('#entitlementKeySubmit').css('display', 'none');
       $('.errMsg').hide();
       $('.continueButton').prop("disabled", false);
       $('#entitlementKeyInputs').after(submitSpan);

  }).fail(function(xhr, status, error){
      console.log(error);
      console.log("sent eula! press continue to finish process");
      // $()
      var submitSpan = "<span style='padding-left: 25px; color:#5cb85c;'>Complete! Press Continue to finish the process.</span>";
       $('#eulaModal').modal('hide');
       $('#thirtyDayTrialRadio').prop("disabled", true);
       $('#entitlementKey1').prop("disabled", true);
       $('#entitlementKeySubmit').css('display', 'none');
       $('.errMsg').hide();
       $('.continueButton').prop("disabled", false);
       $('#entitlementKeyInputs').after(submitSpan);
      // if (error){
      //    document.getElementById('selection-warning').style.display = 'block';
      // }
  });
}

//for continue button when user applied a key after accepting eula
function updateKeyTable(userKeyInput) {
    var applyKeyButton2 = $("#applyKey");
    var base_url = window.location.origin;
    $.ajax({
        url : base_url + '/entitlement/key/' + userKeyInput,
        type : 'PUT',
        dataType : 'json',
        success : function(data){
          $("#keyLicenseTable").load(window.location + " #keyLicenseTable");
          $("#licenseCapa").load(window.location + " #licenseCapa");
        },
        error : function(xhr, status, error){
            console.log(error);
       }
    });
     console.log("updated key");
}

//idk what this code from packetfence is for but check later
function registerExits() {
    $('#tracker a, .form-actions button').click(function(event) {
        var href = $(this).attr('href');
        window.location.href = href;
        return false; // don't follow link
    });
}
