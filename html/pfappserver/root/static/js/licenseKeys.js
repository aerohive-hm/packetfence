
// all html elements

$(document).ready(function(){
  var licenseCapacity = document.getElementById("licenseCapa");
  var usedCapacity = document.getElementById("usedCapacity");
  var usedCapacity2 = $("#usedCapacity");
  var usedCapacity3 = $(".usedCapacitySpan");
  var licenseCapacity3 = $(".licenseCapaSpan");
  console.log(licenseCapacity.innerHTML);

  applyKeyButton();

  // var checkKeyRegex = RegExp("^[\\s]*([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})-([A-Z0-9]{5})[\\s]*$");
  // //need to check if key exists
  // var userKeyInput = document.getElementById('keyInput').value;
  // console.log("input1: " + userKeyInput);
  // //check regex with user input
  // console.log(checkKeyRegex.test(userKeyInput));
  // if (checkKeyRegex.test(userKeyInput) == true){
  //   // check if key exists in keyArray
  // } else {
  //     var errMsg = "<span class='errMsg'>Sorry please reenter the license key again.</span>";
  //     $("label").before(errMsg);
  //     $("#keyInputt").css('border','1px solid #d9534f');
  // }

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
  var userKeyInput = document.getElementById('keyInput').value;
  applyKeyButton2.click(function(){
    console.log(userKeyInput);
  });
}

function updateKeyTable(a) {
    $.ajax('licenseKeys.tt', {
      success: function(response) {
        $('.card').html(response);
      }
    });
}
