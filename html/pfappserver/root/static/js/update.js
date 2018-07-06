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
    if (data.update_progress) {
      $('.detail-box').html(data.update_progress.split('\n').join('<br/>'));
      scheduleNext(data.update_progress);
    }
    else {
      scheduleNext('');
    }
  }).fail(function (xhr, status, error) {
    console.log(error);
    // TODO: Error message in UI

    // Schedule next anyway
    scheduleNext('');
  });
}

function scheduleNext(update_progress) {
  if (update_progress.indexOf("Update was unsuccessful.") === -1
      && update_progress.indexOf("Update completed successfully.") === -1) {
    sleep(10000).then(function () { pollForProgress(); });
  }
  else {
    console.log("Progress if final. No need to schedule next poll.")
  }
}

function sleep (time) {
  return new Promise((resolve) => setTimeout(resolve, time));
}
