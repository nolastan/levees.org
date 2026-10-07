// Mobile "More…" drawer, mirroring the levees.org navbar-burger behavior.
(function () {
  var toggle = document.querySelector('.nav-toggle');
  var drawer = document.getElementById('drawer');
  if (!toggle || !drawer) return;

  function open() {
    drawer.hidden = false;
    toggle.setAttribute('aria-expanded', 'true');
    var first = drawer.querySelector('a, button');
    if (first) first.focus();
  }
  function close() {
    drawer.hidden = true;
    toggle.setAttribute('aria-expanded', 'false');
    toggle.focus();
  }
  toggle.addEventListener('click', open);
  drawer.addEventListener('click', function (e) {
    if (e.target.closest('[data-close]')) close();
  });
  document.addEventListener('keydown', function (e) {
    if (e.key === 'Escape' && !drawer.hidden) close();
  });
})();
