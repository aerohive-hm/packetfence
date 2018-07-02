$(document).ready(function () {
  updateButton();
});

function updateButton() {
  var updateButton = $("#update-button");
  updateButton.click(function () {
    updateButton.addClass('disabled');
    $.ajax({
      url: '/update/latest',
      type: 'POST'
    }).done(function (data) {
      updateButton.slideUp();
      $('.detail-box').empty();
      $('.detail-box').text('Starting A3 update...');
      sleep(10000).then(function () { pollForProgress(); });
    }).fail(function (xhr, status, error) {
      console.log(error);
      // TODO: Error message in UI
    });
  });
}

function pollForProgress() {
  $.ajax({
      url: '/update/progress',
      type: 'GET'
  }).done(function (data) {
    $('.detail-box').html(data.update_progress.split('\n').join('<br/>'));

    if (data.update_progress.indexOf("") === -1
        && data.update_progress.indexOf("") === -1) {
      sleep(10000).then(function () { pollForProgress(); });
    }
  });
}

function sleep (time) {
  return new Promise((resolve) => setTimeout(resolve, time));
}
