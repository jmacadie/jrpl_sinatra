function updateGroupButton(text, mode) {
  var button = document.getElementById('btnSelectGroup');
  if (!button) {
    return;
  }
  button.textContent = text;
  button.setAttribute('data-mode', mode);
}

function selectAllGroups (mode) {
  var collapse = document.getElementById('collapseGroup');
  if (!collapse) {
    return;
  }
  if (mode === 'unselect') {
    collapse.querySelectorAll('[type=checkbox]').forEach(function(checkbox) {
      checkbox.checked = false;
    });
    updateGroupButton('Select All', 'select');
  } else {
    collapse.querySelectorAll('[type=checkbox]').forEach(function(checkbox) {
      checkbox.checked = true;
    });
    updateGroupButton('Unselect All', 'unselect');
  }
}

document.addEventListener('DOMContentLoaded', function() {
  const button = document.getElementById('btnSelectGroup');
  if (!button) {
    return;
  }
  button.addEventListener('click', function(event) {
    event.preventDefault();
    selectAllGroups(button.getAttribute('data-mode'));
  });
});

