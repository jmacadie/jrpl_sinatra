$(function() {
  $("form.signout").submit(function(event) {
    event.preventDefault();
    event.stopPropagation();
    var ok = confirm("Are you sure you want to sign out?");
    if (ok) {
      this.submit();
    }
  });
});

