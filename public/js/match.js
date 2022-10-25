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
