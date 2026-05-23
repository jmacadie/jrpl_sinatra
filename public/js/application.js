function showAlertMessage(content, type) {
  const page = document.querySelector('.page-content');
  if (!page) {
    return;
  }

  const messagePara = document.createElement('div');
  messagePara.className = 'alert alert-' + type + ' alert-dismissible fade show';
  messagePara.setAttribute('role', 'alert');

  const messageButton = document.createElement('button');
  messageButton.className = 'btn-close';
  messageButton.setAttribute('type', 'button');
  messageButton.setAttribute('data-bs-dismiss', 'alert');
  messageButton.setAttribute('aria-label', 'Close');

  messagePara.appendChild(messageButton);
  messagePara.appendChild(document.createTextNode(content));
  page.insertAdjacentElement('afterbegin', messagePara);
}

function confirmFormSubmit(event) {
  const form = event.target.closest('form');
  if (!form) {
    return;
  }

  let message;
  if (form.classList.contains('signout')) {
    message = 'Are you sure you want to sign out?';
  } else if (form.classList.contains('reset-pword')) {
    message = 'Are you sure you want to reset the password? This cannot be undone!';
  } else if (form.classList.contains('toggle-admin')) {
    message = 'Are you sure you want to change admin permissions?';
  } else if (form.classList.contains('delete-user')) {
    const input = form.querySelector('input[name="user_name"]');
    const name = input ? input.value : '';
    message = 'Are you sure you want to delete ' + name + '? This cannot be undone!';
  }

  if (!message) {
    return;
  }

  if (!window.confirm(message)) {
    event.preventDefault();
  }
}

document.addEventListener('submit', confirmFormSubmit, true);
