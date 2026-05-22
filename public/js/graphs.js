document.addEventListener('DOMContentLoaded', function() {
  var usersPanel = document.querySelector('#collapseUsers');
  if (usersPanel) {
    usersPanel.querySelectorAll('[type=checkbox]').forEach(function(checkbox) {
      checkbox.addEventListener('click', function() {
        drawCharts();
      });
    });
  }

  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(drawCharts);
});

var graphResizeTimer = null;
window.addEventListener('resize', function() {
  if (graphResizeTimer) {
    clearTimeout(graphResizeTimer);
  }
  graphResizeTimer = setTimeout(function() {
    drawCharts();
  }, 500);
});

 // Build up series array for
function getSeries() {
  var series = [];
  var checkboxes = document.querySelectorAll('#collapseUsers [type=checkbox]');

  checkboxes.forEach(function(checkbox, index) {
    if (checkbox.checked) {
      series[index] = {visibleInLegend: true, pointSize: 3, lineWidth: 3};
    } else {
      series[index] = {color: '#dddddd', visibleInLegend: false, pointSize: 0, lineWidth: 1};
    }
  });

  return series;
}

function drawChart(f, id, rev=false) {
  var h = window.innerHeight;
  var w = window.innerWidth;

  w = Math.min(w,700);
  h -= 90;
  w -= 30;
  if ((h / 5 * 9) > w) {
    h = w / 9 * 5;
  } else {
    w = h / 5 * 9;
  }

  var options = {
    chartArea: {width:'100%', height:'100%'},
    height: h,
    width: w,
    legend: {position: 'in'},
    hAxis: {textPosition: 'none', baselineColor: 'transparent', gridlines: {color: 'transparent'}},
    vAxis: {textPosition: 'none', baselineColor: 'transparent', gridlines: {color: 'transparent'}},
    series: getSeries()};

  if (rev) {
    options.vAxis.direction = -1;
  }

  var chart = new google.visualization.LineChart(document.getElementById(id));
  chart.draw(f(), options);
}

function drawCharts() {
  drawChart(initOverallPoints, 'chartOverall');
  drawChart(initRelativePoints, 'chartRelative');
  drawChart(initPosition, 'chartPosition', true);
}
