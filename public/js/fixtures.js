// Do stuff when page is ready
$(document).ready(function() {
  // Add click handler to select / unselect all group stages button
  $("#btnSelectGroup").click(function(e) {
    e.preventDefault();
    selectAllGroups($(this).attr('data-mode'));
  });
});

function selectAllGroups (mode) {
  // see if we're selecting or unselecting
  if (mode === 'unselect') {
    // Change all the checkbox states to unchecked
    $('#collapseGroup').find('[type=checkbox]').prop('checked', false);
    // Change button text back to select all
    $("#btnSelectGroup").text('Select All').attr('data-mode', 'select');
  } else {
    // Change all the checkbox states to checked
    $('#collapseGroup').find('[type=checkbox]').prop('checked', true);
    // Change button text back to unselect all
    $("#btnSelectGroup").text('Unselect All').attr('data-mode', 'unselect');
  }
}
