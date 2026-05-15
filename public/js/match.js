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
