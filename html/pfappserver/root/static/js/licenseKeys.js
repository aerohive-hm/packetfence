
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
     $("#usedCapacitySpan").after("<span class='glyphicon glyphicon-warning-sign' style='color: orange;'></span>");
  }
});

function applyKeyButton(){
  var applyKeyButton2 = $("#applyKey");
  applyKeyButton2.click(function(){
    var userKeyInput = document.getElementById('keyInput').value;
    console.log(userKeyInput);
    checkKeyInput(userKeyInput);

  });
}

function updateKeyTable(a) {
    $.ajax('licenseKeys.tt', {
      success: function(response) {
        $('.card').html(response);
      }
    });
}

function checkKeyInput(userKeyInput){
    // var userKeyInput = document.getElementById('keyInput').value;
    var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
    var errMsg = "<p class='errMsg' style='color:red;'>Sorry please reenter the license key again.</p>";
    var applyKeyButton2 = $("#applyKey");
    //need to check if key exists
    console.log("input1: " + userKeyInput);
    //check regex with user input
    console.log(checkKeyRegex.test(userKeyInput));
    if (checkKeyRegex.test(userKeyInput) == true){
      $(".errMsg").css('display', 'none');
      $("#keyInput").css('border','1px solid #dfdfdf');
    } else {
        $(".errMsg").css('display', 'none');
        applyKeyButton2.after(errMsg);
        $("#keyInput").css('border','1px solid #d9534f');
    }
}
