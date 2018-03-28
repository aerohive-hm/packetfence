
// all html elements

$(document).ready(function(){
  var licenseCapacity = document.getElementById("licenseCapa");
  var usedCapacity = document.getElementById("usedCapacity");
  var usedCapacity2 = $("#usedCapacity");
  var usedCapacity3 = $(".usedCapacitySpan");
  var licenseCapacity3 = $(".licenseCapaSpan");
  console.log(licenseCapacity.innerHTML);

  applyKeyButton();

// capacity alert status changes
  if(licenseCapacity.innerHTML > 100000){
     licenseCapacity.innerHTML = "Unlimited";
  }
  if(usedCapacity.innerHTML > licenseCapacity.innerHTML){
     usedCapacity2.css('color', 'red');
     $("#usedCapacitySpan").css('color', 'red');
     $("#usedCapacitySpan").after("<span class='glyphicon glyphicon-warning-sign' style='color: red;'></span>");
  }
  dateRangeChecker();
});

// apply button press
function applyKeyButton(){
  var applyKeyButton2 = $("#applyKey");
  applyKeyButton2.click(function(){
    var userKeyInput = document.getElementById('keyInput').value;
    console.log(userKeyInput);

    if (checkKeyInput(userKeyInput) == true){
      updateKeyTable(userKeyInput);
    }
    //check if key already exists in table
  });
}

// update table after checking regex
function updateKeyTable(userKeyInput) {
    var applyKeyButton2 = $("#applyKey");
    applyKeyButton2.on('click', function(e) {
        $.ajax({
            url : 'https://10.16.134.239:1443/entitlement/key/' + userKeyInput,
            type : 'PUT',
            dataType : 'json',
            success : function(data) {
            },
            error : function() {
                console.log('error');
            }
        });
    });
}


function checkKeyInput(userKeyInput){
    // var userKeyInput = document.getElementById('keyInput').value;
    var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
    var errMsg = "<p class='errMsg' style='color:red;'>Sorry please reenter the license key again.</p>";
    var applyKeyButton2 = $("#applyKey");
    console.log("input1: " + userKeyInput);
    //check regex with user input
    console.log(checkKeyRegex.test(userKeyInput));
    if (checkKeyRegex.test(userKeyInput) == true){
      $(".errMsg").css('display', 'none');
      $("#keyInput").css('border','1px solid #dfdfdf');
          //need to check if key exists; ajax call?
    } else {
        $(".errMsg").css('display', 'none');
        applyKeyButton2.after(errMsg);
        $("#keyInput").css('border','1px solid #d9534f');
    }
    return true;
}

//check if valid from date is over todays date then turn row into grey
function dateRangeChecker(){
   var table = $("#keyLicenseTable");
      table.find('tr').each(function(i) {
          var $tableColumns = $(this).find('td');
          var validFromColumn = $tableColumns.eq(2).text();
          var validToColumn = $tableColumns.eq(3).text();
          console.log('Row ' + (i + 1) + ':\n Date: ' + validFromColumn);

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
          console.log("Today: " + todaysDate);

          var formatValidFromColumn = new Date(validFromColumn);
          var formatValidToColumn = new Date(validToColumn);
          var formatTodaysDate = new Date(todaysDate);
          console.log("Formatted Valid From column: " + formatValidFromColumn);
          console.log("Formatted Valid To column: " + formatValidFromColumn);
          console.log("Formatted Today date: " + formatTodaysDate);

          if (formatValidFromColumn > formatTodaysDate){
              $tableColumns.eq(2).closest('tr').css('color', 'grey');
              $tableColumns.eq(2).closest('tr').css('font-style','italic');
              $tableColumns.eq(2).closest('tr').css('background-color','#eee');
          } else if ((formatTodaysDate - formatValidFromColumn) > 15){

              // var timeDiff = Math.abs(date2.getTime() - date1.getTime());
              // var diffDays = Math.float(timeDiff / (1000 * 3600 * 24));
              // need to recalc; should take in account for Daylight savings?
          } else{
              //do nothing
          }
      });

}
