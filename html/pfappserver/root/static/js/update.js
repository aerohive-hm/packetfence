$(document).ready(function () {
  updateButton();

  var inProgress = $(".update-in-progress");
  if (inProgress.length > 0) {
    pollForProgress();
  }
});

function updateButton() {
  var updateButton = $("#update-button");
  updateButton.click(function () {
    updateButton.addClass('disabled');
    $.ajax({
      url: '/update/latest',
      type: 'POST'
    }).done(function () {
      updateButton.slideUp();
      $('.detail-box').empty();
      $('.detail-box').text('Starting A3 update...');
      sleep(10000).then(function () { pollForProgress(); });
    }).fail(function (xhr, status, error) {
      console.log(error);
    });
  });
}

function pollForProgress() {
  $.ajax({
      url: '/update/progress',
      type: 'GET'
  }).done(function (data) {
    if (data.update_progress) {
      $('.detail-box').html(data.update_progress.join('<br/>'));
      scheduleNext(data.update_progress);
    }
    else {
      scheduleNext(['']);
    }
  }).fail(function (xhr, status, error) {
    console.log(error);
    scheduleNext(['']);
  });
}

function scheduleNext(update_progress) {
  var lastLine = update_progress[update_progress.length - 1];

  if (lastLine && isTerminal(lastLine)) {
    console.log("Progress is final. No need to schedule next poll.")
  }
  else {
    sleep(10000).then(function () { pollForProgress(); });
  }
}

function isTerminal(line) {
  return line.indexOf("Update was unsuccessful.")       !== -1
      || line.indexOf("Update completed successfully.") !== -1;
}

function sleep (time) {
  return new Promise((resolve) => setTimeout(resolve, time));
}
