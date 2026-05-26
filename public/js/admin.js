async function changeTournamentRole(event) {
  const form = event.target.form;
  if (!form) {
    return;
  }
  const content = await postJsonForm(form);
  if (content && content.status == 'success') {
    setTeamDisabled(form.parentElement);
    setFormat(event.target, content.reset);
  }
}

function setTeamDisabled(container) {
  const selects = [...container.querySelectorAll('select')];
  const selectedValues = new Set(
    selects
      .map(select => select.value)
      .filter(value => value !== '0')
  );

  for (const select of selects) {
    for (const option of select.options) {
      if (option.value === '0') {
        option.disabled = false;
        continue;
      }
      option.disabled =
        selectedValues.has(option.value) &&
        option.value !== select.value;
    }
  }
}

function setFormat(select, reset) {
  const row = select.closest('div.row');
  if (!row) {
    return;
  }

  const format_picked = ['fw-bold', 'text-primary-emphasis'];
  const format_not_picked = ['fst-italic', 'fw-light', 'text-body-tertiary'];
  if (reset) {
    row.classList.remove(...format_picked);
    row.classList.add(...format_not_picked);
  } else {
    row.classList.remove(...format_not_picked);
    row.classList.add(...format_picked);
  }

}

function addTournamentRoleListeners() {
  document.querySelectorAll('.tournament-role-select').forEach(function(select) {
    select.addEventListener('change', changeTournamentRole);
  });
}


/*
 * Load the listeners, after page load
 */

document.addEventListener('DOMContentLoaded', function() {
  addTournamentRoleListeners();
});
