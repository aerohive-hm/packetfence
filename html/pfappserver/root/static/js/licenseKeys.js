
// all html elements;
// commented out console log lines;

$(document).ready(function(){
  var licenseCapacity = document.getElementById("licenseCapa");
  var usedCapacity = document.getElementById("usedCapacity");
  var usedCapacity2 = $("#usedCapacity");
  var usedCapacity3 = $("#usedCapacitySpan");
  var licenseCapacity3 = $("#licenseCapaSpan");
  console.log("license Cap right now: " + licenseCapacity.innerHTML);

  applyKeyButton();
  dateRangeChecker();
  updateCapacities();

  $('.no-submitted-eula').click(function(){
    $("#keyLicenseTable").load(window.location + " #keyLicenseTable");
    $("#licenseCapa").load(window.location + " #licenseCapa");
  });

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
        dateRangeChecker();
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
    $.ajax({
        url : base_url + '/entitlement/key/' + userKeyInput,
        type : 'PUT',
        dataType : 'json',
        success : function(data){
          $("#keyLicenseTable").load(window.location + " #keyLicenseTable");
          $("#licenseCapa").load(window.location + " #licenseCapa");
          $(".trialIndicator").hide();
        },
        error : function(error) {
          console.log(error);
          var errMsg2 = "<p class='errMsg' style='color:red;'>This key is not found or not valid.</p>";
          var errMsg3 = "<p class='errMsg' style='color:red;'>This key is already deactivated.</p>";
          var checkFirstCharOfInput = userKeyInput.charAt(0);
          if (checkFirstCharOfInput === '3') {
              $(".errMsg").css('display', 'none');
              applyKeyButton2.after(errMsg3).slideDown("slow");
              $("#keyInput").css('border','1px solid #dfdfdf');
          }else if (checkFirstCharOfInput === '2'){
              $(".errMsg").css('display', 'none');
              applyKeyButton2.after(errMsg2).slideDown("slow");
              $("#keyInput").css('border','1px solid #dfdfdf');
          }else{
            console.log(error);
          }
        }
    });
     console.log("updated key");
}

function success(data){
    $("#keyLicenseTable").load(window.location + " #keyLicenseTable");
    $("#licenseCapa").load(window.location + " #licenseCapa");
    $(".licenseTrialText").hide();
    var capacity = $("#licenseCapa").attr("data-capacity");
    console.log("capacity: " + capacity);
    capacity = $("#licenseCapa").attr('data-capacity', document.getElementById('licenseCapa').innerHTML);
    if (capacity >= 100000){
      // console.log("changeing capacity to new data capacity");
        console.log("changeing capacity to new data capacity2");
        document.getElementById('licenseCapa').innerHTML = "Unlimited";
      // $("#licenseCapa").load(window.location + " #licenseCapa");
    }
    console.log("new license capa: " + document.getElementById('licenseCapa').innerHTML);
}

function checkKeyInput(userKeyInput){
    var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
    var errMsg = "<p class='errMsg' style='color:red;'>Sorry please reenter the license key again.</p>";
    var applyKeyButton2 = $("#applyKey");
    // console.log("user input: " + userKeyInput);
    //check regex with user input; there is check for duplicate already
    console.log(checkKeyRegex.test(userKeyInput)); //TRUE OR FALSE
      if (checkKeyRegex.test(userKeyInput)){
          $(".errMsg").css('display', 'none');
          $("#keyInput").css('border','1px solid #dfdfdf');
          return true;
      } else {
          $(".errMsg").css('display', 'none');
          applyKeyButton2.after(errMsg);
          $("#keyInput").css('border','1px solid #d9534f');
          return false;
      }
    console.log("done checking key");
}

//check if valid from date is over todays date then turn row into grey
function dateRangeChecker(){
   var table = $("#keyLicenseTable");
      table.find('tr').each(function(i) {
        var $tableColumns = $(this).find('td');
        var validFromColumn = $tableColumns.eq(2).text();
        var validToColumn = $tableColumns.eq(3).text();
        // console.log('Row ' + (i + 1) + ':\n Date: ' + validFromColumn);

        // get todays date
        var todayDate = new Date();
        var dd = todayDate.getDate();
        var mm = todayDate.getMonth() + 1;
        var yyyy = todayDate.getFullYear();
        if(dd < 10){
            dd = '0' + dd;
        }
        if(mm < 10){
            mm = '0' + mm;
        }
        var todaysDate = yyyy + '-' + mm + '-' + dd;
        // console.log("Today: " + todaysDate);

        var formatValidFromColumn = new Date(validFromColumn);
        var formatValidToColumn = new Date(validToColumn);
        var formatTodaysDate = new Date(todaysDate);
        // console.log("Formatted Valid From column: " + formatValidFromColumn);
        // console.log("Formatted Valid To column: " + formatValidToColumn);
        // console.log("Formatted Today date: " + formatTodaysDate);

        var total_days = (formatValidToColumn - formatTodaysDate) / (1000 * 60 * 60 * 24);
        // var total_days = (formatTodaysDate - formatValidToColumn) / (1000 * 60 * 60 * 24);
        // console.log("total after subtraction: " + total_days);

        if (formatValidFromColumn > formatTodaysDate){
            $tableColumns.eq(2).closest('tr').css('color', 'grey');
            $tableColumns.eq(2).closest('tr').css('font-style','italic');
            $tableColumns.eq(2).closest('tr').css('background-color','#eee');
        } else if (formatValidToColumn < formatTodaysDate){
            $tableColumns.eq(2).closest('tr').css('color', 'grey');
            $tableColumns.eq(2).closest('tr').css('font-style','italic');
            $tableColumns.eq(2).closest('tr').css('background-color','#eee');
        }
        if (total_days < 30 && total_days > 0){ //check how many days left till near expiration
            $tableColumns.eq(2).closest('tr').css('color', '#FFC007');
            $("#licenseCapaSpan").css('color','#FFC007');
        }
      });
      console.log("checked date");
}

function userSubmitEula(){
  var base_url = window.location.origin;
  //add ajax call here after submit button pressed
  $.ajax({
      type: 'POST',
      url: base_url + '/eula'
  }).done(function(data){
      console.log(data);
      console.log("sent eula! update key");
       if (checkKey(userKeyInput)){
          updateKeyTable(userKeyInput);
       }
  }).fail(function(xhr, status, error){
      console.log(error);
      console.log("uhoh error");
  });
}
