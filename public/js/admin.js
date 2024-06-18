$(function() {
  $("form.reset-pword").submit(function(event) {
    event.preventDefault();
    event.stopPropagation();
    var ok = confirm("Are you sure you want to reset the password? This cannot be undone!");
    if (ok) {
      this.submit();
    }
  });
});

$(function() {
  $("form.toggle-admin").submit(function(event) {
    event.preventDefault();
    event.stopPropagation();
    var ok = confirm("Are you sure you want to change admin permissions?");
    if (ok) {
      this.submit();
    }
  });
});

$(function() {
  $("form.delete-user").submit(function(event) {
    event.preventDefault();
    event.stopPropagation();
    var name = $(this).children('input[name="user_name"]').val()
    var ok = confirm("Are you sure you want to delete " + name + "? This cannot be undone!");
    if (ok) {
      this.submit();
    }
  });
});
