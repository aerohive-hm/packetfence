
$(document).ready(function(){
  var licenseCapacity = document.getElementById("licenseCapa");
  var usedCapacity = document.getElementById("usedCapacity");
  var usedCapacity2 = $("#usedCapacity");
  var usedCapacity3 = $("#usedCapacitySpan");
  var licenseCapacity3 = $("#licenseCapaSpan");

  applyKeyButton();
  updateCapacities();

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

function updateCapacities(){
  var licenseCapacity = document.getElementById("licenseCapa");
  var usedCapacity = document.getElementById("usedCapacity");
  var usedCapacity2 = $("#usedCapacity");
  if(licenseCapacity.innerHTML >= 100000 || licenseCapacity.innerHTML === "Unlimited"){
     licenseCapacity.innerHTML = "Unlimited";
  }
  if(usedCapacity.innerHTML > licenseCapacity.innerHTML){
     usedCapacity2.css('color', 'red');
     $("#usedCapacitySpan").css('color', 'red');
     $("#usedCapacitySpan").after("<span class='glyphicon glyphicon-warning-sign' style='color: red;'></span>");
  }
}

// apply button press
function applyKeyButton(){
  var applyKeyButton2 = $("#applyKey");
  applyKeyButton2.click(function(){
    var userKeyInput = document.getElementById('keyInput').value;
    console.log(checkKeyInput(userKeyInput));
    checkKeyInput(userKeyInput);
    if (checkKeyInput(userKeyInput)){
        $(".errMsg").css('display', 'none');
        $("#keyInput").css('border','1px solid #dfdfdf');
        updateKeyTable(userKeyInput);
        document.getElementById('keyInput').value ='';
        return true;
    } else {
        document.getElementById('keyInput').value = userKeyInput;
    }
  });
}

// update table after checking regex
function updateKeyTable(userKeyInput) {
    var applyKeyButton2 = $("#applyKey");
    var base_url = window.location.origin;
    $.ajax({
        url : base_url + '/entitlement/key/' + userKeyInput,
        type : 'PUT',
        dataType : 'json'
        }).done(function(data){
           var checkFirstCharOfInput = userKeyInput.charAt(0);
           var errMsg = data.status_msg;
           if (errMsg != null ) {
               document.getElementById('errorMessage').innerHTML = errMsg;
               $("#success-alert").show(); // use slide down for animation
               setTimeout(function () {
                 $("#success-alert").slideUp(500);
               }, 3000);
           }

           openEulaModal();
           $("#keyLicenseTable").load(window.location + " #keyLicenseTable");
           $("#licenseCapa").load(window.location + " #licenseCapa");
           $("#trialIndicator").load(window.location + " #trialIndicator");

           //update capacity
           var capacity = $("#licenseCapa").attr("data-capacity");
           capacity = $("#licenseCapa").attr('data-capacity', document.getElementById('licenseCapa').innerHTML);
           if (capacity >= 100000){
               document.getElementById('licenseCapa').innerHTML = "Unlimited";
           }
           return true;
        }).fail(function(xhr, status, error){
           console.log("updateKeyTable error: ");
           console.log(error);
           return false;
        });
}


function checkKeyInput(userKeyInput){
    var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
    var applyKeyButton2 = $("#applyKey");
    console.log(checkKeyRegex.test(userKeyInput)); //TRUE OR FALSE
    if (checkKeyRegex.test(userKeyInput)){
        $("#keyInput").css('border','1px solid #dfdfdf');
        return true;
    } else {
        $("#keyInput").css('border','1px solid #d9534f');
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
