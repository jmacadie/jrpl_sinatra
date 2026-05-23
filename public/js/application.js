function closest(element, selector) {
  if (!element) {
    return null;
  }
  if (element.closest) {
    return element.closest(selector);
  }
  let node = element;
  while (node) {
    if (node.matches && node.matches(selector)) {
      return node;
    }
    node = node.parentElement;
  }
  return null;
}

function getCollapseTarget(trigger) {
  const selector = trigger.getAttribute('data-target') || trigger.getAttribute('href');
  if (!selector || selector.charAt(0) !== '#') {
    return null;
  }
  return document.querySelector(selector);
}

function syncCollapseTrigger(trigger, expanded) {
  if (!trigger) {
    return;
  }
  trigger.setAttribute('aria-expanded', expanded ? 'true' : 'false');
  if (expanded) {
    trigger.classList.remove('collapsed');
  } else {
    trigger.classList.add('collapsed');
  }
}

function showAlertMessage(content, type) {
  const page = document.querySelector('.page-content');
  if (!page) {
    return;
  }

  const messagePara = document.createElement('p');
  messagePara.className = 'alert alert-' + type + ' alert-dismissable';

  const messageButton = document.createElement('button');
  messageButton.className = 'close';
  messageButton.setAttribute('type', 'button');
  messageButton.setAttribute('data-dismiss', 'alert');
  messageButton.setAttribute('aria-label', 'Close');

  const messageButtonSpan = document.createElement('span');
  messageButtonSpan.setAttribute('aria-hidden', 'true');
  messageButtonSpan.textContent = '×';

  messageButton.appendChild(messageButtonSpan);
  messagePara.appendChild(messageButton);
  messagePara.appendChild(document.createTextNode(content));
  page.insertAdjacentElement('afterbegin', messagePara);
}

function toggleCollapse(trigger) {
  const target = getCollapseTarget(trigger);
  if (!target) {
    return;
  }

  const parentSelector = trigger.getAttribute('data-parent');
  const isOpen = target.classList.contains('in');

  if (parentSelector) {
    const parent = document.querySelector(parentSelector);
    if (parent) {
      parent.querySelectorAll('.collapse.in').forEach(function(openPanel) {
        if (openPanel !== target) {
          openPanel.classList.remove('in');
          const openTrigger = parent.querySelector(
            '[data-toggle="collapse"][href="#' + openPanel.id + '"],' +
            '[data-toggle="collapse"][data-target="#' + openPanel.id + '"]'
          );
          syncCollapseTrigger(openTrigger, false);
        }
      });
    }
  }

  target.classList.toggle('in');
  syncCollapseTrigger(trigger, !isOpen);
}

function toggleDropdown(trigger) {
  const parent = closest(trigger, '.dropdown');
  if (!parent) {
    return;
  }
  parent.classList.toggle('open');
  trigger.setAttribute(
    'aria-expanded',
    parent.classList.contains('open') ? 'true' : 'false'
  );
}

function closeDropdowns() {
  document.querySelectorAll('.dropdown.open').forEach(function(dropdown) {
    dropdown.classList.remove('open');
    const trigger = dropdown.querySelector('[data-toggle="dropdown"]');
    if (trigger) {
      trigger.setAttribute('aria-expanded', 'false');
    }
  });
}

function confirmFormSubmit(event) {
  const form = closest(event.target, 'form');
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

function handleDocumentClick(event) {
  const trigger = closest(event.target, '[data-toggle="collapse"], [data-toggle="dropdown"]');
  if (trigger) {
    event.preventDefault();
    if (trigger.getAttribute('data-toggle') === 'collapse') {
      toggleCollapse(trigger);
    } else {
      toggleDropdown(trigger);
    }
    return;
  }

  const dismiss = closest(event.target, '[data-dismiss="alert"]');
  if (dismiss) {
    const alert = closest(dismiss, '.alert');
    if (alert) {
      alert.remove();
    }
    return;
  }

  if (!closest(event.target, '.dropdown')) {
    closeDropdowns();
  }
}

document.addEventListener('submit', confirmFormSubmit, true);
document.addEventListener('click', handleDocumentClick);
