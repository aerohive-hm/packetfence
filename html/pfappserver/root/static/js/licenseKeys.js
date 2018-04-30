

$(document).ready(function(){
  var licenseCapacity = document.getElementById("licenseCapa");
  var usedCapacity = document.getElementById("usedCapacity");
  var usedCapacity2 = $("#usedCapacity");
  var usedCapacity3 = $("#usedCapacitySpan");
  var licenseCapacity3 = $("#licenseCapaSpan");
  console.log("license Cap right now: " + licenseCapacity.innerHTML);

  applyKeyButton();
  updateCapacities();


  $('.agreeToEula').click(function() {
      //changes checkbox to submit button
      console.log("submitAgreement was pressed");
      $(".agree").slideUp();
      $(".agree").delay(3000);
      $(".submitAgreement").slideDown();
  });
  $('.submitAgreement').click(function(){
    console.log("submitAgreement was pressed");
      userSubmitEula();
  })

});

function updateCapacities(){
  var licenseCapacity = document.getElementById("licenseCapa");
  var usedCapacity = document.getElementById("usedCapacity");
  var usedCapacity2 = $("#usedCapacity");
  console.log("licence Capacity: " + licenseCapacity.innerHTML);
  if(licenseCapacity.innerHTML >= 100000 || licenseCapacity.innerHTML === "Unlimited"){
    console.log("changing innerHTML for lice capa");
     licenseCapacity.innerHTML = "Unlimited";
  }
  if(usedCapacity.innerHTML > licenseCapacity.innerHTML){
     usedCapacity2.css('color', 'red');
     $("#usedCapacitySpan").css('color', 'red');
     $("#usedCapacitySpan").after("<span class='glyphicon glyphicon-warning-sign' style='color: red;'></span>");
  }
  console.log("updating capacities");
}

// apply button press
function applyKeyButton(){
  var applyKeyButton2 = $("#applyKey");
  applyKeyButton2.click(function(){
    var userKeyInput = document.getElementById('keyInput').value;
    console.log(userKeyInput);
    console.log("CHECKING KEY REGEX:");
    console.log(checkKeyInput(userKeyInput));
    var errMsg = "<p class='errMsg' style='color:red;'>Key does not exist. Please reenter the key again.</p>";
    if (checkKeyInput(userKeyInput)){
        $(".errMsg").css('display', 'none');
        $("#keyInput").css('border','1px solid #dfdfdf');
        updateKeyTable(userKeyInput);
        document.getElementById('keyInput').value ='';
        console.log("updated table styling after ajax call ");
        return true;
    } else {
        $(".errMsg").css('display', 'none');
        applyKeyButton2.after(errMsg).slideDown();
        $("#keyInput").css('border','1px solid #d9534f');
    }
  });
  console.log("applied new button press");
}

// update table after checking regex
function updateKeyTable(userKeyInput) {
    var applyKeyButton2 = $("#applyKey");
    var base_url = window.location.origin;
    // var clearText = document.getElementById("keyValue");
    $.ajax({
        url : base_url + '/entitlement/key/' + userKeyInput,
        type : 'PUT',
        dataType : 'json'
        }).done(function(data){
           console.log("status message data: ");
           console.log(data);
           var checkFirstCharOfInput = userKeyInput.charAt(0);
           var errMsg = data.status_msg;
           if (errMsg != null ) {
               document.getElementById('errorMessage').innerHTML = errMsg;
               $("#success-alert").show(); // use slide down for animation
               setTimeout(function () {
                 $("#success-alert").slideUp(300);
               }, 2000);
           }

           openEulaModal();

           //update capacity
           $("#keyLicenseTable").load(window.location + " #keyLicenseTable");
           $("#licenseCapa").load(window.location + " #licenseCapa");
           $("#trialIndicator").load(window.location + " #trialIndicator");
           var capacity = $("#licenseCapa").attr("data-capacity");
           console.log("capacity: " + capacity);
           capacity = $("#licenseCapa").attr('data-capacity', document.getElementById('licenseCapa').innerHTML);
           if (capacity >= 100000){
               console.log("changeing capacity to new data capacity2");
               document.getElementById('licenseCapa').innerHTML = "Unlimited";
           }
           console.log("new license capa: " + document.getElementById('licenseCapa').innerHTML);
           console.log("updateKeyTable success");
           return true;
        }).fail(function(xhr, status, error){
           console.log("updateKeyTable error: ");
           console.log(error);
           return false;
        });
       console.log("updated key");
}


function checkKeyInput(userKeyInput){
    var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
    // var errMsg = "<p class='errMsg' style='color:red;'>Sorry please reenter the license key again.</p>";
    var applyKeyButton2 = $("#applyKey");
    //check regex with user input; there is check for duplicate already
    console.log(checkKeyRegex.test(userKeyInput)); //TRUE OR FALSE
      if (checkKeyRegex.test(userKeyInput)){
          // $(".errMsg").css('display', 'none');
          $("#keyInput").css('border','1px solid #dfdfdf');
          return true;
      } else {
          // $(".errMsg").css('display', 'none');
          // applyKeyButton2.after(errMsg);
          $("#keyInput").css('border','1px solid #d9534f');
          return false;
      }
    console.log("done checking key");
}

//check if valid from date is over todays date then turn row into grey
// function dateExpirationChecker(){
//     var table = $("#keyLicenseTable");
//     var myArray = [];
//     var tmp;
//     var lowest, highest = 0;
//     table.find('tr').each(function(i) {
//         var $tableColumns = $(this).find('td');
//         var dayLeftofKey = parseInt(($tableColumns.eq(4).text()));
//         myArray.push(dayLeftofKey);
//     });
//     console.log("myArray: " + myArray);
//
//     //get latest date by getting highest day left
//     for (i=0; i < myArray.length; i++){
//         tmp = myArray[i];
//         console.log(tmp);
//         if (tmp > highest) {
//             highest = tmp;
//         }
//     }
//     console.log(highest);
//     if (highest == 0){
//         return true;
//     } else {
//         return false;
//     }
//     console.log("checked date");
// }

//open eula
function openEulaModal(){
   $('#eulaModal').modal({backdrop:'static', keyboard: false });   // initialized with no keyboard
   $('#eulaModal').modal('show');
   console.log("eula modal opening");
}


//user submits eula with button press
function userSubmitEula(){
  var base_url = window.location.origin;
  $.ajax({
      type: 'POST',
      url: base_url + '/eula'
  }).done(function(data){
      console.log(data);
      console.log("sent eula! congrats no more trial");
      $('.trialIndicator').remove();
      $('#eulaModal').modal('hide');
      $(".modal-backdrop").hide();
      $(".licenseTrialText").hide();
  }).fail(function(xhr, status, error){
      console.log(error);
  });
}
