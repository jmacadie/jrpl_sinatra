/*
 * Match predictions graph
 */

function addMatchGraphListeners() {
  var resizeTimer = null;
  window.addEventListener('resize', function() {
    if (resizeTimer) {
      clearTimeout(resizeTimer);
    }
    resizeTimer = setTimeout(function() {
      draw();
    }, 500);
  });

  const usersPanel = document.querySelector('#collapseUsers');
  if (usersPanel) {
    usersPanel.querySelectorAll('[type=checkbox]').forEach(function(checkbox) {
      checkbox.addEventListener('click', function() {
        draw();
      });
    });
  }
}

var matchGraphData;
var matchGraphScale;

function init_data() {
  var tmp = initPredictions();
  matchGraphData = tmp.data;
  matchGraphScale = tmp.maxScale;
  draw();
}

function draw() {
  if (typeof matchGraphData === 'undefined' || typeof matchGraphScale === 'undefined') {
    return;
  }
  drawChart(matchGraphData, matchGraphScale, 'chartMatch');
}

/*
 * Bootstrap functionality
 */

document.addEventListener('DOMContentLoaded', function() {
  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(init_data);

  addMatchGraphListeners();
});

