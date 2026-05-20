$("form#prediction").ready(function() {
  $('#btn_submit_pred_next').click(function(e) {
    e.preventDefault();
    $('input#next').val('true');
    $('form#prediction').submit();
  });
});

$("form#prediction_s").ready(function() {
  $('#btn_submit_pred_next_s').click(function(e) {
    e.preventDefault();
    $('input#next_s').val('true');
    $('form#prediction_s').submit();
  });
});

$("#btnHomeOrigin").click(function(e) {
  e.preventDefault();
  $("#homeOrigin").fadeToggle();
});

$("#btnAwayOrigin").click(function(e) {
  e.preventDefault();
  $("#awayOrigin").fadeToggle();
});

$("#btnHomeOriginXS").click(function(e) {
  e.preventDefault();
  $("#homeOriginXS").fadeToggle();
});

$("#btnAwayOriginXS").click(function(e) {
  e.preventDefault();
  $("#awayOriginXS").fadeToggle();
});

var data;
var scale;

$(document).ready(function() {
  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(init_data);

  // Add click hanlder for the user checkboxes
  $('#collapseUsers').find('[type=checkbox]').click(function(e) {
    draw();
  });
});

 // Create trigger to resizeEnd event
$(window).resize(function() {
  if(this.resizeTo) clearTimeout(this.resizeTo);
  this.resizeTo = setTimeout(function() {
    $(this).trigger('resizeEnd');
  }, 500);
});

// Redraw graph when window resize is completed
$(window).on('resizeEnd', function() {
  draw();
});

function draw() {
  drawChart(data, scale, 'chartMatch')
}

function init_data() {
  // Load the data - only need do this once
  var tmp = initPredictions();
  console.log(tmp);
  data = tmp.data;
  scale = tmp.maxScale;

  // Draw the charts
  draw();
}

function add_message(content, type) {
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

function addListeners() {
  // tree dropdown
  document.getElementById('broadcaster').addEventListener('change', async (e) => {
    let node = e.target.parentElement;
    while (node && node.nodeName != 'FORM') {
      node = node.parentElement;
    }
    if (!node) {
      return;
    }
    const formData = new FormData(node);
    try {
      const response = await fetch(node.action, {
        method: 'POST',
        body: formData
      });
      const content = await response.json();
      if (content.status === "success") {
        add_message(content.message, "info");
      } else {
        add_message(content.message, "danger");
      }
    } catch (error) {
      const message = `Something went wrong :(\n\n${error.message}`;
      add_message(message, "danger");
    }
  });
}

/* ────────────────────  bootstrap  ──────────────────── */
document.addEventListener('DOMContentLoaded', () => {
  addListeners();
});
