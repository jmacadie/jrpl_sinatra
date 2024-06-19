$(document).ready(function() {
  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(drawCharts);

  // Add click hanlder for the user checkboxes
  $('#collapseUsers').find('[type=checkbox]').click(function(e) {
    drawCharts();
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
  drawCharts();
});

 // Build up series array for
function getSeries() {

  // get all elements in the form
  var series =[];
  var $ckb;

  // loop through the elements
  // grab colour if checked or grey if not
  // make sure they're sorted right!
  // This only works because the points data from the sever AND the user select
  // check boxes are BOTH sorted alphabetically. If they are not sorted the
  // same, this will break
  $('#collapseUsers').find('[type=checkbox]').each(function(index) {
    $ckb = $(this);
    if ($ckb.is(':checked')) {
      series[index] = {visibleInLegend: true, pointSize: 3, lineWidth: 3};
    } else {
      series[index] = {color: '#dddddd', visibleInLegend: false, pointSize: 0, lineWidth: 1};
    }
  });

  return series;
}

function drawChart(f, id, rev=false) {

  // Determine the dimensions
  var h = $(window).height();
  var w = $(window).width();

  // Max width
  w = Math.min(w,700);

  // Padding
  h -= 90;
  w -= 30;

  // Keep 9 x 5 dimensions
  if ((h / 5 * 9) > w) {
    h = w / 9 * 5;
  } else {
    w = h / 5 * 9;
  }

  // Set the options
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
