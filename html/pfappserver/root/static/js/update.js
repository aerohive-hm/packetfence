$(document).ready(function () {
  updateButton();
});

function updateButton() {
  var updateButton = $("#update-button");
  updateButton.click(function () {
    $.ajax({
      url: window.location.origin + '/update/latest',
      type: 'POST'
    }).done(function (data) {
      $("#update-button").slideUp();
      $(".progress-bar-content").slideDown();
    }).fail(function (xhr, status, error) {
      console.log(error);
      // TODO: Error message in UI
    });
  });
}
