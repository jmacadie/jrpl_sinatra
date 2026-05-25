async function changeTournamentRole(event) {
  const form = event.target.form;
  if (!form) {
    return;
  }
  await postJsonForm(form);
}

function addTournamentRoleListeners() {
  document.querySelectorAll('.js-tournament-role-select').forEach(function(select) {
    select.addEventListener('change', changeTournamentRole);
  });
}

/*
 * Load the listeners, after page load
 */

document.addEventListener('DOMContentLoaded', function() {
  addTournamentRoleListeners();
});
