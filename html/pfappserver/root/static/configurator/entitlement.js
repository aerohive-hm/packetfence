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
        url: base_url + '/entitlement/trial',
        dataType: json
    }).done(function(data){
        console.log(data);
        console.log("success!");
    }).fail(function(data){
        console.log("error");
    });
}
