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
 * Show match origin buttons
 */

function togglePanel(panelId) {
  const panel = document.getElementById(panelId);
  if (!panel) {
    return;
  }
  if (panel.style.display === 'none' || !panel.style.display) {
    panel.style.display = 'block';
  } else {
    panel.style.display = 'none';
  }
}

function addOriginListener(button, panel) {
  const originButton = document.getElementById(button);
  if (originButton) {
    originButton.addEventListener('click', function(event) {
      event.preventDefault();
      togglePanel(panel);
    });
  }

}

function addOriginListeners() {
  addOriginListener('btnHomeOrigin', 'homeOrigin');
  addOriginListener('btnAwayOrigin', 'awayOrigin');
  addOriginListener('btnHomeOriginXS', 'homeOriginXS');
  addOriginListener('btnAwayOriginXS', 'awayOriginXS');
}

/*
 * Change broadcaster
 */

function addMessage(content, type) {
  const page = document.querySelector(".page-content");
  if (!page) {
    return;
  }

  const messagePara = document.createElement("p");
  messagePara.classList = "alert";
  messagePara.classList.add(`alert-${type}`);
  messagePara.classList.add("alert-dismissable");

  const messageButton = document.createElement("button");
  messageButton.classList = "close";
  messageButton.setAttribute("type", "button");
  messageButton.setAttribute("data-dismiss", "alert");
  messageButton.setAttribute("aria-label", "Close");

  const messageButtonSpan = document.createElement("span");
  messageButtonSpan.setAttribute("aria-hidden", "true");
  messageButtonSpan.innerText = "×";

  messageButton.appendChild(messageButtonSpan);
  messagePara.appendChild(messageButton);

  const messageText = document.createTextNode(content);
  messagePara.appendChild(messageText);

  page.insertAdjacentElement("afterbegin", messagePara);
}

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
      addMessage(content.message, 'info');
    } else {
      addMessage(content.message, 'danger');
    }
  } catch (error) {
    addMessage('Something went wrong :(\n\n' + error.message, 'danger');
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
  addOriginListeners();
  addBroadcasterListener();
});
