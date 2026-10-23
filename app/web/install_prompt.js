'use strict';
// "Install after the 2nd visit" (docs/07 Web, docs/09 M5.7): keeps the
// browser's install event and a visit count for the app's own banner.
// Visits and "not now" stay in this browser (localStorage), nothing else.
(function () {
  const VISITS = 'dottoday.visits';
  const DISMISSED = 'dottoday.installDismissed';
  let deferred = null;
  let visits = 0;
  try {
    visits = (Number(localStorage.getItem(VISITS)) || 0) + 1;
    localStorage.setItem(VISITS, String(visits));
  } catch (_) {}
  const dismissed = () => {
    try { return localStorage.getItem(DISMISSED) === '1'; } catch (_) { return false; }
  };
  window.addEventListener('beforeinstallprompt', (event) => {
    event.preventDefault();
    deferred = event;
    window.dispatchEvent(new Event('dottoday-installable'));
  });
  window.addEventListener('appinstalled', () => { deferred = null; });
  window.dottodayInstall = {
    available: () => deferred !== null && visits >= 2 && !dismissed(),
    prompt: async () => {
      if (!deferred) return false;
      const event = deferred;
      deferred = null;
      await event.prompt();
      return (await event.userChoice).outcome === 'accepted';
    },
    dismiss: () => { try { localStorage.setItem(DISMISSED, '1'); } catch (_) {} },
  };
})();
