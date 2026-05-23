/*
 * Submit & move next buttons
 */

function submitPredictionNext(formSelector, nextSelector) {
  const form = document.querySelector(formSelector);
  const next = document.querySelector(nextSelector);
  if (!form || !next) {
    return;
  }
  next.value = 'true';
  form.submit();
}

function addSubmitListeners() {
  const nextButton = document.getElementById('btn_submit_pred_next');
  if (nextButton) {
    nextButton.addEventListener('click', function(event) {
      event.preventDefault();
      submitPredictionNext('form#prediction', 'input#next');
    });
  }

  const nextButtonSmall = document.getElementById('btn_submit_pred_next_s');
  if (nextButtonSmall) {
    nextButtonSmall.addEventListener('click', function(event) {
      event.preventDefault();
      submitPredictionNext('form#prediction_s', 'input#next_s');
    });
  }
}

/*
 * Change broadcaster
 */

async function changeBroadcaster(event) {
  const form = event.target.form;
  if (!form) {
    return;
  }

  const formData = new FormData(form);
  try {
    const response = await fetch(form.action, {
      method: 'POST',
      body: formData
    });
    const content = await response.json();
    if (content.status === 'success') {
      showAlertMessage(content.message, 'info');
    } else {
      showAlertMessage(content.message, 'danger');
    }
  } catch (error) {
    showAlertMessage('Something went wrong :(\n\n' + error.message, 'danger');
  }
}

function addBroadcasterListener() {
  const broadcaster = document.getElementById('broadcaster');
  if (broadcaster) {
    broadcaster.addEventListener('change', changeBroadcaster);
  }
}

/*
 * Load the listeners, after page load
 */

document.addEventListener('DOMContentLoaded', function() {
  addSubmitListeners();
  addBroadcasterListener();
});
