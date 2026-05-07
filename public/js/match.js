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
